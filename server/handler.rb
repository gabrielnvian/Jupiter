module Jupiter
  class Handler
    def initialize(socket, id, agents)
      @socket = socket
      @id = id
      @agents = agents
      @headers = {
        J: CONFIG[:version],
        JS: nil,
        Code: '200 OK',
        Cont: {}
      }
      @userinfo = [nil, 0]
      LOG.debug("#{@id}: Handler creato")
    end

    def run
      begin
        agent = Fulfillment.new
        request = {}
        request[:Connection] = 'keep-alive'

        while request[:Connection] == 'keep-alive'
          input = @socket.gets
          tolog = input

          # Check if request is empty or not supported and respond
          return false unless check_request(input)

          input = JSON.parse(input)

          # BEGIN LOGIN BLOCK --------------------------------------------------
          # If request contains (possibly) login credentials &&
          # user is not logged in
          if input.kind_of?(Array) && @userinfo[0].nil?
            if Auth.login(input[0], input[1])
              @userinfo = [input[0], output]
              LOG.debug("#{@id}: Login eseguito (#{input[0]})")
              @socket.puts(@headers.merge(Code: '200 OK', Cont: { Resp: "Login eseguito come #{@userinfo[0]}", Power: @userinfo[1] }).to_json)
            else
              LOG.warn("#{@id}: Login fallito (#{input[0]})")
              @socket.puts(@headers.merge(Code: '401 Unauthorized', Cont: { Resp: 'Login fallito' }).to_json)
            end
          # If request contains (possibly) login credentials but
          # user is already logged in
          elsif input.is_a?(Array) && !@userinfo[0].nil?
            LOG.debug("#{@id}: Login gia' eseguito (#{@userinfo[0]})")
            @socket.puts(@headers.merge(Code: '400 Bad Request', Cont: { Resp: "Login gia' eseguito (#{@userinfo[0]})" }).to_json)
          # END LOGIN BLOCK ----------------------------------------------------
          else
            LOG.debug("#{@id}: #{tolog}")
            # Parse request
            request = Jupiter.jsontosym(input)
            # Save request in connection's history
            agent.history.push([request])

            # If command is allowed for the requested agent
            if Jupiter.agentcommand?(@agents, request[:Agent], request[:Cont][:Req])
              # Get required power to run this task
              req_power = Jupiter.getagentminpower(@agents, request[:Agent], request[:Cont][:Req])

              # If user power >= required power
              if @userinfo[1] >= req_power
                # Run task and get output as out
                LOG.debug("#{@id}: Lancio di \"#{request[:User_Agent]}\" in corso")
                out = agent.public_send(request[:User_Agent].downcase, request, @userinfo)

                LOG.debug("#{@id}: Responding to request...")
                # If out[1] is true, merge output into headers
                if out[1]
                  response = @headers.merge(out[0]).to_json
                else
                  response = out[0].to_json
                end

                # Send response to client
                @socket.puts(response)
                LOG.debug("#{@id}: #{response}")

                # Save response from client in history
                agent.history[-1].push(response)

              # User power < required power
              else
                # Respond with code 401 (Unauthorized)
                response = @headers.merge(Code: '401 Unauthorized', Cont: { Resp: "E' necessario un livello PW#{req_power} (PW#{@userinfo[1]})" }).to_json
                LOG.warn("#{@id}: Errore di autorizzazione: E' necessario un livello PW#{req_power} (PW#{@userinfo[1]})")
                LOG.debug("#{@id}: #{response}")
                agent.history[-1].push(response) # Save response in history
                @socket.puts(response)
              end

            # Agent or command is not allowed
            else
              # Respond with code 404 (Not Found)
              response = @headers.merge(Code: '404 Not Found', Cont: { Resp: "L'agente o il comando richiesto non esiste" }).to_json
              LOG.warn("#{@id}: L'agente o il comando richiesto non esiste")
              LOG.debug("#{@id}: #{response}")
              agent.history[-1].push(response) # Save in history the response
              @socket.puts(response)
            end
          end
        end
      rescue
        # Raise code 500 (Internal Server Error)
        LOG.error("#{@id}: Errore interno del server")
        LOG.debug("#{@id}: #{$ERROR_INFO}")
        LOG.debug("#{@id}: #{$ERROR_INFO.backtrace}")

        error = @headers.merge(Code: '500 Internal Server Error', Cont: { Resp: 'Errore interno del server' }).to_json
        @socket.puts(error)
        LOG.debug("#{@id}: #{error}")
      end
    end

    def check_request(input1)
      if input1.nil? # Send flow to log:"socket closed" if buffer is nil
        LOG.warn("#{@id}: Bad request: la request e' vuota")
        @socket.puts(@headers.merge(Code: '400 Bad Request', Cont: { Resp: "La request e' vuota" }).to_json)
        false
      end

      # Check if request is using HTTP protocol and respond if so
      if %w[GET POST HEAD PUT].include?(input1.split(' ')[0])
        LOG.warn("#{@id}: Bad request: il protocollo HTTP non e' supportato")
        @socket.puts(@headers.merge(Code: '400 Bad Request', Cont: {Resp: 'Impossibile servire attraverso HTTP'}).to_json)
        false
      end

      # If request is ok return true
      true
    end
  end
end
