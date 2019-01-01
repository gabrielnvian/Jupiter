require "openssl"
require "json"
require "socket"

system("cls")

headers = {
  :AP=>"3.0",
  :APS=>false,
  :User_Agent=>"filebase",
  :Connection=>"keep-alive",
  :Content=>{}
}

s = TCPSocket.new "localhost", 2556

s.puts ["root", "ciaociao"].to_json
puts JSON.parse(s.gets)

s.puts headers.merge({:Content=>{:Request=>"INIT", :Name=>"cat", :Ext=>"jpg", :Date=>Time.new.to_i, :Keywords=>["gatto", "micio"]}}).to_json
puts response = JSON.parse(s.gets)
puts "##### #{response["Content"]["Ticket"]} #####"

puts "Move file..."
gets

s.puts headers.merge({:Connection=>"close", :Content=>{:Request=>"SUBMIT", :Ticket=>response["Content"]["Ticket"]}}).to_json
puts JSON.parse(s.gets)
