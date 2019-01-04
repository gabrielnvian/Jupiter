module Auth
  def Auth::login(user, pwd)
    if user.nil?
      user = AP.input("username")
    end

    if pwd.nil?
      pwd = AP.input("password")
    end

    $server ? nil : $server = AP.connect()
    if $server.nil?
      a = AP.input("Connettere automaticamente?")
    end

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
      return true
    else
      AP.output("Non sei connesso a nessun server")
      return false
    end
  end
end