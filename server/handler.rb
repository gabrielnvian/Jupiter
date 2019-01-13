module AP
  class Handler
    def initialize(socket, id, agents)
      @socket = socket
      @id = id
      @agents = agents
      @headers = {
        :AP=>"3.2",
        :APS=>nil,
        :Code=>"200 OK",
        :Content=>{}
      }
      @userinfo = [nil, 0]
      AP.log("Handler creato", @id)
    end

    def run()
      begin
        agent = Fulfillment.new
        request = Hash.new
        request[:Connection] = "keep-alive"

        while request[:Connection] == "keep-alive"
          input = @socket.gets
          tolog = input

          if input.nil? # Send flow to log:"socket closed" if buffer is nil
            AP.log("Bad request: la request e' vuota", @id, "warning")
            @socket.puts(@headers.merge({:Code=>"400 Bad Request", :Content=>{:Response=>"La request e' vuota"}}).to_json)
            return
          end

          if input.split(" ")[0] == "GET" || input.split(" ")[0] == "POST" || input.split(" ")[0] == "HEAD"
            AP.log("Bad request: il protocollo HTTP non e' supportato", @id, "warning")
            @socket.puts(@headers.merge({:Code=>"400 Bad Request", :Content=>{:Response=>"Impossibile servire attraverso HTTP"}}).to_json)
            return
          end
          
          input = JSON.parse(input)

          # BEGIN LOGIN BLOCK ---------------------------------------------------------
          if input.kind_of?(Array) && @userinfo[0].nil?
            output = Auth.login(input[0], input[1])
            if output
              @userinfo = [input[0], output]
              AP.log("Login eseguito (#{input[0]})", @id)
              @socket.puts(@headers.merge({:Code=>"200 OK", :Content=>{:Response=>"Login eseguito", :Power=>@userinfo[1]}}).to_json)
            else
              AP.log("Login fallito (#{input[0]})", @id)
              @socket.puts(@headers.merge({:Code=>"401 Unauthorized", :Content=>{:Response=>"Login fallito"}}).to_json)
            end
          elsif input.kind_of?(Array) && !@userinfo[0].nil?
            AP.log("Login gia' eseguito (#{@userinfo[0]})", @id)
            @socket.puts(@headers.merge({:Code=>"400 Bad Request", :Content=>{:Response=>"Login gia' eseguito (#{@userinfo[0]})"}}).to_json)
          # END LOGIN BLOCK ------------------------------------------------------------
          else
            AP.log(tolog, @id, "rawin")
            request = AP.jsontosym(input)

            agent.history.push([request]) # Save in history the request

            if AP.agentcommand?(@agents, request[:User_Agent], request[:Content][:Request])
              required_power = AP.getagentminpower(@agents, request[:User_Agent], request[:Content][:Request])
              if @userinfo[1] >= required_power
                AP.log("Lancio di \"#{request[:User_Agent]}\" in corso", @id)
                out = agent.public_send(request[:User_Agent].downcase, request, @userinfo)

                #AP.log("Responding to request...", @id)
                out[1] ? response = @headers.merge(out[0]).to_json : response = out[0].to_json # If required merge request with headers
                @socket.puts(response)
                AP.log(response, @id, "rawout")
                agent.history[-1].push(response) # Save in history the response
              else # Not enough power
                response = @headers.merge({:Code=>"401 Unauthorized", :Content=>{:Response=>"E' necessario un livello PW#{required_power} (PW#{@userinfo[1]})"}}).to_json
                AP.log("Errore di autorizzazione: E' necessario un livello PW#{required_power} (PW#{@userinfo[1]})", @id, "warning")
                AP.log(response, @id, "rawout")
                agent.history[-1].push(response) # Save in history the response
                @socket.puts(response)
              end
            else # Invalid agent or command
              response = @headers.merge({:Code=>"404 Not Found", :Content=>{:Response=>"L'agente o il comando richiesto non esiste"}}).to_json
              AP.log("L'agente o il comando richiesto non esiste", @id, "warning")
              AP.log(response, @id, "rawout")
              agent.history[-1].push(response) # Save in history the response
              @socket.puts(response)
            end
          end
        end
      rescue
        # put internal server error
        AP.log("Errore interno del server", @id, "error")
        AP.log($!, @id, "backtrace")
        AP.log($!.backtrace, @id, "backtrace")
        
        error = @headers.merge({:Code=>"500 Internal Server Error", :Content=>{:Response=>"Errore interno del server"}}).to_json
        @socket.puts(error)
        AP.log(error, @id, "rawout")
      end
    end
  end
end
