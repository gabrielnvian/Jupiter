module Jupiter
  class Handler
    def initialize(socket, id, agents)
      @sc = socket  # socket
      @id = id      # id
      @ag = agents  # agents
      @hd = {       # headers
        J: CONFIG[:version],
        JS: nil,
        Code: '200 OK',
        Cont: {}
      }
      @us = [nil, 0] # userinfo
      LOG.debug("#{@id}: #{lang(LANG::HANDLER_CREATED)}")
    end

    def run
      begin
        agent = Fulfillment.new
        request = {}
        request[:Connection] = 'keep-alive'

        while request[:Connection] == 'keep-alive'
          input = @sc.gets
          tolog = input

          # Check if request is empty or not supported and respond
          return false unless check_request(input)

          input = JSON.parse(input)

          # BEGIN LOGIN BLOCK --------------------------------------------------
          # If request contains (possibly) login credentials &&
          # user is not logged in
          if input.is_a?(Array) && @us[0].nil?
            output = Auth.login(input[0], input[1])
            if output
              @us = [input[0], output]
              LOG.debug("#{@id}: #{lang(LANG::LOGIN_OK)} (#{input[0]})")
              @sc.puts(@hd.merge(Code: '200 OK', Cont: { Resp: lang(LANG::LOGIN_AS, @us[0]), Power: @us[1] }).to_json)
            else
              LOG.warn("#{@id}: #{lang(LANG::BAD_LOGIN)} (#{input[0]})")
              @sc.puts(@hd.merge(Code: '401 Unauthorized', Cont: { Resp: lang(LANG::BAD_LOGIN) }).to_json)
            end
          # If request contains (possibly) login credentials but
          # user is already logged in
          elsif input.is_a?(Array) && !@us[0].nil?
            LOG.debug("#{@id}: #{lang(LANG::ALREADY_LOGGED_IN)} (#{@us[0]})")
            @sc.puts(@hd.merge(Code: '400 Bad Request', Cont: { Resp: "#{lang(LANG::ALREADY_LOGGED_IN)} (#{@us[0]})" }).to_json)
          # END LOGIN BLOCK ----------------------------------------------------
          else
            LOG.debug("#{@id}: #{tolog}")
            # Parse request
            request = Jupiter.jsontosym(input)
            # Save request in connection's history
            agent.history.push([request])

            # If command is allowed for the requested agent --> allowed
            Jupiter.agentcommand?(@ag, request[:Agent], request[:Cont][:Req]) ? allowed(agent, request) : not_found(agent)
          end
        end
      rescue => e
        # Raise code 500 (Internal Server Error)
        LOG.error("#{@id}: #{lang(LANG::CODE500)}")
        LOG.debug("#{@id}: #{e}")
        LOG.debug("#{@id}: #{e.backtrace}")

        error = @hd.merge(Code: '500 Internal Server Error', Cont: { Resp: lang(LANG::CODE500) }).to_json
        @sc.puts(error)
        LOG.debug("#{@id}: #{error}")
      end
    end

    def check_request(input1)
      if input1.nil? # Send flow to log:"socket closed" if buffer is nil
        LOG.warn("#{@id}: Bad request: #{lang(LANG::REQUEST_EMPTY)}")
        @sc.puts(@hd.merge(Code: '400 Bad Request', Cont: { Resp: lang(LANG::REQUEST_EMPTY).capitalize }).to_json)
        false
      end

      # Check if request is using HTTP protocol and respond if so
      if %w[GET POST HEAD PUT].include?(input1.split(' ')[0])
        LOG.warn("#{@id}: Bad request: #{lang(LANG::NO_HTTP)}")
        @sc.puts(@hd.merge(Code: '400 Bad Request', Cont: { Resp: lang(LANG::NO_HTTP).capitalize }).to_json)
        false
      end

      # If request is ok return true
      true
    end

    def allowed(agent, request)
      req_power = Jupiter.getagentminpower(@ag, request[:Agent], request[:Cont][:Req])

      # If user power >= required power --> launch
      @us[1] >= req_power ? launch(agent, request) : unauthorized(agent, req_power)
    end

    def not_found(agent)
      response = @hd.merge(Code: '404 Not Found', Cont: { Resp: lang(LANG::NO_AGENT_OR_CMD) }).to_json
      LOG.warn("#{@id}: #{lang(LANG::NO_AGENT_OR_CMD)}")
      LOG.debug("#{@id}: #{response}")
      agent.history[-1].push(response) # Save response in history
      @sc.puts(response)
    end

    def launch(agent, request)
      LOG.debug("#{@id}: #{lang(LANG::LAUNCH_AGENT, request[:Agent])}")
      out = agent.public_send(request[:Agent].downcase, request, @us)

      LOG.debug("#{@id}: #{lang(LANG::RESPONDING_REQUEST)}")
      # If out[1] is true, merge output into headers
      response = out[1] ? @hd.merge(out[0]).to_json : out[0].to_json

      # Send response to client
      @sc.puts(response)
      LOG.debug("#{@id}: #{response}")

      # Save response from client in history
      agent.history[-1].push(response)
    end

    def unauthorized(agent, req_power)
      response = @hd.merge(Code: '401 Unauthorized', Cont: { Resp: lang(LANG::PW_LVL_NEEDED, req_power, @us[1]) }).to_json
      LOG.warn("#{@id}: #{LANG::AUTHORIZATION_ERROR}: #{lang(LANG::PW_LVL_NEEDED, req_power, @us[1])}")
      LOG.debug("#{@id}: #{response}")
      agent.history[-1].push(response) # Save response in history
      @sc.puts(response)
    end
  end
end
