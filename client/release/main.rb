require "json"
require "socket"

require_relative "core.rb"
require_relative "auth.rb"

HOST = "localhost"
#HOST = "192.168.1.130"
#HOST = "138.201.65.198"
PORT = 2556

$credentials = [nil, 0]
$server = nil#AP.connect()

system("cls")

begin
  while true
    cmd = AP.input()

    case cmd.split(" ")[0]
    when "connect"
      $server = AP.connect()
    when "login"
      Auth.login(cmd.split(" ")[1], cmd.split(" ")[2])
    when "logout", "disconnect"
      Auth.logout()
    when "adduser"
      Auth.adduser(cmd.split(" ")[1], cmd.split(" ")[2], cmd.split(" ")[3])
    when "deluser"
      Auth.deluser()
    when "changepwd"
      Auth.changepwd()
    else
      AP.output("Comando non riconosciuto")
    end
  end
rescue Interrupt
  if $server
    $server.puts $headers.merge({:Connection=>"close", :Content=>{:Request=>"HelloWorld"}}).to_json
  end
end