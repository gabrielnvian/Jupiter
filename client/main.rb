require "json"
require "socket"

system("cls")

require_relative "core.rb"
require_relative "auth.rb"
require_relative "filebase.rb"

# $host = "localhost"
# $host = "192.168.1.130"
$host = "gabrielvian.com"
$port = 2556

$version = "3.3"

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
      when "host"
        AP.changehost(cmd.split(" ")[1])
      when "port"
        AP.changeport(cmd.split(" ")[1])
      when "exit"
        if $server
          AP.output(COLOR::YELLOW+"\nDisconnessione automatica..."+COLOR::CLEAR)
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
        when "list"
          FileBase.list()
        when "query", "search"
          FileBase.query(cmd.split(" ")[2])
        else
          AP.output(COLOR::RED+"FileBase: comando non riconosciuto"+COLOR::CLEAR)
        end
      
      when "auth"
        case cmd.split(" ")[1]
        when "list"
          Auth.list()
        else
          AP.output(COLOR::RED+"Auth: comando non riconosciuto"+COLOR::CLEAR)
        end
      
      else
        AP.output(COLOR::RED+"Comando non riconosciuto"+COLOR::CLEAR)
      end
    rescue Interrupt
      AP.output(COLOR::GREEN+"\nComando annullato"+COLOR::CLEAR)
    end
  end
rescue Interrupt
  if $server
    AP.output(COLOR::YELLOW+"\nDisconnessione automatica..."+COLOR::CLEAR)
    Auth.logout()
  end
end