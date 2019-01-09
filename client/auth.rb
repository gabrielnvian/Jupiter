module Auth
  def Auth::login(user)
    if user.nil?
      user = AP.input("username")
    end

    pwd = AP.input("password", true)

    $server ? nil : $server = AP.connect()

    if $server
      $server.puts [user, pwd].to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      puts response[:Content][:Response]
      if response[:Code] == CODE_OK
        $credentials = [user, response[:Content][:Power]]
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def Auth::logout()
    if $server
      $server.puts $headers.merge({:Connection=>"close", :Content=>{:Request=>"CLOSE"}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      $server = nil
      $credentials = [nil, 0]
      puts response[:Content][:Response]
      if response[:Code] == CODE_OK
        return true
      else
        return false
      end
    else
      AP.output("Non sei connesso a nessun server")
      return false
    end
  end

  def Auth::adduser(user, pwd, pow)
    if user.nil?
      user = AP.input("username")
    end

    if pwd.nil?
      pwd = AP.input("password", true)
    end

    if pow.nil?
      pow = AP.input("PW level")
    end

    if $server.nil?
      puts "Devi essere connesso per lanciare questo comando"
      return false
    else
      if pow.nil?
        $server.puts $headers.merge({:User_Agent=>"auth", :Content=>{:Request=>"ADDUSER", :Username=>user, :PWD=>pwd}}).to_json
      else
        $server.puts $headers.merge({:User_Agent=>"auth", :Content=>{:Request=>"ADDUSER", :Username=>user, :PWD=>pwd, :Power=>pow}}).to_json
      end
      response = AP.jsontosym(JSON.parse($server.gets))
      puts response[:Content][:Response]
      return true
    end
  end

  def Auth::deluser(user, pwd)
    if user.nil?
      user = AP.input("username")
    end

    if $server.nil?
      puts "Devi essere connesso per lanciare questo comando"
      return false
    else
      $server.puts $headers.merge({:User_Agent=>"auth", :Content=>{:Request=>"DELUSER", :Username=>user, :PWD=>pwd}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      puts response[:Content][:Response]
      return true
    end
  end

  def Auth::changepwd(user, newpwd, pwd)
    if user.nil?
      user = AP.input("username")
    end

    pwd = AP.input("vecchia password", true)
    newpwd = AP.input("nuova password", true)

    if $server.nil?
      puts "Devi essere connesso per lanciare questo comando"
      return false
    else
      $server.puts $headers.merge({:User_Agent=>"auth", :Content=>{:Request=>"CHANGEPWD", :Username=>user, :PWD=>newpwd, :oldPWD=>pwd}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      puts response[:Content][:Response]
      return true
    end
  end

  def Auth::list()
    if $server.nil?
      puts "Devi essere connesso per lanciare questo comando"
      return false
    else
      $server.puts $headers.merge({:User_Agent=>"auth", :Content=>{:Request=>"LIST"}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        AP.table(response[:Content][:Response].unshift(["Username", "Livello PW"]))
      else
        puts response[:Content][:Response]
      end 
      return true
    end
  end
end