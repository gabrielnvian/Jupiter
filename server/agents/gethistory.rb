class Fulfillment
  def gethistory(req, userinfo)
    [{ Cont: { Resp: @history } }, true]
  end
end


class OnServerStartup
end
