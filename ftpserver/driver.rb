PWD = "ciao"
BASEPATH = "C:/Users/Java/Desktop"


class FTPDriver
  def authenticate(user, pass, &block)
    case user
    when "Gabriel"
      yield pass == "ciao"
    else
      yield false
    end
  end

  def bytes(path, &block)
    if File.exist?(path)
      yield File.size(path)
    else
      yield nil
    end
  end

  def change_dir(path, &block)
    yield path.include?(BASEPATH)
  end

  def dir_contents(path, &block)
    if File.exist?(path) && File.file?(path)
      yield Dir.entries(path)[2..-1]
    else
      yield nil
    end
  end

  def delete_dir(path, &block)
    yield !File.exist?(path)
  end

  def delete_file(path, &block)
    yield !File.exist?(path)
  end

  def rename(from_path, to_path, &block)
    if !File.exist?(from_path)
      yield File.exist?(to_path)
    else
      yield false
    end  
  end

  def make_dir(path, &block)
    yield File.exist?(path)
  end

  def get_file(path, &block)
    if path.include?(BASEPATH)
      yield File.new(path)
    else
      yield nil
    end
  end

  def put_file(path, tmp_file_path, &block)
    if File.exist?(path)
      yield File.size(path)
    else
      yield false
    end
  end
end
