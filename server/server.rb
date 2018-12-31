require "socket"
require "securerandom"
require "json"
require "fileutils"
require "digest"

load "config.rb"

require_relative "handler.rb"
require_relative "fulfillment.rb"
require_relative "debug.rb"
require_relative "core.rb"
require_relative "auth.rb"


system("cls")

if File.exist?(".running") && ARGV[0] != "force"
  AP.log("Another server is already running using this folder (.running)", nil, "error")
  exit!
end

File.exist?("agents") ? nil : FileUtils.mkdir_p("agents")
File.exist?("auth") ? nil : FileUtils.mkdir_p("auth")

File.exist?(".last.dll") ? lastlaunch = eval(File.open(".last.dll").readlines.join("")) : lastlaunch = "unknown#{rand(1111..9999)}"
File.exist?("logs/latest.log") ? FileUtils.mv("logs/latest.log", "logs/#{lastlaunch}.log") : nil

$launchdate = Time.new.strftime("%d.%m.%Y-%H.%M")

File.open(".last.dll", "w") do |f1|
  f1.puts "'#{$launchdate}'"
end

File.open(".running", "w") do |f1|
  f1.puts ""
end

server = TCPServer.new $config[:address], $config[:port]

ARGV[0] == "force" ? AP.log("Forced server start", nil, "warning") : nil
AP.log("Server bound to #{$config[:address]}:#{$config[:port]}", nil, "server")


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
$open_sessions = 0
system("title AlphaProtocol Server (#{$open_sessions})")
while true
  begin
    Thread.fork(server.accept) do |socket|
      begin
        $open_sessions += 1
        system("title AlphaProtocol Server (#{$open_sessions})")
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
      $open_sessions -= 1
      system("title AlphaProtocol Server (#{$open_sessions})")
      AP.log("Socket closed", id, "socket")
    end
  rescue Interrupt
    FileUtils.rm_rf(".running")
    AP.log("Server stopped", nil, "server")
    exit!
  end
end
