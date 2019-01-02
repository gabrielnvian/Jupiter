module AP
	def AP::log(text, id, prefix = "log")
		Dir.mkdir("logs") if !File.exist?("logs")
		if id == nil
			id = " - [7mSYSM[0m"
		else
			id = " - #{id}"
		end

		case prefix
		when "log"
			prefix = "[92m[  LOG  ][0m"
		when "error"
			prefix = "[91m[ ERROR ][0m"
		when "socket"
			prefix = "[92m[ SOCKT ][0m"
		when "server"
			prefix = "[92m[ SERVR ][0m"
		when "backtrace"
			prefix = "[93m[ TRACE ][0m"
		when "rawin"
			prefix = "[96m[ RAWIN ][0m"
		when "rawout"
			prefix = "[96m[ RAWOT ][0m"
		when "warning"
			prefix = "[93m[ WARNG ][0m"
		else
			prefix = "[91m[ NTDEF ][0m"
		end

		logfull1 = "[7m#{Time.new.strftime('%d/%m %H:%M:%S')}[0m #{prefix}#{id}  #{text}"
		logfull2 = "[7m#{Time.new.strftime('%d/%m/%Y %H:%M:%S')}[0m #{prefix}#{id}  #{text}"

		puts logfull1
		
		File.open("logs/latest.log", "a") do |f1|
			f1.puts logfull2
		end
	end
end
