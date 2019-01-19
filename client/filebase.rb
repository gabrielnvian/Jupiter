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
      puts response[:Content][:Response]
      if response[:Code] == CODE_OK
        ticket = response[:Content][:Ticket]
        if FileBase.uploadfile(path, ticket)
          $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"SUBMIT", :Ticket=>ticket}}).to_json
          response = AP.jsontosym(JSON.parse($server.gets))
          puts response[:Content][:Response]
        end
      end
    else
      AP.output("Non sei connesso a nessun server")
      return false
    end
  end

  def FileBase::list()
    if $server
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"LIST"}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))

      if !response[:Content][:Response].empty?
        files = []
        for item in response[:Content][:Response]
          files.push([
            "#{item[:name].item[:ext]}", 
            item[:date], 
            item[:keywords].join(", ")[0..15], 
            item[:owner]
          ])
        end

        AP.table(files.unshift(["Nome", "Data", "Parole Chiave", "Proprietario"]))
      else
        AP.output("Nessun file sul server")
      end
    else
      AP.output("Non sei connesso a nessun server")
      return false
    end
  end

  def FileBase::query(type)
    if type.nil?
      type = AP.input("type")
    end
    query = AP.input("query")

    if $server
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"QUERY", :Type=>type, :Query=>query}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))

      if !response[:Content][:Response].empty?
        files = []
        for item in response[:Content][:Response]
          files.push([
            "#{item[:name].item[:ext]}", 
            item[:date], 
            item[:keywords].join(", ")[0..15], 
            item[:owner]
          ])
        end

        AP.table(files.unshift(["Nome", "Data", "Parole Chiave", "Proprietario"]))
      else
        AP.output("Nessun file corrisponde alla query")
      end
    else
      AP.output("Non sei connesso a nessun server")
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
      puts "Impossibile contattare il server..."
      return false
    rescue
      puts "C'e' stato un errore durante il trasferimento del file..."
      $server.puts $headers.merge({:User_Agent=>"filebase", :Content=>{:Request=>"CANCEL", :Ticket=>ticket}}).to_json
      response = AP.jsontosym(JSON.parse($server.gets))
      return false
    end
  end
end
