class Fulfillment
  def gethistory(request, userinfo)
    return {:Content=>{:Response=>@history}}, true
  end
end


class OnServerStartup
end
