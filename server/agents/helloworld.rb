class Fulfillment
  def helloworld(request, userinfo)
    return {:Content=>{:Response=>"Hello World! :D"}}, true
  end
end


class OnServerStartup
end
