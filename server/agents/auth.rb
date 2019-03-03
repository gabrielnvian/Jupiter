class Fulfillment
  def auth(request, userinfo)
    case request[:Content][:Request]
    when "ADDUSER"
      user = request[:Content][:Username]
      passwd = request[:Content][:PWD]
      power = request[:Content][:Power]
      case Auth.adduser(user, passwd, userinfo[1], power)
      when 0
        return {:Content=>{:Response=>"Utente creato con successo"}}, true
      when 1
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Utente gia' esistente su questo server"}}, true
      when 2
        return {:Code=>"401 Unauthorized", :Content=>{:Response=>"Impossibile creare un utente con livello PW superiore del richiedente"}}, true
      end
    when "DELUSER"
      user = request[:Content][:Username]
      passwd = request[:Content][:PWD]
      case Auth.deluser(user, passwd, userinfo[1])
      when 0
        return {:Content=>{:Response=>"Utente eliminato con successo"}}, true
      when 1
        return {:Code=>"401 Unauthorized", :Content=>{:Response=>"L'utente che si cerca di eliminare ha un livello PW superiore del richiedente o la password non corrisponde"}}, true
      when 2
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"L'utente non esiste"}}, true
      when 3
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Impossibile eliminare l'utente root"}}, true
      end
    when "CHANGEPWD"
      user = request[:Content][:Username]
      passwd = request[:Content][:PWD]
      oldpwd = request[:Content][:oldPWD]
      case Auth.changepwd(user, passwd, oldpwd, userinfo[1])
      when 0
        return {:Content=>{:Response=>"Password modificata con successo"}}, true
      when 1
        return {:Code=>"401 Unauthorized", :Content=>{:Response=>"L'utente ha un livello PW superiore del richiedente o la password non corrisponde"}}, true
      end
    when "LIST"
      return {:Content=>{:Response=>Auth.list(userinfo[1])}}, true
    end
  end
end


class OnServerStartup
  def self.auth_create_dir()
    File.exist?("auth") ? nil : FileUtils.mkdir_p("auth")
  end

  def self.auth_adduser_root()
    File.exist?("auth/root") ? nil : Auth.adduser("root", $config[:rootPWD], 11, 11)
  end
end
