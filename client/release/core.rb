module AP
  def AP::connect()
    begin
      return TCPSocket.new HOST, PORT
    rescue
      AP.input("Connessione al server fallita", false)
      return nil
    end
  end

  def AP::jsontosym(h)
    newhash = {}
    for key in h.keys
      if h[key].kind_of?(Hash)
        newhash[key.to_sym] = AP.jsontosym(h[key])
      else
        newhash[key.to_sym] = h[key]
      end
    end
    return newhash
  end

  def AP::input(text = nil, get = true)
    #system("cls")
    system("title AP Client - #{$credentials[0] ? $credentials[0] : "Login non eseguito"}")
    if text.nil?
      print "#{$credentials[0] ? $credentials[0] : "nil"}@#{HOST} > "
    else
      print "#{text} > "
    end
    if get
      return gets.chomp
    else
      return nil
    end
  end
end

headers = {
  :AP=>"3.0",
  :APS=>false,
  :User_Agent=>"auth",
  :Connection=>"keep-alive",
  :Content=>{}
}

CODE_OK = "200 OK"
