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
        :minPW=>request[:Content][:minPW] ? request[:Content][:minPW].to_i : userinfo[1]
      }
      return {:Content=>{:Response=>"Registrazione eseguita con successo", :Ticket=>ticket}}, true
    when "SUBMIT"
      ticket = request[:Content][:Ticket]
      if $filebase_tickets[ticket] != nil
        data = $filebase_tickets[ticket]
        FileUtils.cp("#{$config[:BayPath]}/#{ticket}.#{data[:ext]}", "#{$config[:DBpath]}/#{data[:code]}.#{data[:ext]}")
        FileUtils.rm("#{$config[:BayPath]}/#{ticket}.#{data[:ext]}")
        
        data[:size] = File.size("#{$config[:DBpath]}/#{data[:code]}.#{data[:ext]}")

        FileBase.add($config[:DBpath], data)

        newhash = {}
        for key in $filebase_tickets.keys
          key != ticket ? newhash[key] = $filebase_tickets[key] : nil
        end
        $filebase_tickets = newhash

        return {:Content=>{:Response=>"File aggiunto al database"}}, true
      else
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Prima di completare la registrazione e' necessario inviare i dati"}}, true
      end
    when "CANCEL"
      ticket = request[:Content][:Ticket]
      if $filebase_tickets[ticket] != nil
        newhash = {}
        for key in $filebase_tickets.keys
          key != ticket ? newhash[key] = $filebase_tickets[key] : nil
        end
        $filebase_tickets = newhash
        return {:Content=>{:Response=>"Registrazione annullato"}}, true
      else
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Il ticket di caricamento non esiste"}}, true
      end
    when "LIST"
      user = userinfo[0]
      power = userinfo[1]
      reg = FileBase.load($config[:DBpath])
      regtosend = []
      
      for item in reg
        if power >= item[:minPW]
          item2 = {}
          for key in [:name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          regtosend.push(item2)
        else
          if user == item[:owner]
            item2 = {}
            for key in [:name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            regtosend.push(item2)
          end
        end
      end
      return {:Content=>{:Response=>regtosend}}, true
    when "QUERY"
      user = userinfo[0]
      power = userinfo[1]
      type = request[:Content][:Type]
      query = request[:Content][:Query]

      case type
      when "name"
        result = FileBase::QueryName(query, user, power)
      when "keywords"
        result = FileBase::QueryKeywords(query, user, power)
      when "owner"
        result = FileBase::QueryOwner(query, user, power)
      when "before"
        result = FileBase::QueryBefore(query, user, power)
      when "after"
        result = FileBase::QueryAfter(query, user, power)
      else
        return false
      end
      return {:Content=>{:Response=>result}}, true
    end
  end
end

$filebase_tickets = {}


class OnServerStartup
  def self.filebase_create_subfolders()
    FileUtils.mkdir_p("#{$config[:DBpath]}/.db")
    FileUtils.mkdir_p("#{$config[:DBpath]}/.backup")
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
      db = []
      for entry in File.readlines("#{path}/.db/registry")
        db.push(eval(entry))
      end
      return db
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

  def FileBase::QueryName(query, user, power)
    db = FileBase.load($config[:DBpath])
    result = []
    for item in db
      if power >= item[:minPW]
        if item[:name].downcase().include?(query.downcase())
          item2 = {}
          for key in [:name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:name].downcase().include?(query.downcase())
            item2 = {}
            for key in [:name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            result.push(item2)
          end
        end
      end
    end
    return result
  end

  def FileBase::QueryKeywords(query, user, power)
    db = FileBase.load($config[:DBpath])
    result = []
    for item in db
      if power >= item[:minPW]
        if item[:keywords].include?(query)
          item2 = {}
          for key in [:name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:keywords].include?(query)
            item2 = {}
            for key in [:name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            result.push(item2)
          end
        end
      end
    end
    return result
  end

  def FileBase::QueryOwner(query, user, power)
    db = FileBase.load($config[:DBpath])
    result = []
    query.nil? ? query = user : nil
    for item in db
      if power >= item[:minPW]
        if item[:owner] == query
          item2 = {}
          for key in [:name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:owner] == query
            item2 = {}
            for key in [:name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            result.push(item2)
          end
        end
      end
    end
    return result
  end

  def FileBase::QueryBefore(query, user, power)
    db = FileBase.load($config[:DBpath])
    result = []
    query.nil? ? query = Time.new.to_i : nil
    for item in db
      if power >= item[:minPW]
        if item[:date] < query.to_i
          item2 = {}
          for key in [:name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:date] < query.to_i
            item2 = {}
            for key in [:name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            result.push(item2)
          end
        end
      end
    end
    return result
  end

  def FileBase::QueryAfter(query, user, power)
    db = FileBase.load($config[:DBpath])
    result = []
    query.nil? ? query = Time.new.to_i : nil
    for item in db
      if power >= item[:minPW]
        if item[:date] > query.to_i
          item2 = {}
          for key in [:name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:date] > query.to_i
            item2 = {}
            for key in [:name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            result.push(item2)
          end
        end
      end
    end
    return result
  end


  def FileBase::snapshot(path)
  end
end
