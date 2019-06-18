# frozen_string_literal: true

require 'socket'
require 'securerandom'
require 'json'
require 'fileutils'
require 'digest'
require 'logger'

load 'config.rb'

# Load external libraries
require_relative 'lang.rb'
require_relative 'handler.rb'
require_relative 'fulfillment.rb'
require_relative 'core.rb'

# Initialize logger
LOG = Logger.new(STDOUT, datetime_format: '%d/%m %H:%M:%S')
LOG.level = Logger::DEBUG

# Check if another instance is running using the same folder, if so, exit
if File.exist?('.running')
  if ARGV[0] == 'force'
    LOG.warn(lang(LANG::SERVER_START_FORCED))
  elsif LOG.level.zero?
    LOG.warn(lang(LANG::DEBUG_MODE_ON))
  else
    LOG.fatal(lang(LANG::FOLDER_ALREADY_IN_USE))
    exit!
  end
end

# Check if instance has admin privileges, exit if not
system('reg query "HKU\S-1-5-19" > nul 2> nul')
if `echo %errorlevel%`.chomp != '0'
  LOG.fatal(lang(LANG::ADMIN_REQUIRED))
  exit!
end

# Create required agents folder
FileUtils.mkdir_p('agents') unless File.exist?('agents')

# Create .running file indicating an instance is using the folder
File.open('.running', 'w') do |f1|
  f1.puts ''
end

# Initialize TCP server
server = TCPServer.new CONFIG[:address], CONFIG[:port]
LOG.info(lang(LANG::SERVER_LISTENING, CONFIG[:address], CONFIG[:port]))


# Get tasks to launch
agents = Jupiter.getagents
LOG.info(lang(LANG::LAUNCH_START_SCRIPTS))
ran_tasks = 0
# Run agents tasks
agents.each do |agent|
  agent[:startupTasks].each do |task|
    ran_tasks += 1
    OnServerStartup.public_send(task)
  end
end
LOG.info(lang(LANG::LAUNCHED_SCRIPTS, ran_tasks))


open_sessions = 0 # Counter for open sessions

# Waiting for connections
LOG.info(lang(LANG::WAITING_CONNECTIONS))
system("title Jupiter Server #{CONFIG['version']} (#{open_sessions})")
while true
  begin
    Thread.fork(server.accept) do |socket|
      begin
        open_sessions += 1
        system("title Jupiter Server #{CONFIG['version']} (#{open_sessions})")
        id = SecureRandom.hex(2)
        LOG.info("#{id}: #{lang(LANG::NEW_CONNECTION)}")
        handler = Jupiter::Handler.new(socket, id, agents)
        handler.run
      rescue => e
        LOG.error(lang(LANG::ERROR_CREATE_SOCKET))
        LOG.debug(e)
        LOG.debug(e.backtrace)
        @socket.puts(@headers.merge(Code: '500 Internal Server Error', Content: { Response: lang(LANG::CODE500) }).to_json)
      end
      open_sessions -= 1
      system("title Jupiter Server #{CONFIG['version']} (#{open_sessions})")
      LOG.info(lang(LANG::CLOSED_CONNECTION))
    end
  rescue Interrupt
    FileUtils.rm_rf('.running')
    LOG.info(lang(LANG::SERVER_STOPPED))
    LOG.close
    exit!
  end
end
