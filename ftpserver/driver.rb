class Driver
  def initialize(socket)
    @sock = socket
    @user = nil
    @pwd = nil
    @logged = false
    @currentdir = nil
  end

  def run()
    @sock.puts "220-#{$ftpconfig[:welcomeMessage]}"
    
    while true
      request = @sock.gets.chomp
      LOG.debug(request)

      response = parseRequest(request)
      @sock.puts response
      LOG.debug(response)
    end
  end

  def exposeDir()
    dir = @currentdir.sub($config[:defaultDir], "")
    dir == "" ? dir = "/" : nil
    return dir
  end

  def authenticate(user, pwd)
    if File.exist?("auth/#{user}.ini")
      return eval(File.readlines("auth/#{user}.ini").join(""))[0] == Digest::MD5.hexdigest(pwd.to_s).downcase
    else
      return false
    end
  end

  def parseRequest(request)
    case request.split(" ")[0]
    when "AUTH" #----------------------------# AUTH
      return "502 Explicit TLS authentication not allowed." #"534 TLS not enabled"
    when "USER" #----------------------------# USER
      doAction(:auth1, [request.split(" ")[1]])
      return "331 Password required for #{@user}"
    when "PASS" #----------------------------# PASS
      if doAction(:auth2, [request.split(" ")[1]])
        return "230 Logged in"
      else
        return "530 Login incorrect"
      end
    when "CDUP" #----------------------------# CDUP
      if doAction(:cdup)
        return "200 CDUP successful. \"#{exposeDir()}\" is current directory."
      else
      end
    when "PWD" #-----------------------------# PWD
      return "257 \"#{exposeDir()}\" is current directory."
    when "FEAT" #----------------------------# FEAT
      return
        "211-Features:\n" +
        "MDTM\n" +
        "SIZE\n" +
        "MLST type*;size*;modify*;\n" +
        "MLSD\n" +
        "MFMT\n" +
        "EPSV\n" +
        "EPRT\n" +
        "211 End"
      when "MLSD"
        doAction(:list, [request.split(" ")[1]])
    else #-----------------------------------# ELSE
      return "202 Command not implemented"
    end
  end

  def doAction(action, params)
    case action
    when :auth1 #----------------------------# FIRST AUTH (USER)
      @user = params[0]
      return true
    when :auth2 #----------------------------# SECOND AUTH (PWD)
      @pwd = params[0]
      if authenticate(@user, @pwd)
        @logged = true
        @currentdir = $config[:defaultDir]
        return true
      else
        @user, @pwd = nil, nil
        return false
      end
    when :cdup #-----------------------------# CDUP
      newdir = File.dirname(@currentdir)
      if newdir.include?($config[:defaultDir])
        @currentdir = newdir
        return true
      else
        return false
      end
    when :list #-----------------------------# LIST (MLSD)

    else #-----------------------------------# ELSE
    end
  end
end




# D, [2019-02-19T20:01:52.794767 #6684] DEBUG -- : 220 wconrad/ftpd 2.1.0
# D, [2019-02-19T20:01:52.806657 #6684] DEBUG -- : AUTH TLS
# D, [2019-02-19T20:01:52.807344 #6684] DEBUG -- : 534 TLS not enabled
# D, [2019-02-19T20:01:52.818359 #6684] DEBUG -- : AUTH SSL
# D, [2019-02-19T20:01:52.819096 #6684] DEBUG -- : 534 TLS not enabled
# D, [2019-02-19T20:01:52.830611 #6684] DEBUG -- : USER ciao
# D, [2019-02-19T20:01:52.831336 #6684] DEBUG -- : 331 Password required
# D, [2019-02-19T20:01:52.842664 #6684] DEBUG -- : PASS **FILTERED**
# D, [2019-02-19T20:01:52.843381 #6684] DEBUG -- : 230 Logged in
# D, [2019-02-19T20:01:52.854561 #6684] DEBUG -- : PWD
# D, [2019-02-19T20:01:52.855240 #6684] DEBUG -- : 257 "/" is current directory
# D, [2019-02-19T20:06:52.857080 #6684] DEBUG -- : 421 Control connection timed out.