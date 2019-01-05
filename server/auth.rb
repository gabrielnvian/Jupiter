module Auth
  def Auth::adduser(usr, pwd, reqpow, pow = reqpow)
    pow.nil? ? pow = reqpow : nil
    if reqpow >= pow.to_i
      if File.exist?("auth/#{usr}.ini")
        return 1
      else
        File.open("auth/#{usr}.ini", "w") do |f1|
          hashed = Digest::MD5.hexdigest(pwd).downcase
          f1.puts "['#{hashed}', #{pow}]"
        end
        return 0
      end
    else
      return 2
    end
  end

  def Auth::getpower(usr)
    if File.exist?("auth/#{usr}.ini")
      return eval(File.readlines("auth/#{usr}.ini").join(""))[1]
    else
      return -1
    end
  end

  def Auth.checkpwd(usr, pwd)
    if File.exist?("auth/#{usr}.ini")
      return eval(File.readlines("auth/#{usr}.ini").join(""))[0] == Digest::MD5.hexdigest(pwd.to_s).downcase
    else
      return false
    end
  end

  def Auth::changepwd(usr, pwd, old = nil, reqpow = 0)
    if File.exist?("auth/#{usr}.ini")
      if reqpow > Auth.getpower(usr)
        pow = Auth.getpower(usr)
        File.open("auth/#{usr}.ini", "w") do |f1|
          hashed = Digest::MD5.hexdigest(pwd).downcase
          f1.puts "['#{hashed}', #{pow}]"
        end
        return 0
      else
        if Auth.checkpwd(usr, old)
          File.open("auth/#{usr}.ini", "w") do |f1|
            hashed = Digest::MD5.hexdigest(pwd).downcase
            f1.puts "['#{hashed}', #{pow}]"
          end
          return 0
        else
          return 1
        end
      end
    else
      return 2
    end
  end

  def Auth::deluser(usr, pwd = nil, reqpow = 0)
    if usr == "root"
      return 3
    else
      if File.exist?("auth/#{usr}.ini")
        if reqpow > Auth.getpower(usr)
          FileUtils.rm_rf("auth/#{usr}.ini")
          return 0
        else
          if Auth.checkpwd(usr, pwd)
            FileUtils.rm_rf("auth/#{usr}.ini")
            return 0
          else
            return 1
          end
        end
      else
        return 2
      end
    end
  end

  def Auth::login(usr, pwd)
    if File.exist?("auth/#{usr}.ini")
      if Auth.checkpwd(usr, pwd)
        return Auth.getpower(usr)
      else
        return false
      end
    else
      return false
    end
  end
end
