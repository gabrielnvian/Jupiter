require "net/ftp"

module FileBase
  def FileBase::addfile(path)
    if $server
      if path.nil?
        path = AP.input("path").gsub(File::ALT_SEPARATOR, File::SEPARATOR).gsub("\"", "")
      end

      fname = File.basename(path, ".*")
      fext = File.extname(path)[1..-1]
      fdate = Time.new.to_i

      fname == "" ? fname = nil : nil
      fext == "" ? fext = nil : nil
      fdate == "" ? fdate = nil : nil

      keywords = AP.input("keywords").split(" ")
      owner = AP.input("owner")
      minPW = AP.input("minPW")

      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"INIT", :Name=>fname, :Ext=>fext, :Date=>fdate,
        :Keywords=>keywords, :Owner=>owner == "" ? nil : owner, :minPW=>minPW == "" ? nil : minPW}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      if response[:Code] == CODE_OK
        AP.output(COLOR::GREEN+response[:Content][:Response]+COLOR::CLEAR)
        ticket = response[:Content][:Ticket]
        if FileBase.uploadfile(path, ticket)
          $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"SUBMIT", :Ticket=>ticket}}).to_json
          response = AP.jsontosym(JSON.parse($server.gets))
          AP.output(response[:Content][:Response])
        end
      elsif response[:Code] == CODE_ERROR
        AP.reset()
        AP.output(COLOR::RED+response[:Content][:Response]+COLOR::CLEAR)
      else
        AP.output(COLOR::RED+response[:Content][:Response]+COLOR::CLEAR)
      end
    else
      AP.output(COLOR::RED+"Non sei connesso a nessun server"+COLOR::CLEAR)
      return false
    end
  end

  def FileBase::list()
    if $server
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"LIST"}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))

      if response[:Code] == CODE_OK
        for i in 0...response[:Content][:Response].length
          response[:Content][:Response][i] = AP.jsontosym(response[:Content][:Response][i])
        end

        if !response[:Content][:Response].empty?
          files = []
          for item in response[:Content][:Response]
            files.push([
              item[:name][0..40] + "." + item[:ext], 
              Time.at(item[:date]).strftime("%d/%m/%y %H:%M"), 
              item[:keywords].join(", ")[0..35], 
              item[:owner]
            ])
          end

          AP.table(files.unshift(["Nome", "Data", "Parole Chiave", "Proprietario"]))
        else
          AP.output(COLOR::YELLOW+"Nessun file da elencare"+COLOR::CLEAR)
        end
      elsif response[:Code] == CODE_ERROR
        AP.reset()
        AP.output(COLOR::RED+response[:Content][:Response]+COLOR::CLEAR)
      else
        AP.output(COLOR::RED+response[:Content][:Response]+COLOR::CLEAR)
      end
    else
      AP.output(COLOR::RED+"Non sei connesso a nessun server"+COLOR::CLEAR)
      return false
    end
  end

  def FileBase::query(type)
    if type.nil?
      type = AP.input("type")
    end
    query = AP.input("query")
    query.to_s[0] == "-" ? query = eval(query.to_s[1..-1]) : nil

    if $server
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"QUERY", :Type=>type, :Query=>query}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))

      if response[:Code] == CODE_OK
        for i in 0...response[:Content][:Response].length
          response[:Content][:Response][i] = AP.jsontosym(response[:Content][:Response][i])
        end

        if !response[:Content][:Response].empty?
          files = []
          for item in response[:Content][:Response]
            files.push([
              item[:name][0..40] + "." + item[:ext], 
              Time.at(item[:date]).strftime("%d/%m/%y %H:%M"), 
              item[:keywords].join(", ")[0..35], 
              item[:owner]
            ])
          end

          AP.table(files.unshift(["Nome", "Data", "Parole Chiave", "Proprietario"]))
        else
          AP.output(COLOR::YELLOW+"Nessun file corrisponde alla query"+COLOR::CLEAR)
        end
      elsif response[:Code] == CODE_ERROR
        AP.reset()
        AP.output(COLOR::RED+response[:Content][:Response]+COLOR::CLEAR)
      else
        AP.output(COLOR::RED+response[:Content][:Response]+COLOR::CLEAR)
      end
    else
      AP.output(COLOR::RED+"Non sei connesso a nessun server"+COLOR::CLEAR)
      return false
    end
  end


  def FileBase::uploadfile(path, ticket)
    puts "Caricamento file..."
    begin
      ftp = Net::FTP.new
      ftp.connect($host, "12345")
      ftp.login("BAY", "bay")
      ftp.passive = true
      ftp.putbinaryfile(path, "#{ticket}#{File.extname(path)}")
      ftp.close
      return true
    rescue Errno::ECONNREFUSED
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"CANCEL", :Ticket=>ticket}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      AP.output(COLOR::RED+"Impossibile contattare il server..."+COLOR::CLEAR)
      return false
    rescue
      AP.output(COLOR::RED+"C'e' stato un errore durante il trasferimento del file..."+COLOR::CLEAR)
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"CANCEL", :Ticket=>ticket}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      return false
    end
  end
end
