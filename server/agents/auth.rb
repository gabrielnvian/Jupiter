class Fulfillment
  def auth(request, userinfo)
    case request[:Content][:Request]
    when "ADDUSER"
      user = request[:Content][:Username]
      passwd = request[:Content][:PWD]
      power = request[:Content][:Power]
      case Auth.adduser(user, passwd, userinfo[1], power)
      when 0
        return {:Content=>{:Response=>"User created"}}, true
      when 1
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"User already exists on server"}}), true
      when 2
        return {:Code=>"401 Unauthorized", :Content=>{:Response=>"New user PW level is higher than the caller PW level"}}), true
      end
    when "DELUSER"
      user = request[:Content][:Username]
      passwd = request[:Content][:PWD]
      case Auth.deluser(user, passwd, userinfo[1])
      when 0
        return {:Content=>{:Response=>"User deleted"}}, true
      when 1
        return {:Code=>"401 Unauthorized", :Content=>{:Response=>"User you are trying to delete has higher PW level or user pwd does not match"}}), true
      end
    when "CHANGEPWD"
      user = request[:Content][:Username]
      passwd = request[:Content][:PWD]
      oldpwd = request[:Content][:PWD]
      case Auth.changepwd(user, passwd, userinfo[1])
      when 0
        return {:Content=>{:Response=>"User deleted"}}, true
      when 1
        return {:Code=>"401 Unauthorized", :Content=>{:Response=>"User has higher PW level than caller or user old pwd does not match"}}), true
      end
    end
  end
end


class OnServerStartup
end
