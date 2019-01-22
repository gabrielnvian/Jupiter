require "io/console"

$headers = {
  :AP=>"3.2",
  :APS=>false,
  :User_Agent=>"HelloWorld",
  :Connection=>"keep-alive",
  :Content=>{}
}

CODE_OK = "200 OK"
CODE_ERROR = "500 Internal Server Error"


module AP
  def AP::connect()
    begin
      return TCPSocket.new $host, $port
    rescue
      if AP.checkconn()
        AP.output(COLOR::RED+"Connessione al server fallita"+COLOR::CLEAR)
        return nil
      else
        AP.output(COLOR::RED+"Nessuna connessione a internet"+COLOR::CLEAR)
        return nil
      end
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
      print "#{$credentials[0] ? $credentials[0] : "#{COLOR::RED}nil"}#{COLOR::CLEAR}@#{$server ? $host : COLOR::RED + $host}[#{$credentials[1]}] > #{COLOR::CLEAR}"
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
    puts
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
    puts
    puts
  end

  def AP::changehost(newhost)
    if newhost == "" || newhost.nil?
      puts "#{COLOR::RED}Hostname non valido#{COLOR::CLEAR}"
    else
      $server ? Auth.logout() : nil
      $host = newhost
    end
  end

  def AP::changeport(newport)
    if newport == "" || newport.to_i == 0 || newport.nil?
      puts "#{COLOR::RED}Porta non valida#{COLOR::CLEAR}"
    else
      $server ? Auth.logout() : nil
      $port = newport.to_i
    end
  end

  def AP::checkconn()
    begin
      a = TCPSocket.new "google.com", 80
      a.close
      return true
    rescue
      return false
    end
  end

  def AP::reset()
    $server = nil
    $credentials = [nil, 0]
    #AP.output(COLOR::YELLOW+"Il server non ha risposto alla richiesta, pertanto la connessione e' stata chiusa"+COLOR::CLEAR)
  end
end


module COLOR
  COLOR::CLEAR = "[0m"

  COLOR::GREEN = "[92m"
  COLOR::YELLOW = "[93m"
  COLOR::CYAN = "[96m"
  COLOR::BLUE = "[94m"
  COLOR::RED = "[91m"

  COLOR::BOLD = "[1m"
end