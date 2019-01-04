class Fulfillment
  def helloworld(request, userinfo)
    case request[:Content][:Request]
    when "HELLOWORLD"
      return {:Content=>{:Response=>"Hello World! :D"}}, true
    when "CLOSE"
      return {:Content=>{:Response=>"Logout successful"}}, true
    end
  end
end


class OnServerStartup
end
