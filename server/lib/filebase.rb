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

  def FileBase::get(path, uid)
    db = FileBase.load(path)
    for entry in db
      return entry if entry[:uid] == uid
    end
    return false
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
      list.push(entry[:uid])
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
          for key in [:uid, :name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:name].downcase().include?(query.downcase())
            item2 = {}
            for key in [:uid, :name, :ext, :date, :keywords, :owner]
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
          for key in [:uid, :name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:keywords].include?(query)
            item2 = {}
            for key in [:uid, :name, :ext, :date, :keywords, :owner]
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
          for key in [:uid, :name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:owner] == query
            item2 = {}
            for key in [:uid, :name, :ext, :date, :keywords, :owner]
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
          for key in [:uid, :name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:date] < query.to_i
            item2 = {}
            for key in [:uid, :name, :ext, :date, :keywords, :owner]
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
          for key in [:uid, :name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          result.push(item2)
        end
      else
        if user == item[:owner]
          if item[:date] > query.to_i
            item2 = {}
            for key in [:uid, :name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            result.push(item2)
          end
        end
      end
    end
    return result
  end
end