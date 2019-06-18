class Fulfillment
  def filebase(request, userinfo)
    case request[:Cont][:Req]
    when 'SUBMIT'
      # move file
      # respond
    when 'CANCEL'
      # delete file
      # respond
    when 'LIST'
      # list all registered files
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
  def self.load(path = 'agents/files/filebase/registry.json')
    JSON.parse File.readlines(path).join('').chomp
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
  end

  # Add file to registry
  def self.add(item, path = 'agents/files/filebase/registry.json')
    reg = FileBase.load(path)
    return false unless FileBase.validate(item)

    reg.push(item)
  end

  # Delete file from registry
  def self.del(path = 'agents/files/filebase/registry.json', uid)
    reg = FileBase.load(path)
    reg.each_with_index do |entry, i|
      reg.delete_at(i) if entry[:uid] == uid
    end
    reg
  end

  # Generates a new registry from the files found
  def self.regen(path = 'agents/files/filebase/registry.json')
    reg = []
    uids = FileBase.get_uids(path) || []
    Dir.entries(path)[2..-1].each do |entry|
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
  def self.get_uids(path = 'agents/files/filebase/registry.json')
    return false unless File.exist?(path)

    uids = []
    FileBase.load(path).each do |entry|
      uids.push(entry[:uid])
    end
    uids
  end

  # List all files in registry
  def self.list(path)
  end

  # Query by ...
  def self.query_name(query, user, power)
  end

  def self.query_keywords(query, user, power)
  end

  def self.query_owner(query, user, power)
  end

  def self.query_before(query, user, power)
  end

  def self.query_after(query, user, power)
  end
end
