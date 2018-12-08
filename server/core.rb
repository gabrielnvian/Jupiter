module AP
  def self.getsafeid(array, len = 4)
    id = SecureRandom.hex(len/2)
    while array.include?(id)
      id = SecureRandom.hex(len/2)
    end
    return id
  end

  def self.serialize(str, len, char="0") # DEPRECATED
    return char*(len - str.length) + str
  end

	def self.getagents(id, log = false)
		AP::log("Loading agents...", id)
		begin
			agents = eval(File.open("agents/agents.ini").readlines.join(""))

			for i in 0...agents.length
        if agents[i][:active]
  				FileUtils.mkdir_p("agents/files/#{agents[i][:name]}")
  				for j in 0...agents[i][:folders].length
  					FileUtils.mkdir_p("agents/files/#{agents[i][:name]}/#{agents[i][:folders][j]}")
  				end
  				load "agents/#{agents[i][:name]}.rb"
        else
          agents.delete_at(i)
        end
			end

      AP::log("Agents loaded: #{agents}", id) if log
			return agents
		rescue
			AP::log("Error while parsing agents", @id, "error")
			AP::log($!, @id, "backtrace")
			AP::log($!.backtrace, @id, "backtrace")
			return nil
		end
	end

	def self.agentexists?(agents, agentname)
		for i in 0...agents.length
			return true if agents[i][:name] == agentname
		end
		return false
	end

  def self.commandexists?(agents, agent, command)
    for i in 0...agents.length
      return true if agents[i][:name] == agent && agents[i][:commands].include?(command)
    end
    return false
  end
end
