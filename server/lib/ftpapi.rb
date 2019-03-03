require "nokogiri"
require "securerandom"
require "digest"


module FTPAPI
  FTPAPI::DEFUSER = '<User Name="Gabriel">
            <Option Name="Pass">79C0BCC109411B6D3C91147548599E3A0B375D70213C8B0778167A51431046F48BE7AF1FBFF16118241511CB3EC278EBC027146B083D044C000F31AF915DB322</Option>
            <Option Name="Salt">a5b76b399331a52d8c71c354bfbc73933da8d1a0040c62390375cd9092d24d45</Option>
            <Option Name="Group"/>
            <Option Name="Bypass server userlimit">0</Option>
            <Option Name="User Limit">0</Option>
            <Option Name="IP Limit">0</Option>
            <Option Name="Enabled">1</Option>
            <Option Name="Comments"/>
            <Option Name="ForceSsl">0</Option>
            <IpFilter>
                <Disallowed/>
                <Allowed/>
            </IpFilter>
            <Permissions>
                <Permission Dir="C:\Users\Java\Desktop">
                    <Option Name="FileRead">1</Option>
                    <Option Name="FileWrite">1</Option>
                    <Option Name="FileDelete">1</Option>
                    <Option Name="FileAppend">1</Option>
                    <Option Name="DirCreate">1</Option>
                    <Option Name="DirDelete">1</Option>
                    <Option Name="DirList">1</Option>
                    <Option Name="DirSubdirs">1</Option>
                    <Option Name="IsHome">1</Option>
                    <Option Name="AutoCreate">0</Option>
                </Permission>
            </Permissions>
            <SpeedLimits DlType="0" DlLimit="10" ServerDlLimitBypass="0" UlType="0" UlLimit="10" ServerUlLimitBypass="0">
                <Download/>
                <Upload/>
            </SpeedLimits>
        </User>'

  def FTPAPI::reloadconfig()
    system("\"#{$config[:FTPserverPath]}/FileZilla Server.exe\" /reload-config")
    return true
  end

  def FTPAPI::create_folder(username)
    FileUtils.mkdir_p("#{$config[:FTPuserPath]}/#{username}")
    return File.exist?("#{$config[:FTPuserPath]}/#{username}")
  end

  def FTPAPI::delete_folder(username)
    FileUtils.rm_rf("#{$config[:FTPuserPath]}/#{username}")
    return !File.exist?("#{$config[:FTPuserPath]}/#{username}")
  end

  def FTPAPI::change_pass(username, newpwd)
    xml = File.readlines("#{$config[:FTPserverPath]}/FileZilla Server.xml").join("").chomp
    newsalt = SecureRandom.hex(32)

    doc = Nokogiri.XML(xml)

    if doc.at("//User[@Name=\"#{username}\"]").nil?
      FTPAPI.adduser(username, newpwd)
    else
      doc.at("//User[@Name=\"#{username}\"]//Option[@Name=\"Pass\"]").content = Digest::SHA2.new(512).hexdigest(newpwd + newsalt).upcase()
      doc.at("//User[@Name=\"#{username}\"]//Option[@Name=\"Salt\"]").content = newsalt

      File.open("#{$config[:FTPserverPath]}/FileZilla Server.xml", "w") do |f1|
        f1.puts doc
      end

      FTPAPI.reloadconfig()
    end
    return true
  end

  def FTPAPI::adduser(username, newpwd)
    FTPAPI.create_folder(username)

    xml = File.readlines("#{$config[:FTPserverPath]}/FileZilla Server.xml").join("").chomp
    doc = Nokogiri.XML(xml)

    if doc.at("//User[@Name=\"#{username}\"]").nil?
      newsalt = SecureRandom.hex(32)
      newuser = Nokogiri.XML(FTPAPI::DEFUSER)

      newuser.at("//User").attributes["Name"].value = username
      newuser.at("//Option[@Name=\"Pass\"]").content = Digest::SHA2.new(512).hexdigest(newpwd + newsalt).upcase()
      newuser.at("//Option[@Name=\"Salt\"]").content = newsalt
      newuser.at("//Permission").attributes["Dir"].value = "#{$config[:FTPuserPath]}/#{username}"

      doc.at("//Users").add_child(newuser.at("//User[@Name=\"#{username}\"]"))

      File.open("#{$config[:FTPserverPath]}/FileZilla Server.xml", "w") do |f1|
        f1.puts doc
      end

      FTPAPI.reloadconfig()
    end
    return true
  end

  def FTPAPI::deluser(username)
    FTPAPI.delete_folder(username)
    xml = File.readlines("#{$config[:FTPserverPath]}/FileZilla Server.xml").join("").chomp
    doc = Nokogiri.XML(xml)
    if doc.at("//User[@Name=\"#{username}\"]") != nil
      doc.at("//User[@Name=\"#{username}\"]").remove

      File.open("#{$config[:FTPserverPath]}/FileZilla Server.xml", "w") do |f1|
        f1.puts doc
      end

      FTPAPI.reloadconfig()
    end
    return true
  end
end