require "openssl"
require "json"
require "socket"

system("cls")

headers = {
  "AP"=>"2.0",
  "APS"=>false,
  "User-Agent"=>"helloworld",
  "Connection"=>"keep-alive",
  "Content"=>{}
}

s = TCPSocket.new "localhost", 2556

s.puts headers.merge({"User-Agent"=>"filebase", "Connection"=>"keep-alive", "Content"=>{"Request"=>"COMM", "Name"=>"cat", "Ext"=>"jpg", "Date"=>Time.new.to_i, "Keywords"=>["gatto", "micio"]}}).to_json
puts JSON.parse(s.gets)

puts "Move file..."
gets

s.puts headers.merge({"User-Agent"=>"filebase", "Connection"=>"keep-alive", "Content"=>{"Request"=>"SUBM", "Ticket"=>"8668"}}).to_json
puts JSON.parse(s.gets)
