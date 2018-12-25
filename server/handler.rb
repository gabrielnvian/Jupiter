module AP
  class Handler
    def initialize(socket, id)
      @socket = socket
      @id = id
      @agents = AP::getagents(@id)
      @headers = {
        "AP"=>"3.0",
        "APS"=>nil,
        "Code"=>"200 OK",
        "Content"=>{}
      }
      AP::log("Handler created", @id)
    end

    def run()
      begin
        agent = Fulfillment.new
        request = Hash.new
        request["Connection"] = "keep-alive"

        while request["Connection"] == "keep-alive"
          input = @socket.gets
          AP::log(input, @id, "rawin")

          if input.nil? # Send flow to log:"socket closed" if buffer is nil
            AP::log("Bad request: request is empty", @id, "warning")
            @socket.puts(@headers.merge({"Code"=>"400 Bad Request", "Content"=>{"Response"=>"Request is empty"}}).to_json)
            return true
          end

          if input.split(" ")[0] == "GET" || input.split(" ")[0] == "POST" || input.split(" ")[0] == "HEAD"
            AP::log("Bad request: cannot handle HTTP requests", @id, "warning")
            @socket.puts(@headers.merge({"Code"=>"400 Bad Request", "Content"=>{"Response"=>"Cannot handle HTTP requests"}}).to_json)
            return true
          end
          
          request = JSON.parse(input)

          agent.history.push([request]) # Save in history the request

          if AP::agentcommand?(@agents, request["User-Agent"].downcase, request["Content"]["Request"])
            AP::log("Running agent \"#{request["User-Agent"]}\"", @id)
            out = agent.public_send(request["User-Agent"].downcase, request)

            AP::log("Responding to request...", @id)
            out[1] ? response = @headers.merge(out[0]).to_json : response = out[0].to_json # If required merge request with headers
            @socket.puts(response)
            AP::log(response, @id, "rawout")
            agent.history[-1].push(response) # Save in history the response
          else
            AP::log("Bad request: Agent or command not exists", @id, "warning")
            @socket.puts(@headers.merge({"Code"=>"404 Not Found", "Content"=>{"Response"=>"Agent or command does not exists"}}).to_json)
          end
        end
      rescue
        # put internal server error
        AP::log("Internal server error", @id, "error")
        AP::log($!, @id, "backtrace")
        AP::log($!.backtrace, @id, "backtrace")
        
        error = @headers.merge({"Code"=>"500 Internal Server Error"}).to_json
        @socket.puts(error)
        AP::log(error, @id, "rawout")
      end
    end
  end
end
