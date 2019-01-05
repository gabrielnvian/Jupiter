class Fulfillment
  def tohash(request, userinfo)
    hashtype = request[:Content][:Hashtype].downcase
    string = request[:Content][:String]
    
    case hashtype
    when "md5"
      newhash = Digest::MD5.hexdigest(string).downcase
    else
      return {:Code=>"400 Bad Request", :Content=>{:Response=>"Algoritmo hash non supportato"}}, true
    end
    return {:Content=>{:Response=>newhash}}, true
  end
end


class OnServerStartup
end
