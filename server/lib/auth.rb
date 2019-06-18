module Auth
  def self.adduser(usr, pwd, reqpow, pow)
    pow.nil? ? pow = reqpow - 1 : nil
    pow.to_i > 10  && usr != 'root' ? pow = 10 : nil

    return 2 if reqpow < pow.to_i
    return 1 if File.exist?("auth/#{usr}.ini")

    File.open("auth/#{usr}.ini", 'w') do |f1|
      hashed = Digest::MD5.hexdigest(pwd).downcase
      f1.puts "['#{hashed}', #{pow}]"
    end
    FTPAPI.adduser(usr, pwd)
    0
  end

  def self.getpower(usr)
    return -1 unless File.exist?("auth/#{usr}.ini")

    JSON.parse(File.readlines("auth/#{usr}.ini").join(''))[1]
  end

  def self.checkpwd(usr, pwd)
    return false unless File.exist?("auth/#{usr}.ini")

    JSON.parse(File.readlines("auth/#{usr}.ini").join(''))[0] == Digest::MD5.hexdigest(pwd.to_s).downcase
  end

  def self.changepwd(usr, pwd, old = nil, reqpow = 0)
    return 2 unless File.exist?("auth/#{usr}.ini")

    return 1 unless reqpow > Auth.getpower(usr) && Auth.checkpwd(usr, old)

    pow = Auth.getpower(usr)
    File.open("auth/#{usr}.ini", 'w') do |f1|
      hashed = Digest::MD5.hexdigest(pwd).downcase
      f1.puts "['#{hashed}', #{pow}]"
    end
    FTPAPI.change_pass(usr, pwd)
    0
  end

  def self.deluser(usr, pwd = nil, reqpow = 0)
    return 3 if usr == 'root'

    return 2 unless File.exist?("auth/#{usr}.ini")

    return 1 unless reqpow > Auth.getpower(usr) && Auth.checkpwd(usr, pwd)

    FileUtils.rm_rf("auth/#{usr}.ini")
    FTPAPI.deluser(usr)
    0
  end

  def self.login(usr, pwd)
    return false unless File.exist?("auth/#{usr}.ini") || Auth.checkpwd(usr, pwd)

    Auth.getpower(usr)
  end

  def self.list
    list = []
    Dir.entries('auth')[2..-1].each do |entry|
      row = entry.split('.')[0], Auth.getpower(entry.split('.')[0])
      list.push(row)
    end
    list
  end
end
