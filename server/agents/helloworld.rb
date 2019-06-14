class Fulfillment
  def helloworld(req, userinfo)
    case req[:Cont][:Request]
    when 'HELLOWORLD'
      [{ Cont: { Resp: 'Hello World! :D' } }, true]
    when 'CLOSE'
      [{ Cont: { Resp: "Logout eseguito (#{userinfo[0]})" } }, true]
    end
  end
end

class OnServerStartup
end
