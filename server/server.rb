require "socket"
require "securerandom"
require "json"
require "fileutils"

load "config.rb"

require_relative "handler.rb"
require_relative "fulfillment.rb"
require_relative "debug.rb"
require_relative "core.rb"
require_relative "auth.rb"


File.exists?("agents") ? nil : FileUtils.mkdir_p("agents")
File.exists?("auth") ? nil : FileUtils.mkdir_p("auth")

server = TCPServer.new $config[:address], $config[:port]

system("cls")
AP.log("Server bound to #{$config[:address]}:#{$config[:port]}", nil, "server")
$launchdate = Time.new.strftime("%d.%m.%Y-%H.%M.%S")


# Tasks on server startup
agents = AP.getagents(nil, true)

AP.log("Running startup tasks...", nil, "server")
ranTasks = 0
agents.each do |agent|
  agent[:startupTasks].each do |task|
    ranTasks += 1
    OnServerStartup.public_send(task)
  end
end
AP.log("Ran #{ranTasks} startup tasks", nil, "server")


AP.log("Listening for connections...", nil, "server")
while true
  begin
    Thread.fork(server.accept) do |socket|
      begin
        id = SecureRandom.hex(2)
        AP.log("Socket opened", id, "socket")
        handler = AP::Handler.new(socket, id)
        handler.run()
      rescue
        AP.log("Error while creating socket", id, "error")
        AP.log($!, id, "backtrace")
        AP.log($!.backtrace, id, "backtrace")
        @socket.puts(@headers.merge({"Code"=>"500 Internal Server Error"}).to_json)
      end
      AP.log("Socket closed", id, "socket")
    end
  rescue Interrupt
    AP.log("Server stopped", nil, "server")
    exit!
  end
end
