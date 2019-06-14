class Fulfillment
  def auth(req, userinfo)
    case req[:Cont][:Req]
    when 'ADDUSER'
      user = req[:Cont][:Username]
      passwd = req[:Cont][:PWD]
      power = req[:Cont][:Power]
      case Auth.adduser(user, passwd, userinfo[1], power)
      when 0
        return { Cont: { Resp: 'Utente creato con successo' } }, true
      when 1
        return { Code: '400 Bad req', Cont: { Resp: "Utente gia' esistente su questo server" } }, true
      when 2
        return { Code: '401 Unauthorized', Cont: { Resp: 'Impossibile creare un utente con livello PW superiore del richiedente' } }, true
      end
    when 'DELUSER'
      user = req[:Cont][:Username]
      passwd = req[:Cont][:PWD]
      case Auth.deluser(user, passwd, userinfo[1])
      when 0
        return { Cont: { Resp: 'Utente eliminato con successo' } }, true
      when 1
        return { Code: '401 Unauthorized', Cont: { Resp: "L'utente che si cerca di eliminare ha un livello PW superiore del richiedente o la password non corrisponde" } }, true
      when 2
        return { Code: '400 Bad req', Cont: { Resp: "L'utente non esiste" } }, true
      when 3
        return { Code: '400 Bad req', Cont: { Resp: "Impossibile eliminare l'utente root" } }, true
      end
    when 'CHANGEPWD'
      user = req[:Cont][:Username]
      passwd = req[:Cont][:PWD]
      oldpwd = req[:Cont][:oldPWD]
      case Auth.changepwd(user, passwd, oldpwd, userinfo[1])
      when 0
        return { Cont: { Resp: 'Password modificata con successo' } }, true
      when 1
        return { Code: '401 Unauthorized', Cont: { Resp: "L'utente ha un livello PW superiore del richiedente o la password non corrisponde" } }, true
      end
    when 'LIST'
      [{ Cont: { Resp: Auth.list(userinfo[1]) } }, true]
    end
  end
end


class OnServerStartup
  def self.auth_create_dir
    File.exist?('auth') ? nil : FileUtils.mkdir_p('auth')
  end

  def self.auth_adduser_root
    Auth.adduser('root', CONFIG[:rootPWD], 11, 11) unless File.exist?('auth/root')
  end
end
