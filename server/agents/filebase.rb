class Fulfillment
  def filebase(request, userinfo)
    case request[:Cont][:Req]
    when 'ADD'
      item = request[:Cont][:Data] # name, ext, owner, power, kwords
      item[:uid] = Jupiter.getsafeid(FileBase.get_uids, 10)
      return { Code: '400 Bad Request', Cont: { Resp: 'Dati non validi' } }, true unless FileBase.validate(item)

      FileUtils.mv("#{CONFIG[:FTPuserPath]}/#{item[:name]}.#{item[:ext]}", "agents/files/filebase/db/#{item[:uid]}.filebase")
      FileBase.add(item)
      [{ Cont: { Resp: lang(LANG::FILEBASE_FILE_ADDED) } }, true]
    when 'DEL'
      # delete file
      # respond
    when 'LIST'
      files = FileBase.list(userinfo[0])
      if files.empty?
        return { Cont: { Resp: lang(LANG::FILEBASE_NO_FILE_TO_SHOW), Data: [] } }, true
      else
        return { Cont: { Resp: lang(LANG::FILEBASE_FILE_LIST, userinfo[0]), Data: files } }, true
      end
    when 'QUERY'
      # query through registered files
    end
  end
end


class OnServerStartup
  def self.filebase_create_subfolders
    FileUtils.mkdir_p('agents/files/filebase/db')
  end

  def self.filebase_create_registry
    return true if File.exist?('agents/files/filebase/registry.json')

    File.open('agents/files/filebase/registry.json', 'w') do |f1|
      f1.print ''
    end
  end
end


module FileBase
  # Parse registry
  def self.load
    Jupiter.jsontosym JSON.parse(File.readlines.join('').chomp)
  end

  # Validates the item
  def self.validate(item)
    item = Jupiter.jsontosym(item)
    return false if item.keys.include? :uid
    return false if item[:uid].length != 10
    return false if item.keys.include? :name
    return false if item[:name].nil?
    return false if item.keys.include? :ext
    return false if item[:ext].nil?
    return false if item.keys.include? :owner
    return false if item[:owner].nil?
    return false if item.keys.include? :kwords
    return false unless item[:kwords].is_a?(Array)

    item[:power] = 10 if item[:power] > 10
  end

  # Add file to registry
  def self.add(item)
    reg = FileBase.load
    return false unless FileBase.validate(item)

    reg.push(item)
  end

  # Delete file from registry
  def self.del(uid)
    reg = FileBase.load
    reg.each_with_index do |entry, i|
      reg.delete_at(i) if entry[:uid] == uid
    end
    reg
  end

  # Generates a new registry from the files found
  def self.regen
    reg = []
    uids = FileBase.get_uids || []
    Dir.entries[2..-1].each do |entry|
      h = {
          uid: Jupiter.getsafeid(uids, 10),
          name: entry.split('.'[0..-2].join('.')),
          ext: entry.split('.')[-1],
          owner: nil,
          kwords: ['unknown']
      }
      reg.push(h)
    end
    reg
  end

  # Returns an array containing all uids
  def self.get_uids
    return false unless File.exist?('agents/files/filebase/registry.json')

    uids = []
    FileBase.load.each do |entry|
      uids.push(entry[:uid])
    end
    uids
  end

  # Returns attribute of uid entry
  def self.getattr(uid, attr)
    FileBase.load.each do |entry|
      return entry[attr] if entry[:uid] == uid
    end
    nil
  end

  # Returns true if user has access to file
  def self.has_access(uid, user)
    return true if Auth.getpower(user) >= FileBase.getpower(uid)

    return true if FileBase.getattr(uid, :name) == user

    false
  end

  # Returns all files the user has access to
  def self.list(user)
    results = []
    FileBase.load.each do |entry|
      results.push(entry) if FileBase.has_access(entry[:uid], user)
    end
    results
  end

  # Query by ...
  def self.query_name(query, user)
    results = []
    FileBase.load.each do |entry|
      results.push(entry) if entry[:name].include?(query) && FileBase.has_access(entry[:uid], user)
    end
    results
  end

  def self.query_keywords(query, user)
    results = []
    FileBase.load.each do |entry|
      results.push(entry) if entry[:keywords].include?(query) && FileBase.has_access(entry[:uid], user)
    end
    results
  end

  def self.query_owner(query, user)
    results = []
    FileBase.load.each do |entry|
      results.push(entry) if entry[:owner] == query && FileBase.has_access(entry[:uid], user)
    end
    results
  end

  def self.query_before(query, user)
    results = []
    FileBase.load.each do |entry|
      ctime = File.ctime("agents/files/filebase/db/#{entry[:name]}.#{entry[:ext]}").to_i
      results.push(entry) if ctime < query.to_i && FileBase.has_access(entry[:uid], user)
    end
    results
  end

  def self.query_after(query, user)
    results = []
    FileBase.load.each do |entry|
      ctime = File.ctime("agents/files/filebase/db/#{entry[:name]}.#{entry[:ext]}").to_i
      results.push(entry) if ctime > query.to_i && FileBase.has_access(entry[:uid], user)
    end
    results
  end
end
