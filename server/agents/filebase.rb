class Fulfillment
  def filebase(request, userinfo)
    case request[:Content][:Request]
    when "INIT"
      ticket = AP.getsafeid($filebase_tickets.keys)
      $filebase_tickets[ticket] = {
        :code=>AP.getsafeid(FileBase.list($config[:DBpath]), 20),
        :name=>request[:Content][:Name],
        :ext=>request[:Content][:Ext],
        :date=>request[:Content][:Date],
        :keywords=>request[:Content][:Keywords],
        :owner=>request[:Content][:Owner] ? request[:Content][:Owner] : userinfo[0],
        :minPW=>request[:Content][:minPW] ? request[:Content][:minPW] : userinfo[1]
      }
      return {:Content=>{:Response=>"Registered", :Ticket=>ticket}}, true
    when "SUBMIT"
      ticket = request[:Content][:Ticket]
      if $filebase_tickets[ticket] != nil
        data = $filebase_tickets[ticket]
        FileUtils.cp("#{$config[:BayPath]}/#{ticket}.#{data[:ext]}", "#{$config[:DBpath]}/#{data[:code]}.#{data[:ext]}")
        FileUtils.rm("#{$config[:BayPath]}/#{ticket}.#{data[:ext]}")
        
        FileBase.add($config[:DBpath], data)

        newhash = {}
        for key in $filebase_tickets.keys
          key != ticket ? newhash[key] = $filebase_tickets[key] : nil
        end
        $filebase_tickets = newhash

        return {:Content=>{:Response=>"Saved"}}, true
      else
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Ticket does not exists"}}, true
      end
    end
  end
end

$filebase_tickets = {}


class OnServerStartup
  def self.filebase_create_subfolders()
    FileUtils.mkdir_p("#{$config[:DBpath]}/.db")
  end

  def self.filebase_create_registry()
    if !File.exist?("#{$config[:DBpath]}/.db/registry")
      File.open("#{$config[:DBpath]}/.db/registry", "w") do |f1|
        f1.print ""
      end
    end
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
    if File.exist?("#{path}/.db/registry")
      db = eval("[" + File.open("#{path}/.db/registry").readlines.join("") + "]")
      if db.nil?
        return []
      else
        return db
      end
    else
      return []
    end
  end

  def FileBase::check(path) # Deletes non existing files
    db = FileBase.load(path)
    db.each_with_index do |entry, i|
      File.exist?("#{path}/#{entry}") ? nil : db.delete_at(i)
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
