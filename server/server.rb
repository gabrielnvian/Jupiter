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


system("cls")

if File.exist?(".running") && ARGV[0] != "force"
  AP.log("Un'altra istanza e' in esecuzione utilizzando la stessa cartella (.running)", nil, "error")
  exit!
end

system('reg query "HKU\S-1-5-19" > nul 2> nul')
if `echo %errorlevel%`.chomp != "0"
  AP.log("Sono richiesti privilegi da amministratore per avviare il server", nil, "error")
  exit!
end

for lib in Dir.entries("lib")[2..-1]
  require_relative "lib/#{lib}"
end

File.exist?("agents") ? nil : FileUtils.mkdir_p("agents")

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

ARGV[0] == "force" ? AP.log("L'avvio del server e' stato forzato", nil, "warning") : nil
AP.log("Server in ascolto su #{$config[:address]}:#{$config[:port]}", nil, "server")


# Tasks on server startup
agents, $loaded_libs = AP.getagents()

AP.log("Lancio script di avvio in corso...", nil, "server")
ranTasks = 0
agents.each do |agent|
  agent[:startupTasks].each do |task|
    ranTasks += 1
    OnServerStartup.public_send(task)
  end
end
AP.log("Lanciati #{ranTasks} script di avvio", nil, "server")


AP.log("In attesa di connessioni...", nil, "server")
$open_sessions = 0
system("title AlphaProtocol Server #{$config["version"]} (#{$open_sessions})")
while true
  begin
    Thread.fork(server.accept) do |socket|
      begin
        $open_sessions += 1
        system("title AlphaProtocol Server #{$config["version"]} (#{$open_sessions})")
        id = SecureRandom.hex(2)
        AP.log("Socket aperto", id, "socket")
        handler = AP::Handler.new(socket, id, agents)
        handler.run()
      rescue
        AP.log("Errore nel creare il socket", id, "error")
        AP.log($!, id, "backtrace")
        AP.log($!.backtrace, id, "backtrace")
        @socket.puts(@headers.merge({:Code=>"500 Internal Server Error", :Content=>{:Response=>"Errore interno del server"}}).to_json)
      end
      $open_sessions -= 1
      system("title AlphaProtocol Server #{$config["version"]} (#{$open_sessions})")
      AP.log("Socket chiuso", id, "socket")
    end
  rescue Interrupt
    FileUtils.rm_rf(".running")
    AP.log("Server offline", nil, "server")
    exit!
  end
end
