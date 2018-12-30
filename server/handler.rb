module AP
  class Handler
    def initialize(socket, id)
      @socket = socket
      @id = id
      @agents = AP.getagents(@id)
      @headers = {
        :AP=>"3.0",
        :APS=>nil,
        :Code=>"200 OK",
        :Content=>{}
      }
      @userinfo = [nil, 0]
      AP.log("Handler created", @id)
    end

    def run()
      begin
        agent = Fulfillment.new
        request = Hash.new
        request[:Connection] = "keep-alive"

        while request[:Connection] == "keep-alive"
          input = @socket.gets
          AP.log(input, @id, "rawin")

          if input.nil? # Send flow to log:"socket closed" if buffer is nil
            AP.log("Bad request: request is empty", @id, "warning")
            @socket.puts(@headers.merge({:Code=>"400 Bad Request", :Content=>{:Response=>"Request is empty"}}).to_json)
            return true
          end

          if input.split(" ")[0] == "GET" || input.split(" ")[0] == "POST" || input.split(" ")[0] == "HEAD"
            AP.log("Bad request: cannot handle HTTP requests", @id, "warning")
            @socket.puts(@headers.merge({:Code=>"400 Bad Request", :Content=>{:Response=>"Cannot handle HTTP requests"}}).to_json)
            return true
          end
          
          input = JSON.parse(input)

          if input.kind_of?(Array) && @userinfo[0].nil?
            output = Auth.login(input[0], input[1])
            if output
              @userinfo = [input[0], output]
              AP.log("Login successful (#{input[0]})", @id)
              @socket.puts(@headers.merge({:Code=>"200 OK", :Content=>{:Response=>"Login successful", :Power=>@userinfo[1]}}).to_json)
            else
              AP.log("Login failed (#{input[0]})", @id)
              @socket.puts(@headers.merge({:Code=>"401 Unauthorized", :Content=>{:Response=>"Login failed"}}).to_json)
            end
          else
            request = AP.jsontosym(input)

            agent.history.push([request]) # Save in history the request

            if AP.agentcommand?(@agents, request[:User_Agent], request[:Content][:Request])
              required_power = AP.getagentminpower(@agents, request[:User_Agent], request[:Content][:Request])
              if @userinfo[1] >= required_power
                AP.log("Running agent \"#{request[:User_Agent]}\"", @id)
                out = agent.public_send(request[:User_Agent].downcase, request, @userinfo)

                AP.log("Responding to request...", @id)
                out[1] ? response = @headers.merge(out[0]).to_json : response = out[0].to_json # If required merge request with headers
                @socket.puts(response)
                AP.log(response, @id, "rawout")
                agent.history[-1].push(response) # Save in history the response
              else # Not enough power
                response = @headers.merge({:Code=>"401 Unauthorized", :Content=>{:Response=>"PW#{@userinfo[1]} instead of required PW#{required_power}"}})
                AP.log("Authorization issue: PW#{@userinfo[1]} instead of required PW#{required_power}", @id, "warning")
                AP.log(response, @id, "rawout")
                agent.history[-1].push(response) # Save in history the response
                @socket.puts(response)
              end
            else # Invalid agent or command
              response = @headers.merge({:Code=>"404 Not Found", :Content=>{:Response=>"Agent or command does not exists"}}).to_json
              AP.log("Bad request: Agent or command not exists", @id, "warning")
              AP.log(response, @id, "rawout")
              agent.history[-1].push(response) # Save in history the response
              @socket.puts(response)
            end
          end
        end
      rescue
        # put internal server error
        AP.log("Internal server error", @id, "error")
        AP.log($!, @id, "backtrace")
        AP.log($!.backtrace, @id, "backtrace")
        
        error = @headers.merge({:Code=>"500 Internal Server Error"}).to_json
        @socket.puts(error)
        AP.log(error, @id, "rawout")
      end
    end
  end
end
