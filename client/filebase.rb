require 'net/ftp'

module FileBase
  def self.addfile(path)
    if $server
      if path.nil?
        path = JClient.input('path').gsub(File::ALT_SEPARATOR, File::SEPARATOR).gsub('"', '')
      end

      fname = File.basename(path, '.*')
      fext = File.extname(path)[1..-1]
      fdate = Time.new.to_i

      fname = nil if fname == ''
      fext = nil if fext == ''
      fdate = nil if fdate == ''

      keywords = JClient.input('keywords').split(' ')
      owner = JClient.input('owner')
      min_pw = JClient.input('min_pw')

      $server.puts HEADERS.merge(Agent: 'filebase', Cont: { Req: 'UPLOAD', Name: fname, Ext: fext, Date: fdate,
                                                                    Keywords: keywords, Owner: owner == '' ? nil : owner,
                                                                    min_pw: min_pw == '' ? nil : min_pw }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
        ticket = response[:Cont][:Ticket]
        if FileBase.uploadfile(path, ticket)
          $server.puts HEADERS.merge(Agent: 'filebase', Cont: { Req: 'SUBMIT', Ticket: ticket }).to_json
          response = JClient.jsontosym(JSON.parse($server.gets))
          JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
        end
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
    else
      JClient.output(COLOR::RED + 'Non sei connesso a nessun server' + COLOR::CLEAR)
      false
    end
  end

  def self.list
    if $server
      $server.puts HEADERS.merge(Agent: 'filebase', Cont: { Req: 'LIST' }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))

      if response[:Code] == CODE_OK
        FileBase.show(response, 'Nessun file da elencare')
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
    else
      JClient.output(COLOR::RED + 'Non sei connesso a nessun server' + COLOR::CLEAR)
      false
    end
  end

  def self.query(type)
    type = JClient.input('type') if type.nil?

    query = JClient.input('query')
    query.to_s[0] == '-' ? query = eval(query.to_s[1..-1]) : nil

    if $server
      $server.puts HEADERS.merge(Agent: 'filebase', Cont: { Req: 'QUERY', Type: type, Query: query }).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))

      if response[:Code] == CODE_OK
        FileBase.show(response, 'Nessun file corrisponde alla query')
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
    else
      JClient.output(COLOR::RED + 'Non sei connesso a nessun server' + COLOR::CLEAR)
      return false
    end
  end


  def self.uploadfile(path, ticket)
    JClient.output(COLOR::YELLOW+'Caricamento file...'+COLOR::CLEAR)
    begin
      ftp = Net::FTP.new
      ftp.connect($host, '12345')
      ftp.login('BAYUP', 'bayup')
      ftp.passive = true
      ftp.putbinaryfile(path, "#{ticket}#{File.extname(path)}")
      ftp.close
      return true
    rescue Errno::ECONNREFUSED
      $server.puts HEADERS.merge({ Agent: 'filebase', Cont: { Req: 'CANCEL', Ticket: ticket } }).to_json
      JClient.jsontosym(JSON.parse($server.gets))
      JClient.output(COLOR::RED + 'Impossibile contattare il server...' + COLOR::CLEAR)
      return false
    rescue
      JClient.output(COLOR::RED + "C'e' stato un errore durante il trasferimento del file..." + COLOR::CLEAR)
      $server.puts HEADERS.merge({ Agent: 'filebase', Cont: { Req: 'CANCEL', Ticket: ticket } }).to_json
      JClient.jsontosym(JSON.parse($server.gets))
      return false
    end
  end

  def self.show(resp, msg)
    resp[:Cont][:Resp].each_index do |i|
      resp[:Cont][:Resp][i] = JClient.jsontosym(resp[:Cont][:Resp][i])
    end

    JClient.output(COLOR::YELLOW + msg + COLOR::CLEAR) if resp[:Cont][:Resp].empty?

    files = []
    resp[:Cont][:Resp].each do |item|
      files.push([
                     item[:uid],
                     item[:name][0..40] + '.' + item[:ext],
                     Time.at(item[:date]).strftime('%d/%m/%y %H:%M'),
                     item[:keywords].join(', ')[0..35],
                     item[:owner]
                 ])
    end

    JClient.table(files.unshift(%w[UID Nome Data Parole\ Chiave Proprietario]))
  end
end
