require "openssl"
require "json"
require "socket"

system("cls")

headers = {
  "AP"=>"3.0",
  "APS"=>false,
  "User-Agent"=>"tohash",
  "Connection"=>"keep-alive",
  "Content"=>{}
}

s = TCPSocket.new "localhost", 2556

string = "ciaom"
req = headers.merge({"Connection"=>"close", "Content"=>{"Request"=>"HASH", "String"=>string, "Hashtype"=>"md5"}}).to_json
puts ">>> " + req
s.puts req
puts "<<< " + JSON.parse(s.gets).to_json
