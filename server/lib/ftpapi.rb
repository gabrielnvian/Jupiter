module FTPAPI
  def text_to_xml(salt)
    salt = salt.gsub("<", "&lt;")
    salt = salt.gsub(">", "&gt;")
    salt = salt.gsub("&", "&amp;")
    salt = salt.gsub("'", "&apos;")
    salt = salt.gsub("\"", "&quot;")
  end

  def xml_to_text(salt)
    salt = salt.gsub("&lt;", "<")
    salt = salt.gsub("&gt;", ">")
    salt = salt.gsub("&amp;", "&")
    salt = salt.gsub("&apos;", "'")
    salt = salt.gsub("&quot;", "\"")
  end

  def reloadconfig()
    system("#{$config[:FTPserverPath]} /reload-config")
  end
end