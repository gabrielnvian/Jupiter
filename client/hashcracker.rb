require "openssl"
require "json"
require "socket"

system("cls")

headers = {
  "AP"=>"3.0",
  "APS"=>false,
  "User-Agent"=>"hashcracker",
  "Connection"=>"keep-alive",
  "Content"=>{}
}

s = TCPSocket.new "localhost", 2556

hashin = "53531f81f28211786bad113dd41a9a96"
req = headers.merge({"Connection"=>"close", "Content"=>{"Request"=>"CRACK", "Hash"=>hashin, "Hashtype"=>"md5"}}).to_json
puts ">>> " + req
s.puts req
puts "<<< " + JSON.parse(s.gets).to_json
