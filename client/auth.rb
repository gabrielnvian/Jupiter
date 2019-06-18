module AuthClient
  def self.login(user)
    if $creds[0] != user
      user = JClient.input('username') if user.nil?

      pwd = JClient.input('password', true)

      AuthClient.logout unless $creds[0].nil?

      $server.nil? ? $server = JClient.connect : nil

      return nil unless $server

      $server.puts [user, pwd].to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
        $creds = [user, response[:Cont][:Power]]
        return true
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
        return false
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
        return false
      end
    else
      JClient.output(COLOR::RED + "Hai gia' eseguito il login con l'account \"#{user}\"" + COLOR::CLEAR)
    end
  end

  def self.logout
    if $server
      $server.puts HEADERS.merge(Connection: 'close', Cont: { Req: 'CLOSE' }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      $server.close
      JClient.reset
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
        return true
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
        return false
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
        return false
      end
    else
      JClient.output(COLOR::RED + 'Non sei connesso a nessun server' + COLOR::CLEAR)
      return false
    end
  end

  def self.adduser(user, pwd, pow)
    user = JClient.input('username') if user.nil?

    pwd = JClient.input('password', true) if pwd.nil?

    pow = JClient.input('PW level') if pow.nil?

    if $server.nil?
      JClient.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      if pow.nil?
        $server.puts HEADERS.merge(Agent: 'auth', Cont: { Req: 'ADDUSER', Username: user, PWD: pwd }).to_json
      else
        $server.puts HEADERS.merge(Agent: 'auth', Cont: { Req: 'ADDUSER', Username: user, PWD: pwd, Power: pow }).to_json
      end
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.deluser(user, pwd)
    user = JClient.input('username') if user.nil?

    if $server.nil?
      JClient.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      $server.puts HEADERS.merge(Agent: 'auth', Cont: { Req: 'DELUSER', Username: user, PWD: pwd }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.changepwd(user, newpwd, pwd)
    user = JClient.input('username') if user.nil?

    pwd = JClient.input('vecchia password', true) if pwd.nil?
    newpwd = JClient.input('nuova password', true) if newpwd.nil?

    if $server.nil?
      JClient.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      $server.puts HEADERS.merge(Agent: 'auth', Cont: { Req: 'CHANGEPWD', Username: user, PWD: newpwd, oldPWD: pwd }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.list
    if $server.nil?
      JClient.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      $server.puts HEADERS.merge(Agent: 'auth', Cont: { Req: 'LIST' }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.table(response[:Cont][:Resp].unshift(['Username', 'Livello PW']))
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end 
      return true
    end
  end
end