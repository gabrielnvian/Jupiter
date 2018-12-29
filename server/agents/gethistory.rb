class Fulfillment
  def gethistory(request, userinfo)
    return {:Content=>{:Response=>"OK", :History=>@history}}, true
  end
end


class OnServerStartup
end
