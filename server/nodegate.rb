module Node
  class Gate
    def initialize(server)
      @server = server

      Thread.new do
        while true
          Thread.fork(@server.accept) do |client|
            begin
              socket = TCPSocket.new "localhost", 2556
              begin
                while true
                  socket.puts(client.gets)
                  STDOUT.puts("------------------client to server")
                  client.puts(socket.gets)
                  STDOUT.puts("------------------server to client")
                end
              rescue Errno::ECONNRESET
                # Nothing
              end
            rescue
              AP.log("Errore NodeGate", nil, "error")
              AP.log($!, nil, "backtrace")
              AP.log($!.backtrace, nil, "backtrace")
            end
          end
        end
      end
    end
  end
end