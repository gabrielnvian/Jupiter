require "ftpd"

PWD = "ciao"

# class CustomFileSystem
#   def initialize(user)
#     @user = user
#   end

#   def accessible?(ftp_path)
#     true
#   end

#   def directory?(ftp_path)
#     true
#   end

#   def exists?(ftp_path)
#     true
#   end

#   def append(ftp_path)
#     true
#   end

#   def delete(ftp_path)
#     true
#   end

#   def dir(ftp_path)
#     true
#   end

#   def file_info(ftp_path)
#     true
#   end

#   def mkdir(ftp_path)
#     true
#   end

#   def read(ftp_path)
#     true
#   end

#   def rename(ftp_path)
#     true
#   end

#   def rmdir(ftp_path)
#     true
#   end

#   def write(ftp_path, stream)
#     puts "Received upload"
#     puts "User: #{@user}"
#     puts "ftp_path: #{@ftp_path}"
#     puts "byte count: #{stream.read.size}"
#   end
# end

class Driver

  def initialize(dir)
    @dir = dir
  end

  def authenticate(user, password)
    case user
    when "Gabriel"
      return password == PWD
    else
      return false
    end
  end

  def file_system(user)
    # return CustomFileSystem.new(user)
    Ftpd::DiskFileSystem.new("E:/")
  end

end

driver = Driver.new("C:/Users/ImGek/Desktop/")
server = Ftpd::FtpServer.new(driver)
server.port = 21
server.start
puts "Server listening on port #{server.bound_port}"
gets
