class Fulfillment
  def filebase(request)
    case request["Content"]["Request"]
    when "COMM"
      ticket = "8668"# AP::getsafeid(Dir.entries("agents/files/filebase/tickets")[2..-1])
      File.open("agents/files/filebase/tickets/#{ticket}.ini", "w") do |f1|
      f1.puts "["
        f1.puts "#{request["Content"]["Name"]},"
        f1.puts "#{request["Content"]["Ext"]},"
        f1.puts "#{request["Content"]["Date"]}"
        f1.puts "#{request["Content"]["Keywords"]}"
        f1.puts "]"
      end
      return {"Content"=>{"Response"=>"Registered", "Ticket"=>ticket}}, true
    when "SUBM"
      if File.exists?("agents/files/filebase/tickets/#{request["Content"]["Ticket"]}.ini")
        file = eval(File.open("agents/files/filebase/tickets/#{request["Content"]["Ticket"]}.ini").readlines.join(""))
        FileUtils.cp("#{$config["BayPath"]}/#{request["Content"]["Ticket"]}.#{file[1]}", "#{$config["DBpath"]}/#{file[0]}-#{file[2].to_s}.#{file[1]}")

        FileBase.add($config["DBpath"], {FileBase.getid(path)=>{:name=>file[0], :ext=>file[1], :date=>file[2], :keywords=>file[3]}})
        FileUtils.rm("#{$config["BayPath"]}/#{request["Content"]["Ticket"]}.#{file[1]}")
        return {"Content"=>{"Response"=>"Saved"}}, true
      else
        AP::log("Bad Request: ticket not exists", @id, "error")
        return {"Code"=>"400 Bad Request", "Content"=>{"Response"=>"Ticket does not exists"}}, true
      end
    end
  end
end


class OnServerStartup
  def self.filebase_delete_tickets()
    Dir.entries("agents/files/filebase/tickets")[2..-1].each do |entry|
      FileUtils.rm("agents/files/filebase/tickets/#{entry}")
    end
  end

  def self.filebase_create_subfolders()
    FileUtils.mkdir_p("#{$config["DBpath"]}/.db")
  end
end


module FileBase
  def FileBase::add(path, item)
    if item[:id].kind_of?(String) && item[:name].kind_of?(String) && item[:date].kind_of?(Integer) && item[:keywords].kind_of?(Array)
      File.open("#{path}/.db/registry", "w") do |f1|
        f1.puts FileBase.load(path).merge(item)
      end
      return true
    else
      raise Exception, "item fields missing or invalid"
      return false
    end
  end

  def FileBase::clear(path)
    db = FileBase.load(path)
    for i in 0...db.keys.length
      db[i] = nil if !File.exists?("#{path}/#{db[i][:name]}.#{db[i][:ext]}")
    end
  end

  def FileBase::load(path)
    return eval(File.open("#{path}/.db/registry").readlines.join(""))
  end

  def FileBase::getid(path)
    FileBase.clear(path)
    db = FileBase.load(path)
    for i in 0...db.keys.length
      return i if db[i] == nil
    end
    return db.keys.length + 1
  end
end
