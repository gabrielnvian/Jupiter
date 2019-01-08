require "io/console"

module AP
  def AP::connect()
    begin
      return TCPSocket.new HOST, PORT
    rescue
      AP.output("Connessione al server fallita")
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

  def AP::input(text = nil, pwd = false)
    #system("cls")
    system("title AP Client - #{$server ? "Connesso" : "Non connesso"} - #{$credentials[0] ? $credentials[0]+"[#{$credentials[1]}]" : "Login non eseguito"}")
    if text.nil?
      print "#{$credentials[0] ? $credentials[0] : "nil"}@#{HOST}[#{$credentials[1]}] > "
    else
      print "#{text} > "
    end
    if pwd
      i = STDIN.noecho(&:gets).chomp
      if i = ""
        return nil
      else
        return i
      end
    else
      i = gets.to_s.chomp
      if i = ""
        return nil
      else
        return i
      end
    end
  end

  def AP::output(text)
    system("title AP Client - #{$server ? "Connesso" : "Non connesso"} - #{$credentials[0] ? $credentials[0]+"[#{$credentials[1]}]" : "Login non eseguito"}")
    puts text
  end
end

$headers = {
  :AP=>"3.0",
  :APS=>false,
  :User_Agent=>"HelloWorld",
  :Connection=>"keep-alive",
  :Content=>{}
}

CODE_OK = "200 OK"
