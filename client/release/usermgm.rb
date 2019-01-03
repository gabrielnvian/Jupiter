require "json"
require "socket"


module USERMGM
  def USERMGM::login(user, pwd)
    if user.nil?
      user = AP.input("username")
    end

    if pwd.nil?
      pwd = AP.input("password")
    end

    $server ? nil : $server = AP.connect()

    $server.puts [user, pwd].to_json
    response = AP.jsontosym(JSON.parse($server.gets))
    puts response[:Response]
    return response[:Code] == CODE_OK
  end
end





# request = ["root", "ciaociao"].to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts


# request = headers.merge({:Content=>{:Request=>"ADDUSER", :Username=>"ImGek", :PWD=>"megadirettore", :Power=>2}}).to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts


# request = headers.merge({:Content=>{:Request=>"ADDUSER", :Username=>"utente1", :PWD=>"minchiasoft", :Power=>2}}).to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts


# request = headers.merge({:Content=>{:Request=>"CHANGEPWD", :Username=>"ImGek", :PWD=>"password1"}}).to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts


# request = headers.merge({:Content=>{:Request=>"CHANGEPWD", :Username=>"ImGek", :PWD=>"password2", :oldPWD=>"password1"}}).to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts


# request = headers.merge({:Content=>{:Request=>"DELUSER", :Username=>"ImGek"}}).to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts


# request = headers.merge({:Content=>{:Request=>"DELUSER", :Username=>"utente1", :PWD=>"minchiasoft"}}).to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts




# request = headers.merge({:User_Agent=>"HelloWorld", :Connection=>"close", :Content=>{:Request=>"HelloWorld"}}).to_json
# puts ">>> " + request
# s.puts request
# puts "<<< " + JSON.parse(s.gets).to_json
# puts
