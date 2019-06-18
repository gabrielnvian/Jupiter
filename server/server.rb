# frozen_string_literal: true

require 'socket'
require 'securerandom'
require 'json'
require 'fileutils'
require 'digest'
require 'logger'

load 'config.rb'

# Load external libraries
require_relative 'handler.rb'
require_relative 'fulfillment.rb'
require_relative 'core.rb'

# Initialize logger
LOG = Logger.new(STDOUT, datetime_format: '%d/%m %H:%M:%S')
LOG.level = Logger::DEBUG

# Check if another instance is running using the same folder, if so, exit
if File.exist?('.running')
  if ARGV[0] == 'force'
    LOG.warn("L'avvio del server e' stato forzato")
  elsif LOG.level.zero?
    LOG.warn("Avvio del server in modalita' di debug")
  else
    LOG.fatal("Un'altra istanza e' in esecuzione utilizzando la stessa cartella (.running)")
    exit!
  end
end

# Check if instance has admin privileges, exit if not
system('reg query "HKU\S-1-5-19" > nul 2> nul')
if `echo %errorlevel%`.chomp != '0'
  LOG.fatal('Sono richiesti privilegi di amministratore per avviare il server')
  exit!
end

# Create required agents folder
File.exist?('agents') ? nil : FileUtils.mkdir_p('agents')

# Create .running file indicating an instance is using the folder
File.open('.running', 'w') do |f1|
  f1.puts ''
end

# Initialize TCP server
server = TCPServer.new CONFIG[:address], CONFIG[:port]
LOG.info("Server in ascolto su #{CONFIG[:address]}:#{CONFIG[:port]}")


# Get tasks to launch
agents = Jupiter.getagents
LOG.info('Lancio script di avvio in corso...')
ran_tasks = 0
# Run agents tasks
agents.each do |agent|
  agent[:startupTasks].each do |task|
    ran_tasks += 1
    OnServerStartup.public_send(task)
  end
end
LOG.info("Lanciati #{ran_tasks} script di avvio")


open_sessions = 0 # Counter for open sessions

# Waiting for connections
LOG.info('In attesa di connessioni...')
system("title Jupiter Server #{CONFIG['version']} (#{open_sessions})")
while true
  begin
    Thread.fork(server.accept) do |socket|
      begin
        open_sessions += 1
        system("title Jupiter Server #{CONFIG['version']} (#{open_sessions})")
        id = SecureRandom.hex(2)
        LOG.info("#{id}: Nuova connessione")
        handler = Jupiter::Handler.new(socket, id, agents)
        handler.run
      rescue => e
        LOG.error('Errore nel creare il socket')
        LOG.debug(e)
        LOG.debug(e.backtrace)
        @socket.puts(@headers.merge(Code: '500 Internal Server Error', Content: { Response: 'Errore interno del server' }).to_json)
      end
      open_sessions -= 1
      system("title Jupiter Server #{CONFIG['version']} (#{open_sessions})")
      LOG.info("Connessione chiusa")
    end
  rescue Interrupt
    FileUtils.rm_rf('.running')
    LOG.info('Server fermato')
    LOG.close
    exit!
  end
end
