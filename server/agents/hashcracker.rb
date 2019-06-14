class Fulfillment
  def hashcracker(req, userinfo)
    hashtoc = req[:Cont][:Hash].to_s.downcase
    hashtype = req[:Cont][:Hashtype] ? req[:Cont][:Hashtype].downcase : 'md5'
    chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    indexes = [0]

    if File.exist?("agents/files/hashcracker/#{hashtype}/#{hashtoc}.txt")
      File.open("agents/files/hashcracker/#{hashtype}/#{hashtoc}.txt", 'r') do |f1|
        next { Cont: { Resp: f1.gets.chomp, Cached: true, Time: 0 } }, true
      end
    else
      time1 = Time.new.to_i
      text = ''
      if hashtype == 'md5'
        loop do
          text = build_string(indexes, chars)
          break if Digest::MD5.hexdigest(text).downcase == hashtoc

          indexes = increase_index(indexes, chars)
        end
        File.open("agents/files/hashcracker/md5/#{hashtoc}.txt", 'w') do |f1|
          f1.puts text
        end
      end
      time2 = Time.new.to_i
      [{ Cont: { Resp: text, Cached: false, Time: time2 - time1 } }, true]
    end
  end

  def build_string(indexes, chars)
    str = ''
    indexes.each do |i|
      str += chars[i]
    end
    str
  end

  def increase_index(indexes, chars)
    if indexes[-1] < chars.length - 1
      indexes[-1] += 1
    elsif indexes[-1] == chars.length - 1
      indexes = increase_last(indexes, chars)
    end
    indexes
  end

  def increase_last(indexes, chars)
    (indexes.length - 2).downto(0).each do |i|
      next unless indexes[i] < chars.length - 1

      indexes[i] += 1
      ((i + 1)...indexes.length).each do |j|
        indexes[j] = 0
      end
      return indexes
    end
    indexes.unshift(0)
    (0...indexes.length).each do |k|
      indexes[k] = 0
    end
    indexes
  end
end

class OnServerStartup
end
