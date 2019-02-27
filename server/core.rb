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
    AP.log("Caricamento agenti...", nil)
    begin
      needed_install = false
      libs = []
      agents = []
      for file in Dir.entries("agents/conf")[2..-1]
        agents.push(eval(File.readlines("agents/conf/#{file}").join("")))
      end
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
                AP.log("Installazione libreria \"#{dependency}\" richiesta da \"#{agent[:name]}\"", nil, "warning")
                system("gem install #{dependency} >nul")
                AP.log("Libreria \"#{dependency}\" installata con successo per \"#{agent[:name]}\"", nil, "log")
              rescue
                AP.log("Installazione libreria \"#{dependency}\" per \"#{agent[:name]}\" fallita", nil, "error")
              end
            end
          end

          for lib in agent[:libs]
            if File.exist?("lib/#{lib}.rb")
              libs.push(lib)
              require_relative "lib/#{lib}.rb"
            end
          end
          
          load "agents/#{agent[:name]}.rb"
        else
          agents.delete_at(i)
        end
      end

      if needed_install
        AP.log("E' necessario un riavvio per completare l'installazione delle librerie", nil, "error")
        exit!
      end

      AP.log("Agenti attivi: #{agents}", nil)
      
      return agents, libs
    rescue
      AP.log("Caricamento agenti fallito", nil, "error")
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
