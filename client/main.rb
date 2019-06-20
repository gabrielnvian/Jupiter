require 'json'
require 'socket'
require 'terminal-table'
require 'net/ftp'

system('cls')

require_relative 'core.rb'
require_relative 'auth.rb'
require_relative 'filebase.rb'
require_relative 'colors.rb'

$host = 'localhost'
# host = "192.168.1.130"
# host = "gabrielvian.com"
$port = 2556

VERSION = '3.4'.freeze

$creds = [nil, 0]
$server = nil # JClient.connect(host, port)


begin
  loop do
    cmd = JClient.input
    begin
      case cmd.split(' ')[0]
      # CONNECTION -------------------------------------------------------------
      when 'connect'
        $server = JClient.connect
      when 'host'
        JClient.chghost(cmd.split(' ')[1])
      when 'port'
        JClient.chgport(cmd.split(' ')[1])
      when 'exit'
        if $server
          JClient.output(COLOR::YELLOW + "\nDisconnessione automatica..." + COLOR::CLEAR)
          AuthClient.logout
        end

      when 'ping'
        JClient.ping

      when 'login'
        AuthClient.login(cmd.split(' ')[1])

      when 'logout', 'disconnect'
        AuthClient.logout

      # USER MGMT --------------------------------------------------------------
      when 'adduser'
        AuthClient.adduser(cmd.split(' ')[1], cmd.split(' ')[2], cmd.split(' ')[3])

      when 'deluser'
        AuthClient.deluser(cmd.split(' ')[1], cmd.split(' ')[2])

      when 'changepwd'
        AuthClient.changepwd(cmd.split(' ')[1], cmd.split(' ')[2], cmd.split(' ')[3])

      # FILEBASE ---------------------------------------------------------------
      when 'filebase', 'file'
        case cmd.split(' ')[1]
        when 'addfile', 'add'
          FileBase.add(cmd.split(' ')[2], cmd.split(' ')[3], cmd.split(' ')[4], cmd.split(' ')[5..-1])
        when 'download', 'down'
          FileBase.download(cmd.split(' ')[2])
        when 'list'
          FileBase.list
        when 'query', 'search'
          FileBase.query(cmd.split(' ')[2])
        else
          JClient.output(COLOR::RED + 'FileBase: comando non riconosciuto' + COLOR::CLEAR)
        end

      when 'auth'
        case cmd.split(' ')[1]
        when 'list'
          AuthClient.list
        else
          JClient.output(COLOR::RED + 'Auth: comando non riconosciuto' + COLOR::CLEAR)
        end

      else
        JClient.output(COLOR::RED + 'Comando non riconosciuto' + COLOR::CLEAR)
      end
    rescue Interrupt
      JClient.output(COLOR::GREEN + "\nComando annullato" + COLOR::CLEAR)
    end
  end
rescue Interrupt
  if server
    JClient.output(COLOR::YELLOW + "\nDisconnessione automatica..." + COLOR::CLEAR)
    AuthClient.logout
  end
end
