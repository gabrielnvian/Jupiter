require 'io/console'

HEADERS = {
  :J => '3.2',
  :JS => false,
  :Agent => 'HelloWorld',
  :Connection => 'keep-alive',
  :Cont => {}
}

CODE_OK = '200 OK'
CODE_ERROR = '500 Internal Server Error'


module JClient
  def self.connect(host, port)
    begin
      return TCPSocket.new host, port
    rescue
      if AP.checkconn
        AP.output(COLOR::RED+'Connessione al server fallita'+COLOR::CLEAR)
        return nil
      else
        AP.output(COLOR::RED+'Nessuna connessione a internet'+COLOR::CLEAR)
        return nil
      end
    end
  end

  def self.jsontosym(h)
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

  def self.input(server, creds, text = nil, pwd = false)
    #system("cls")
    system("title AP Client #{VERSION} - #{server ? "Connesso" : "Non connesso"} - #{creds[0] ? creds[0]+"[#{creds[1]}]" : "Login non eseguito"}")
    if text.nil?
      print "#{creds[0] ? creds[0] : "#{COLOR::RED}nil"}#{COLOR::CLEAR}@#{server ? host : COLOR::RED + host}[#{creds[1]}] > #{COLOR::CLEAR}"
    else
      print "#{text} > "
    end
    if pwd
      i = STDIN.noecho(&:gets).chomp
      puts # Add newline char after pwd gets
      if i == ''
        return nil
      else
        return i
      end
    else
      i = gets.to_s.chomp
      if i == ''
        return nil
      else
        return i
      end
    end
  end

  def self.output(server, creds, text)
    system("title AP Client #{VERSION} - #{server ? "Connesso" : "Non connesso"} - #{creds[0] ? creds[0]+"[#{creds[1]}]" : "Login non eseguito"}")
    puts text
  end

  def self.table(input, sep = '|', header = true)
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
          print input[0][j].to_s + ' '*(longest[j] - input[0][j].to_s.length) + sep + ' '
        else
          print input[0][j].to_s
        end
      end
      puts
      for j in 0...input[0].length
        if longest[j]
          print '-'*(j == 0 ? longest[j] : longest[j] + 1) + sep
        else
          print '-'*longest[j]
        end
      end
      puts
    end

    for i in (header ? 1 : 0)...input.length
      for j in 0...input[0].length
        if longest[j]
          print input[i][j].to_s + ' '*(longest[j] - input[i][j].to_s.length) + sep + ' '
        else
          print input[i][j].to_s
        end
      end
      puts
    end
    puts
    puts
  end

  def self.chghost(server, newhost)
    if newhost == '' || newhost.nil?
      puts "#{COLOR::RED}Hostname non valido#{COLOR::CLEAR}"
      return false
    else
      server ? Auth.logout : nil
      return true
    end
  end

  def self.chgport(server, newport)
    if newport == '' || newport.to_i == 0 || newport.nil?
      puts "#{COLOR::RED}Porta non valida#{COLOR::CLEAR}"
      return false
    else
      server ? Auth.logout : nil
      return true
    end
  end

  def self.checkconn
    begin
      a = TCPSocket.new 'google.com', 80
      a.close
      return true
    rescue
      return false
    end
  end

  def self.reset
    server = nil
    creds = [nil, 0]
    return server, creds
    #AP.output(COLOR::YELLOW+"Il server non ha risposto alla richiesta, pertanto la connessione e' stata chiusa"+COLOR::CLEAR)
  end

  def self.ping
    if $server
      time1 = Time.now
      $server.puts $headers.merge({:Content=>{:Request=>'HELLOWORLD'}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      time2 = Time.now
      if response[:Code] == CODE_OK
        AP.output("Ridardo in millisecondi: #{(time2 - time1) * 1000.0}")
        return true
      elsif response[:Code] == CODE_ERROR
        AP.reset
        AP.output(COLOR::RED+response[:Content][:Response]+COLOR::CLEAR)
        return false
      else
        AP.output(COLOR::RED + response[:Content][:Response] + COLOR::CLEAR)
        return false
      end
    else
      AP.output(COLOR::RED+'Non sei connesso a nessun server'+COLOR::CLEAR)
      return false
    end
  end
end
