require "openssl"
require "json"
require "socket"

system("cls")

headers = {
  :AP=>"3.0",
  :APS=>false,
  :User_Agent=>"helloworld",
  :Connection=>"keep-alive",
  :Content=>{}
}

s = TCPSocket.new "localhost", 2556

hashin = "1f6fda80636fb763bef93193444b3f36"
req = headers.merge({:Connection=>"close", :Content=>{:Request=>"CRACK", :Hash=>hashin, :Hashtype=>"md5"}}).to_json
puts ">>> " + req
s.puts req
puts "<<< " + JSON.parse(s.gets).to_json
