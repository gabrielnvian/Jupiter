class Fulfillment
  def gethistory(request)
    return {"Content"=>{"Response"=>"OK", "History"=>@history}}, true
  end
end


class OnServerStartup
end
