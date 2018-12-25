class Fulfillment
  def helloworld(request)
    return {:Content=>{:Response=>"Hello World! :D"}}, true
  end
end


class OnServerStartup
end
