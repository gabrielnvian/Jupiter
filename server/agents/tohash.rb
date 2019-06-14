class Fulfillment
  def tohash(req, userinfo)
    hashtype = req[:Cont][:Hashtype].downcase
    string = req[:Cont][:String]

    case hashtype
    when "md5"
      newhash = Digest::MD5.hexdigest(string).downcase
      [{ Cont: { Resp: newhash } }, true]
    else
      [{ Code: "400 Bad Request", Cont: { Resp: "Algoritmo hash non supportato" } }, true]
    end
  end
end


class OnServerStartup
end
