def authenticate(user, pass, &block)
  case user
  when "Gabriel"
    return pass == "ciao"
  else
    return false
  end
end

bytes(path, &block)
- an integer with the number of bytes in the file or nil if the file
  doesn't exist

change_dir(path, &block)
- a boolen indicating if the current user is permitted to change to the
  requested path

dir_contents(path, &block)
- an array of the contents of the requested path or nil if the dir
  doesn't exist. Each entry in the array should be
  EM::FTPD::DirectoryItem-ish

delete_dir(path, &block)
- a boolean indicating if the directory was successfully deleted

delete_file(path, &block)
- a boolean indicating if path was successfully deleted

rename(from_path, to_path, &block)
- a boolean indicating if from_path was successfully renamed to to_path

make_dir(path, &block)
- a boolean indicating if path was successfully created as a new directory

get_file(path, &block)
- nil if the user isn't permitted to access that path
- an IOish (File, StringIO, IO, etc) object with data to send back to the
  client
- a string with the file data to send to the client
- an array of strings to join with the standard FTP line break and send to
  the client