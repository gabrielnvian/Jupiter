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

  def AP::getagents()
    AP.log("Loading agents...", nil)
    begin
      needed_install = false
      agents = eval(File.open("agents/agents.ini").readlines.join(""))
      agents.each_with_index do |agent, i|
        if agent[:active]
          FileUtils.mkdir_p("agents/files/#{agent[:name]}")
          
          for folder in agent[:folders]
            FileUtils.mkdir_p("agents/files/#{agent[:name]}/#{folder}")
          end

          for dependency in agent[:dependencies]
            begin
              require dependency
            rescue LoadError
              begin
                needed_install = true
                AP.log("Installing dependency \"#{dependency}\" for agent \"#{agent[:name]}\"", nil, "warning")
                system("gem install #{dependency} >nul")
                AP.log("Successfully installed \"#{dependency}\" for agent \"#{agent[:name]}\"", nil, "log")
              rescue
                AP.log("Failed to install dependency \"#{dependency}\" for agent \"#{agent[:name]}\"", nil, "error")
              end
            end
          end
          
          load "agents/#{agent[:name]}.rb"
        else
          agents.delete_at(i)
        end
      end

      if needed_install
        AP.log("Restart required after gem install", nil, "error")
        exit!
      end

      AP.log("Agents loaded: #{agents}", nil)
      
      return agents
    rescue
      AP.log("Error while parsing agents", nil, "error")
      AP.log($!, nil, "backtrace")
      AP.log($!.backtrace, nil, "backtrace")
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
