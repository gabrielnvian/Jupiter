require "openssl"
require "json"
require "socket"

system("cls")

headers = {
  "AP"=>"3.0",
  "APS"=>false,
  "User-Agent"=>"helloworld",
  "Connection"=>"keep-alive",
  "Content"=>{}
}

s = TCPSocket.new "localhost", 2556

for i in 0..5
	gets
	puts ">>> " + headers.merge({"Connection"=>"keep-alive", "Content"=>{"Request"=>"HelloWorld"}}).to_json
  s.puts headers.merge({"Connection"=>"keep-alive", "Content"=>{"Request"=>"HelloWorld"}}).to_json
  puts "<<< " + JSON.parse(s.gets).to_json
end

s.puts headers.merge({"User-Agent"=>"gethistory", "Connection"=>"keep-alive", "Content"=>{"Request"=>"GetHistory"}}).to_json
puts JSON.parse(s.gets).to_s.length
