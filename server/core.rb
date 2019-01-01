module AP
  def AP::getsafeid(array, len = 4)
    id = SecureRandom.hex(len/2)
    while array.include?(id)
      id = SecureRandom.hex(len/2)
    end
    return id
  end

  def AP::serialize(str, len, char="0") # DEPRECATED
    return char*(len - str.length) + str
  end

  def AP::getagents(id, log = false)
    AP::log("Loading agents...", id)
    begin
      agents = eval(File.open("agents/agents.ini").readlines.join(""))
      agents.each_with_index do |agent, i|
        if agent[:active]
          FileUtils.mkdir_p("agents/files/#{agent[:name]}")
          for folder in agent[:folders]
            FileUtils.mkdir_p("agents/files/#{agent[:name]}/#{folder}")
          end
          load "agents/#{agent[:name]}.rb"
        else
          agents.delete_at(i)
        end
      end

      log ? AP::log("Agents loaded: #{agents}", id) : nil
      
      return agents
    rescue
      AP::log("Error while parsing agents", @id, "error")
      AP::log($!, @id, "backtrace")
      AP::log($!.backtrace, @id, "backtrace")
      return nil
    end
  end

  def AP::getagentminpower(agents, agentname, command)
    for agent in agents
      if agent[:name] == agentname.downcase && agent[:commands].keys.include?(command.upcase)
        return agent[:commands][command.upcase]
      end
    end
  end

  def AP::agentcommand?(agents, agentname, command)
    for agent in agents
      return true if agent[:name] == agentname.downcase && agent[:commands].keys.include?(command.upcase)
    end
    return false
  end

  def AP::jsontosym(h)
    newhash = {}
    for key in h.keys
      if h[key].kind_of?(Hash)
        newhash[key.to_sym] = AP.jsontosym(h[key])
      else
        newhash[key.to_sym] = h[key]
      end
    end
    return newhash
  end
end
