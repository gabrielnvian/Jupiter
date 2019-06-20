require 'net/ftp'

module FileBase
  def self.add(path, owner, power, *kwords)
    path = JClient.input('path') if path.nil?
    until File.file?(path)
      JClient.output(COLOR::RED + "'#{path}' non e' un file valido!" + COLOR::CLEAR)
      path = JClient.input('path') if path.nil?
    end

    FileBase.uploadfile(path)

    owner = JClient.input('current user --> owner?') || $creds[0] if owner.nil?

    power = JClient.input('current power --> power?') || $creds[1] if power.nil?

    name = File.basename(path, '.*')
    ext = File.extname(path)[1..-1] # Remove dot

    if owner != $creds[0] && power > $creds[1]
      raise Interrupt if JClient.input('Non avrai accesso a questo file, continuare? (si/no)') == 'no'
    end

    if $server.nil?
      JClient.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      data = { name: name, ext: ext, owner: owner, power: power, kwords: kwords }
      $server.puts HEADERS.merge(Agent: 'filebase', Cont: { Req: 'ADD', Data: data}).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.del(uid)
    uid = JClient.input('uid') || $creds[0] if uid.nil?

    if $server.nil?
      JClient.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      return false
    else
      $server.puts HEADERS.merge(Agent: 'filebase', Cont: { Req: 'DEL', uid: uid}).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
      elsif response[:Code] == CODE_ERROR
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      else
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end
      return true
    end
  end

  def self.list
    if $server.nil?
      JClient.output(COLOR::RED + 'Devi essere connesso per lanciare questo comando' + COLOR::CLEAR)
      false
    else
      $server.puts HEADERS.merge(Agent: 'filebase', Cont: { Req: 'LIST'}).to_json
      response = JClient.jsontosym(JSON.parse($server.gets))

      if response[:Code] != CODE_OK
        JClient.reset
        JClient.output(COLOR::RED + response[:Cont][:Resp] + COLOR::CLEAR)
      end

      JClient.output(COLOR::GREEN + response[:Cont][:Resp] + COLOR::CLEAR)
      t = Terminal::Table.new
      t.add_row %w[UID Nome Ext Proprietario PWLVL Parole\ Chiave]
      t.add_separator
      response[:Cont][:Data].each do |f|
        row = [f[:uid], f[:name], f[:ext], f[:owner], f[:power], f[:kwords].join(", ")]
        t.add_row row
      end
      true
    end
  end

  def self.query(type)
  end

  def self.uploadfile(path)
    Net::FTP.open($host) do |ftp|
      ftp.login('Jupiter', 'ciaociao')
      ftp.putbinaryfile(path, File.basename(path), 1024)
    end
  end

  def self.show(resp, msg)
  end
end
