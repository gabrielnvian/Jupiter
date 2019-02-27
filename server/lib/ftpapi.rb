require "nokogiri"
require "securerandom"
require "digest"


module FTPAPI
  def FTPAPI::reloadconfig()
    system("\"#{$config[:FTPserverPath]}/FileZilla Server.exe\" /reload-config")
  end

  def FTPAPI::change_pass(username, newpwd)
    xml = File.readlines("#{$config[:FTPserverPath]}/FileZilla Server.xml").join("").chomp
    newsalt = SecureRandom.hex(32)

    doc = Nokogiri.XML(xml)
    puts doc.at("//User[@Name=\"#{username}\"]//Option[@Name=\"Pass\"]").content = Digest::SHA2.new(512).hexdigest(newpwd + newsalt).upcase()
    doc.at("//User[@Name=\"#{username}\"]//Option[@Name=\"Salt\"]").content = newsalt

    File.open("#{$config[:FTPserverPath]}/FileZilla Server.xml", "w") do |f1|
      f1.puts doc
    end

    FTPAPI.reloadconfig()
  end
end
