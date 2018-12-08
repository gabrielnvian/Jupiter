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

			agents.each do |agent|
				if agent[:active]
					FileUtils.mkdir_p("agents/files/#{agent[:name]}")
					agent[:folders].each do |folder|
						FileUtils.mkdir_p("agents/files/#{agent[:name]}/#{folder}")
					end
					load "agents/#{agent[:name]}.rb"
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
		agents.each do |agent|
			return true if agent[:name] == agentname
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
