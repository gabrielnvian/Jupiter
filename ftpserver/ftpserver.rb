require "socket"
require "logger"
require "digest"

require_relative "driver.rb"

load "config.rb"


LOG = Logger.new(STDOUT)

server = TCPServer.new $ftpconfig[:address], $ftpconfig[:port]
LOG.debug("In attesa di connessioni...")

$open_sessions = 0
while true
  begin
    Thread.fork(server.accept) do |socket|
      begin
        $open_sessions += 1
        driver = FTPDriver.new(socket)
        driver.run()
      rescue
        LOG.fatal($!)
        LOG.fatal($!.backtrace)
      end
      $open_sessions -= 1
    end
  rescue
    LOG.fatal($!)
    LOG.fatal($!.backtrace)
  end
end