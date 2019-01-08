require "json"
require "socket"

system("cls")

require_relative "core.rb"
require_relative "auth.rb"
require_relative "filebase.rb"

HOST = "localhost"
#HOST = "192.168.1.130"
#HOST = "138.201.65.198"
PORT = 2556

$credentials = [nil, 0]
$server = nil#AP.connect()


begin
  while true
    cmd = AP.input()
    begin
      case cmd.split(" ")[0]
      # CONNECTION ---------------------------------------------------------------
      when "connect"
        $server = AP.connect()
      when "exit"
        if $server
          puts "\nDisconnessione automatica..."
          Auth.logout()
        end

      when "login"
        Auth.login(cmd.split(" ")[1])
      
      when "logout", "disconnect"
        Auth.logout()
      # USER MGM -----------------------------------------------------------------
      
      when "adduser"
        Auth.adduser(cmd.split(" ")[1], cmd.split(" ")[2], cmd.split(" ")[3])
      
      when "deluser"
        Auth.deluser(cmd.split(" ")[1], cmd.split(" ")[2])
      
      when "changepwd"
        Auth.changepwd(cmd.split(" ")[1], cmd.split(" ")[2], cmd.split(" ")[3])
      # FILEBASE ------------------------------------------------------------------
      
      when "filebase"
        case cmd.split(" ")[1]
        when "addfile", "add"
          FileBase.addfile(cmd.split(" ")[2])
        else
          AP.output("FileBase: comando non riconosciuto")
        end
      
      when "auth"
        case cmd.split(" ")[1]
        when "list"
          Auth.list()
        else
          AP.output("Auth: comando non riconosciuto")
        end
      
      else
        AP.output("Comando non riconosciuto")
      end
    rescue Interrupt
      puts "\nComando annullato"
    end
  end
rescue Interrupt
  if $server
    puts "\nDisconnessione automatica..."
    Auth.logout()
  end
end