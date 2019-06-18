require 'io/console'

HEADERS = {
  J: '3.2',
  JS: false,
  Agent: 'HelloWorld',
  Connection: 'keep-alive',
  Cont: {}
}.freeze

CODE_OK = '200 OK'.freeze
CODE_ERROR = '500 Internal Server Error'.freeze


module JClient
  def self.connect
    begin
      return TCPSocket.new $host, $port
    rescue
      out = JClient.checkconn ? 'Connessione al server fallita' : 'Nessuna connessione a internet'
      JClient.output(COLOR::RED + out + COLOR::CLEAR)
      return nil
    end
  end

  def self.jsontosym(h)
    newhash = {}
    h.keys.each do |key|
      newhash[key.to_sym] = h[key].is_a?(Hash) ? self.jsontosym(h[key]) : h[key]
    end
    return newhash
  end

  def self.input(text = nil, pwd = false)
    # system("cls")
    system("title AP Client #{VERSION} - #{$server ? 'Connesso' : 'Non connesso'} - #{$creds[0] ? $creds[0]+"[#{$creds[1]}]" : 'Login non eseguito'}")

    longstr = "#{$creds[0] || "#{COLOR::RED}nil"}#{COLOR::CLEAR}@#{$server ? $host : COLOR::RED + $host}[#{$creds[1]}] > #{COLOR::CLEAR}"
    print text.nil? ? longstr : "#{text} > "

    if pwd
      i = STDIN.noecho(&:gets).chomp
      puts
    else
      i = gets.to_s.chomp
    end

    i == '' ? nil : i # return
  end

  def self.output(text)
    system("title AP Client #{VERSION} - #{$server ? 'Connesso' : 'Non connesso'} - #{$creds[0] ? $creds[0]+"[#{$creds[1]}]" : 'Login non eseguito'}")
    puts text
  end

  def self.chghost(newhost)
    if newhost == '' || newhost.nil?
      puts "#{COLOR::RED}Hostname non valido#{COLOR::CLEAR}"
      false # return
    else
      $server ? Auth.logout : nil
      $host = newhost
      true # return
    end
  end

  def self.chgport(newport)
    if newport == '' || newport.to_i.zero? || newport.nil?
      puts "#{COLOR::RED}Porta non valida#{COLOR::CLEAR}"
      false # return
    else
      $server ? Auth.logout : nil
      $port = newport
      true # return
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
    $server = nil
    $creds = [nil, 0]
    # JClient.output(COLOR::YELLOW+"Il server non ha risposto alla richiesta, pertanto la connessione e' stata chiusa"+COLOR::CLEAR)
  end

  def self.ping
    if $server
      time1 = Time.now
      $server.puts HEADERS.merge(Cont: { Req: 'HELLOWORLD' }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      time2 = Time.now
      if response[:Code] == CODE_OK
        JClient.output("Ridardo in millisecondi: #{(time2 - time1) * 1000.0}")
        true # return
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
        false # return
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
        false # return
      end
    else
      JClient.output(COLOR::RED + 'Non sei connesso a nessun server' + COLOR::CLEAR)
      false # return
    end
  end
end
