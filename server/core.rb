module Jupiter
  def self.getsafeid(array, len = 4)
    id = SecureRandom.hex(len / 2)
    id = SecureRandom.hex(len / 2) while array.include?(id)
    id
  end

  def self.serialize(str, len, char = '0') # DEPRECATED
    char * (len - str.length) + str
  end

  def self.getagents
    LOG.debug('Caricamento agenti...')
    begin
      needed_install = false
      agents = []
      Dir.entries('agents/conf')[2..-1].each do |file|
        conf = File.readlines("agents/conf/#{file}").join('')
        agents.push(Jupiter.jsontosym(JSON.parse(conf)))
      end
      agents.each_with_index do |agent, i|
        if agent[:active]
          FileUtils.mkdir_p("agents/files/#{agent[:name]}")

          Jupiter.getagents_folders(agent)

          agent[:dependencies].each do |dependency|
            begin
              require dependency
            rescue LoadError
              needed_install = true
              Jupiter.getagents_install(agent)
            end
          end

          load "agents/#{agent[:name]}.rb"
        else
          # If agent is not active delete it from the list
          agents.delete_at(i)
        end
      end

      if needed_install
        LOG.fatal("E' necessario riavviare per completare l'installazione delle librerie")
        exit!
      end

      LOG.debug("Agenti attivi: #{agents}")

      return agents
    rescue
      LOG.error('Caricamento agenti fallito')
      LOG.debug($ERROR_INFO)
      LOG.debug($ERROR_INFO.backtrace)
      return nil
    end
  end

  def self.getagents_folders(agent)
    agent[:folders].each do |folder|
      FileUtils.mkdir_p("agents/files/#{agent[:name]}/#{folder}")
    end
  end

  def self.getagents_install(agent)
    begin
      LOG.info("Installazione libreria \"#{dependency}\" richiesta da \"#{agent[:name]}\"")
      system("gem install #{dependency} >nul")
      LOG.info("Libreria \"#{dependency}\" installata con successo per \"#{agent[:name]}\"")
    rescue
      LOG.error("Installazione libreria \"#{dependency}\" per \"#{agent[:name]}\" fallita")
    end
  end

  def self.getagentminpower(agents, agentname, command)
    agents.each do |agent|
      if agent[:name] == agentname.downcase && agent[:commands].keys.include?(command.upcase)
        return agent[:commands][command.upcase]
      end
    end
  end

  def self.agentcommand?(agents, agname, cmd)
    agents.each do |agent|
      agent[:name] == agname.downcase && agent[:commands].keys.include?(cmd.upcase)
    end
    false
  end

  def self.jsontosym(h)
    newhash = {}
    h.keys.each do |key|
      # If value is an hash call this method on it
      newhash[key.to_sym] = h[key].is_a?(Hash) ? Jupiter.jsontosym(h[key]) : h[key]
    end
    newhash
  end
end
