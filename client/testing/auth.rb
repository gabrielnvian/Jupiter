require "json"
require "socket"

system("cls")

headers = {
  :AP=>"3.0",
  :APS=>false,
  :User_Agent=>"auth",
  :Connection=>"keep-alive",
  :Content=>{}
}

s = TCPSocket.new "localhost", 2556

sleep(2)

# LOGIN TEST
request = ["root", "ciaociao"].to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts
sleep(2)

# ADDUSER TEST
request = headers.merge({:Content=>{:Request=>"ADDUSER", :Username=>"ImGek", :PWD=>"megadirettore", :Power=>2}}).to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts
sleep(2)

# ADDUSER TEST 2
request = headers.merge({:Content=>{:Request=>"ADDUSER", :Username=>"utente1", :PWD=>"minchiasoft", :Power=>2}}).to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts
sleep(2)

# CHANGEPWD PW TEST
request = headers.merge({:Content=>{:Request=>"CHANGEPWD", :Username=>"ImGek", :PWD=>"password1"}}).to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts
sleep(2)

# CHANGEPWD OLD TEST
request = headers.merge({:Content=>{:Request=>"CHANGEPWD", :Username=>"ImGek", :PWD=>"password2", :oldPWD=>"password1"}}).to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts
sleep(2)

# DELUSER PW TEST
request = headers.merge({:Content=>{:Request=>"DELUSER", :Username=>"ImGek"}}).to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts
sleep(2)

# DELUSER OLD TEST
request = headers.merge({:Content=>{:Request=>"DELUSER", :Username=>"utente1", :PWD=>"minchiasoft"}}).to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts
sleep(2)



# HELLOWORLD
request = headers.merge({:User_Agent=>"HelloWorld", :Connection=>"close", :Content=>{:Request=>"HelloWorld"}}).to_json
puts ">>> " + request
s.puts request
puts "<<< " + JSON.parse(s.gets).to_json
puts

s.close