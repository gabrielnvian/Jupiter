require "io/console"

module AP
  def AP::connect()
    begin
      return TCPSocket.new $host, $port
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
    system("title AP Client #{$version} - #{$server ? "Connesso" : "Non connesso"} - #{$credentials[0] ? $credentials[0]+"[#{$credentials[1]}]" : "Login non eseguito"}")
    if text.nil?
      print "#{$credentials[0] ? $credentials[0] : "nil"}@#{$host}[#{$credentials[1]}] > "
    else
      print "#{text} > "
    end
    if pwd
      i = STDIN.noecho(&:gets).chomp
      puts # Add newline char after pwd gets
      if i == ""
        return nil
      else
        return i
      end
    else
      i = gets.to_s.chomp
      if i == ""
        return nil
      else
        return i
      end
    end
  end

  def AP::output(text)
    system("title AP Client #{$version} - #{$server ? "Connesso" : "Non connesso"} - #{$credentials[0] ? $credentials[0]+"[#{$credentials[1]}]" : "Login non eseguito"}")
    puts text
  end

  def AP::table(input, sep = "|", header = true)
    longest = []
    for i in 0...input[0].length
      longest[i] = 0
      for j in 0...input.length
        input[j][i].to_s.length > longest[i] ? longest[i] = input[j][i].to_s.length + 1 : nil
      end
    end

    if header
      for j in 0...input[0].length
        if longest[j]
          print input[0][j].to_s + " "*(longest[j] - input[0][j].to_s.length) + sep + " "
        else
          print input[0][j].to_s
        end
      end
      puts
      for j in 0...input[0].length
        if longest[j]
          print "-"*(j == 0 ? longest[j] : longest[j] + 1) + sep
        else
          print "-"*longest[j]
        end
      end
      puts
    end

    for i in (header ? 1 : 0)...input.length
      for j in 0...input[0].length
        if longest[j]
          print input[i][j].to_s + " "*(longest[j] - input[i][j].to_s.length) + sep + " "
        else
          print input[i][j].to_s
        end
      end
      puts
    end
  end

  def AP::changehost(newhost)
    if newhost != ""
      $server ? Auth.logout() : nil
      $host = newhost
    else
      puts "Hostname non valido"
    end
  end

  def AP::changeport(newport)
    if newport != "" && newport.to_i != 0
      $server ? Auth.logout() : nil
      $port = newport.to_i
    else
      puts "Hostname non valido"
    end
  end
end

$headers = {
  :AP=>"3.2",
  :APS=>false,
  :User_Agent=>"HelloWorld",
  :Connection=>"keep-alive",
  :Content=>{}
}

CODE_OK = "200 OK"
