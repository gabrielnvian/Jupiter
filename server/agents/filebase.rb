class Fulfillment
  def filebase(request, userinfo)
    case request[:Content][:Request]
    when "COMM"
      ticket = AP.getsafeid(Dir.entries("agents/files/filebase/tickets")[2..-1])
      File.open("agents/files/filebase/tickets/#{ticket}.ini", "w") do |f1|
        t = {:code=>AP.getsafeid(FileBase.list($config[:DBpath]), 20), :name=>request[:Content][:Name],
          :ext=>request[:Content][:Ext], :date=>request[:Content][:Date], :keywords=>request[:Content][:Keywords]}
        f1.puts t
      end
      return {:Content=>{:Response=>"Registered", :Ticket=>ticket}}, true
    when "SUBM"
      ticket = ticket
      if File.exists?("agents/files/filebase/tickets/#{ticket}.ini")
        file = eval(File.open("agents/files/filebase/tickets/#{ticket}.ini").readlines.join(""))
        FileUtils.cp("#{$config[:BayPath]}/#{ticket}", "#{$config[:DBpath]}/#{file[:code]}.#{file[:ext]}")

        FileBase.add($config[:DBpath], file)
        FileUtils.rm("#{$config[:BayPath]}/#{ticket}")
        return {:Content=>{:Response=>:Saved}}, true
      else
        AP::log("Bad Request: ticket not exists", @id, "error")
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Ticket does not exists"}}, true
      end
    end
  end
end


class OnServerStartup
  def self.filebase_delete_tickets()
    for entry in Dir.entries("agents/files/filebase/tickets").select {|f| !File.directory? f}
      FileUtils.rm("agents/files/filebase/tickets/#{entry}")
    end
  end

  def self.filebase_create_subfolders()
    FileUtils.mkdir_p("#{$config[:DBpath]}/.db")
  end
end


module FileBase
  def FileBase::add(path, item)
    db = FileBase.load(path)
    File.open("#{path}/.db/registry", "w") do |f1|
      f1.puts db.push(item)
    end
    return true
  end

  def FileBase::commit(path, db) # Rewrites the entire registry with the new provided
    if db.kind_of?(Array)
      File.open("#{path}/.db/registry", "w") do |f1|
        f1.puts db
      end
      return true
    else
      return false
    end
  end

  def FileBase::load(path) # Loads and returns the registry
    return eval(File.open("#{path}/.db/registry").readlines.join(""))
  end

  def FileBase::check(path) # Deletes non existing files
    db = FileBase.load(path)
    db.each_with_index do |entry, i|
      if !File.exists?("#{path}/#{entry}")
        db.delete_at(i)
      end
    end
    FileBase.commit(path, db)
    return true
  end

  def FileBase::list(path)
    list = []
    for entry in FileBase.load(path)
      list.push(entry[:code])
    end
    return list
  end
end


# a = {:id=>"1", :name=>"ciao.txt", :date=>Time.new.to_i, :keywords=>["file a caso", "boooh"]}

# load "C:/Users/Java/Documents/GitHub/AlphaProtocol/server/agents/filebase.rb"

# pa = "C:/Users/Java/Documents/GitHub/AlphaProtocol/server/agents/files/filebase/database"