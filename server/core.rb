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

  def AP::agentcommand?(agents, agentname, command)
    for agent in agents
      return true if agent[:name] == agentname && agent[:commands].include?(command)
    end
    return false
  end
end
