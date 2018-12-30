module Auth
  def Auth::adduser(usr, pwd, reqpow, pow = reqpow)
    if reqpow >= pow
      if File.exists?("auth/#{usr}")
        return 1
      else
        FileUtils.mkdir_p("auth/#{usr}")
        File.open("auth/#{usr}/user.ini", "w") do |f1|
          f1.puts "['#{pwd}', #{pow}]"
        end
        return 0
      end
    else
      return 2
    end
  end

  def Auth::getpower(usr)
    return eval(File.open("auth/#{usr}/user.ini").readlines.join(""))[1]
  end

  def Auth.checkpwd(usr, pwd)
    return eval(File.open("auth/#{usr}/user.ini").readlines.join(""))[0] == pwd.to_s
  end

  def Auth::changepwd(usr, pwd, old = nil, reqpow = 0)
    if reqpow > AP.getpower(usr)
      File.open("auth/#{usr}/user.ini", "w") do |f1|
        f1.puts "['#{pwd}', #{pow}]"
      end
      return 0
    else
      if Auth.checkpwd(usr, old)
        File.open("auth/#{usr}/user.ini", "w") do |f1|
          f1.puts "['#{pwd}', #{pow}]"
        end
        return 0
      else
        return 1
      end
    end
  end

  def Auth::deluser(usr, pwd = nil, reqpow = 0)
    if reqpow > AP.getpower(usr)
      FileUtils.rm_rf("auth/#{usr}")
      return 0
    else
      if Auth.checkpwd(usr, old)
        FileUtils.rm_rf("auth/#{usr}")
        return 0
      else
        return 1
      end
    end
  end


  def Auth::login(usr, pwd)
    if File.exists?("auth/#{usr}")
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


File.exists?("auth/root") ? nil : Auth.adduser("root", $config[:rootPWD], 11, 10)
