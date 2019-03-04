class Fulfillment
  def filebase(request, userinfo)
    case request[:Content][:Request]
    when "UPLOAD"
      ticket = AP.getsafeid($filebase_tickets.keys)
      $filebase_tickets[ticket] = {
        :uid=>AP.getsafeid(FileBase.list($config[:DBpath]), 6),
        :name=>request[:Content][:Name],
        :ext=>request[:Content][:Ext],
        :date=>request[:Content][:Date],
        :keywords=>request[:Content][:Keywords],
        :owner=>request[:Content][:Owner] ? request[:Content][:Owner] : userinfo[0],
        :minPW=>request[:Content][:minPW] ? request[:Content][:minPW].to_i : userinfo[1]
      }
      return {:Content=>{:Response=>"Registrazione eseguita con successo", :Ticket=>ticket}}, true
    when "SUBMIT"
      ticket = request[:Content][:Ticket]
      if $filebase_tickets[ticket] != nil
        data = $filebase_tickets[ticket]
        FileUtils.cp("#{$config[:BayUPPath]}/#{ticket}.#{data[:ext]}", "#{$config[:DBpath]}/#{data[:uid]}.#{data[:ext]}")
        FileUtils.rm("#{$config[:BayUPPath]}/#{ticket}.#{data[:ext]}")
          
        data[:size] = File.size("#{$config[:DBpath]}/#{data[:uid]}.#{data[:ext]}")

        FileBase.add($config[:DBpath], data)

        newhash = {}
        for key in $filebase_tickets.keys
          key != ticket ? newhash[key] = $filebase_tickets[key] : nil
        end
        $filebase_tickets = newhash

        return {:Content=>{:Response=>"File aggiunto al database"}}, true
      else
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Prima di completare la registrazione e' necessario inviare i dati"}}, true
      end
    when "CANCEL"
      ticket = request[:Content][:Ticket]
      if $filebase_tickets[ticket] != nil
        newhash = {}
        for key in $filebase_tickets.keys
          key != ticket ? newhash[key] = $filebase_tickets[key] : nil
        end
        $filebase_tickets = newhash
        return {:Content=>{:Response=>"Registrazione annullato"}}, true
      else
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Il ticket di caricamento non esiste"}}, true
      end
    when "LIST"
      user = userinfo[0]
      power = userinfo[1]
      reg = FileBase.load($config[:DBpath])
      regtosend = []
      
      for item in reg
        if power >= item[:minPW]
          item2 = {}
          for key in [:uid, :name, :ext, :date, :keywords, :owner]
            item2[key] = item[key]
          end
          regtosend.push(item2)
        else
          if user == item[:owner]
            item2 = {}
            for key in [:uid, :name, :ext, :date, :keywords, :owner]
              item2[key] = item[key]
            end
            regtosend.push(item2)
          end
        end
      end
      return {:Content=>{:Response=>regtosend}}, true
    when "QUERY"
      user = userinfo[0]
      power = userinfo[1]
      type = request[:Content][:Type]
      query = request[:Content][:Query]

      case type
      when "name"
        result = FileBase::QueryName(query, user, power)
      when "keywords"
        result = FileBase::QueryKeywords(query, user, power)
      when "owner"
        result = FileBase::QueryOwner(query, user, power)
      when "before"
        result = FileBase::QueryBefore(query, user, power)
      when "after"
        result = FileBase::QueryAfter(query, user, power)
      else
        return {:Code=>"400 Bad Request", :Content=>{:Response=>"Opzione query invalida"}}, true
      end
      return {:Content=>{:Response=>result}}, true
    end
  end
end

$filebase_tickets = {}


class OnServerStartup
  def self.filebase_create_subfolders()
    FileUtils.mkdir_p("#{$config[:DBpath]}/.db")
    FileUtils.mkdir_p("#{$config[:DBpath]}/.backup")
  end

  def self.filebase_create_registry()
    if !File.exist?("#{$config[:DBpath]}/.db/registry")
      File.open("#{$config[:DBpath]}/.db/registry", "w") do |f1|
        f1.print ""
      end
    end
  end
end
