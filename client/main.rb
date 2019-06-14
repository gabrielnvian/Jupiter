require 'json'
require 'socket'

system('cls')

require_relative 'core.rb'
require_relative 'auth.rb'
require_relative 'filebase.rb'
require_relative 'colors.rb'

host = 'localhost'
# host = "192.168.1.130"
# host = "gabrielvian.com"
port = 2556

VERSION = '3.4'

creds = [nil, 0]
server = nil# JClient.connect(host, port)


begin
  loop do
    cmd = JClient.input(server, creds)
    begin
      case cmd.split(' ')[0]
      # CONNECTION -------------------------------------------------------------
      when 'connect'
        server = JClient.connect(host, port)
      when 'host'
        host = JClient.chghost(server, cmd.split(' ')[1]) ? cmd.split(' ')[1] : host
      when 'port'
        port = JClient.chgport(server, cmd.split(' ')[1]) ? cmd.split(' ')[1].to_i : port
      when 'exit'
        if server
          JClient.output(server, creds, COLOR::YELLOW + "\nDisconnessione automatica..." + COLOR::CLEAR)
          AuthClient.logout(server)
        end

      when 'ping'
        JClient.ping

      when 'login'
        newcreds = AuthClient.login(server, creds, cmd.split(' ')[1])
        creds = newcreds if newcreds

      when 'logout', 'disconnect'
        AuthClient.logout(server)
      # USER MGM ---------------------------------------------------------------

      when 'adduser'
        AuthClient.adduser(server, cmd.split(' ')[1], cmd.split(' ')[2], cmd.split(' ')[3])

      when 'deluser'
        AuthClient.deluser(server, cmd.split(' ')[1], cmd.split(' ')[2])

      when 'changepwd'
        AuthClient.changepwd(cmd.split(' ')[1], cmd.split(' ')[2], cmd.split(' ')[3])
      # FILEBASE ---------------------------------------------------------------

      when 'filebase', 'file'
        case cmd.split(' ')[1]
        when 'addfile', 'add'
          FileBase.addfile(cmd.split(' ')[2])
        when 'download', 'down'
          FileBase.download(cmd.split(' ')[2])
        when 'list'
          FileBase.list
        when 'query', 'search'
          FileBase.query(cmd.split(' ')[2])
        else
          JClient.output(server, creds, COLOR::RED + 'FileBase: comando non riconosciuto' + COLOR::CLEAR)
        end

      when 'auth'
        case cmd.split(' ')[1]
        when 'list'
          AuthClient.list
        else
          JClient.output(server, creds, COLOR::RED + 'Auth: comando non riconosciuto' + COLOR::CLEAR)
        end

      else
        JClient.output(server, creds, COLOR::RED + 'Comando non riconosciuto' + COLOR::CLEAR)
      end
    rescue Interrupt
      JClient.output(server, creds, COLOR::GREEN + "\nComando annullato" + COLOR::CLEAR)
    end
  end
rescue Interrupt
  if server
    JClient.output(server, creds, COLOR::YELLOW + "\nDisconnessione automatica..." + COLOR::CLEAR)
    AuthClient.logout(server)
  end
end
