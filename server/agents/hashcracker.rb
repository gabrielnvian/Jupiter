require "digest"

class Fulfillment
  def hashcracker(request, userinfo)
    def buildString(indexes, chars)
      str = ""
      for i in indexes
        str += chars[i]
      end
      return str
    end

    def increaseIndex(indexes, chars)
      if indexes[-1] < chars.length - 1
        indexes[-1] += 1
      elsif indexes[-1] == chars.length - 1
        indexes = increaseLast(indexes, chars)
      end
      return indexes
    end

    def increaseLast(indexes, chars)
      (indexes.length - 2).downto(0).each do |i|
        if indexes[i] < chars.length - 1
          indexes[i] += 1
          for j in (i + 1)...indexes.length
            indexes[j] = 0
          end
          return indexes
        end
      end
      indexes.unshift(0)
      for k in 0...indexes.length
        indexes[k] = 0
      end
      return indexes
    end

    hashtoc = request[:Content][:Hash].to_s.downcase()
    hashtype = request[:Content][:Hashtype] ? request[:Content][:Hashtype].downcase() : "md5"
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    indexes = [0]

    if File.exist?("agents/files/hashcracker/#{hashtype}/#{hashtoc}.txt")
      File.open("agents/files/hashcracker/#{hashtype}/#{hashtoc}.txt", "r") do |f1|
        return {:Content=>{:Response=>f1.gets.chomp, :Cached=>true, Time=>0}}, true
      end
    else
      time1 = Time.new.to_i
      text = ""
      if hashtype == "md5"
        while true
          text = buildString(indexes, chars)
          break if Digest::MD5.hexdigest(text).downcase() == hashtoc
          indexes = increaseIndex(indexes, chars)
        end
        File.open("agents/files/hashcracker/md5/#{hashtoc}.txt", "w") do |f1|
          f1.puts text
        end
      end
      time2 = Time.new.to_i
      return {:Content=>{:Response=>text, :Cached=>false, :Time=>time2-time1}}, true
    end

    return {:Content=>{:Response=>"Hello World! :D"}}, true
  end
end


class OnServerStartup
end
