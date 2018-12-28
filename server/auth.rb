module Auth
  def Auth::adduser(usr, pwd, reqpow, pow = reqpow)
    if reqpow >= pow
      if File.exists?("auth/#{usr}")
        return false
      else
        FileUtils.mkdir_p("auth/#{usr}")
        File.open("auth/#{usr}/user.ini", "w") do |f1|
          f1.puts "['#{pwd}', #{pow}]"
        end
        return true
      end
    else
      return false
    end
  end

  def Auth::getpower(usr)
    return eval(File.open("auth/#{usr}/user.ini").readlines.join(""))[1]
  end

  def Auth.checkpwd(usr, pwd)
    return eval(File.open("auth/#{usr}/user.ini").readlines.join(""))[0] == pwd
  end

  def Auth::changepwd(usr, pwd, old = nil, reqpow = 0)
    pow = AP.getpower(usr)
    if old = nil
      if reqpow >= pow
        File.open("auth/#{usr}/user.ini", "w") do |f1|
          f1.puts "['#{pwd}', #{pow}]"
        end
        return true
      else
        return false
      end
    else
      File.open("auth/#{usr}/user.ini", "w") do |f1|
        f1.puts "['#{pwd}', #{pow}]"
      end
      return true
    end
  end

  def Auth::deluser(usr)
    FileUtils.rm_rf("auth/#{usr}")
    return !File.exists?("auth/#{usr}")
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
