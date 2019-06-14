module AuthClient
  def self.login(server, creds, user)
    if creds[0] != user
      user = AP.input('username') if user.nil?

      pwd = AP.input('password', true)

      Auth.logout unless creds.nil?

      server ? nil : server = AP.connect

      if server
        server.puts [user, pwd].to_json
        response = AP.jsontosym(JSON.parse(server.gets))
        if response[:Code] == CODE_OK
          AP.output(COLOR::GREEN + response[:Content][:Response] + COLOR::CLEAR)
          return [user, response[:Content][:Power]]
        elsif response[:Code] == CODE_ERROR
          AP.reset
          AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
          return nil
        else
          AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
          return nil
        end
      else
        return nil
      end
    else
      AP.output(COLOR::RED + "Hai gia' eseguito il login con l'account \"#{user}\"" + COLOR::CLEAR)
    end
  end

  def self.logout(server)
    if server
      server.puts HEADERS.merge(Connection: 'close', Cont: { Req: 'CLOSE' }).to_json
      response = AP.jsontosym(JSON.parse(server.gets))
      server.close
      AP.reset
      if response[:Code] == CODE_OK
        AP.output(COLOR::GREEN + response[:Content][:Response] + COLOR::CLEAR)
        return true
      elsif response[:Code] == CODE_ERROR
        AP.reset
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
        return false
      else
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
        return false
      end
    else
      AP.output(COLOR::RED + 'Non sei connesso a nessun server' + COLOR::CLEAR)
      return false
    end
  end

  def self.adduser(server, user, pwd, pow)
    user = AP.input('username') if user.nil?

    pwd = AP.input('password', true) if pwd.nil?

    pow = AP.input('PW level') if pow.nil?

    if server.nil?
      AP.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      if pow.nil?
        server.puts HEADERS.merge(User_Agent: 'auth', Content: { Request: 'ADDUSER', Username: user, PWD: pwd }).to_json
      else
        server.puts HEADERS.merge(User_Agent: 'auth', Content: { Request: 'ADDUSER', Username: user, PWD: pwd, Power: pow }).to_json
      end
      response = AP.jsontosym(JSON.parse(server.gets))
      if response[:Code] == CODE_OK
        AP.output(COLOR::GREEN + response[:Content][:Response] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        AP.reset
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      else
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.deluser(server, user, pwd)
    if user.nil?
      user = AP.input('username')
    end

    if server.nil?
      AP.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      server.puts headers.merge(User_Agent: 'auth', Content: { Request: 'DELUSER', Username: user, PWD: pwd }).to_json
      response = AP.jsontosym(JSON.parse(server.gets))
      if response[:Code] == CODE_OK
        AP.output(COLOR::GREEN + response[:Content][:Response] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        AP.reset
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      else
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.changepwd(user, newpwd, pwd)
    user = AP.input('username') if user.nil?

    pwd = AP.input('vecchia password', true) if pwd.nil?
    newpwd = AP.input('nuova password', true) if newpwd.nil?

    if server.nil?
      AP.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      server.puts server.merge(User_Agent: 'auth', Content: { Request: 'CHANGEPWD', Username: user, PWD: newpwd, oldPWD: pwd }).to_json
      response = AP.jsontosym(JSON.parse(server.gets))
      if response[:Code] == CODE_OK
        AP.output(COLOR::GREEN + response[:Content][:Response] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        AP.reset
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      else
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.list
    if server.nil?
      AP.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      server.puts HEADERS.merge(User_Agent: 'auth', Content: { Request: 'LIST' }).to_json
      response = AP.jsontosym(JSON.parse(server.gets))
      if response[:Code] == CODE_OK
        AP.table(response[:Content][:Response].unshift(['Username', 'Livello PW']))
      elsif response[:Code] == CODE_ERROR
        AP.reset
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      else
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
      end 
      return true
    end
  end
end