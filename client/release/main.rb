require_relative "core.rb"
require_relative "usermgm.rb"

HOST, PORT = "localhost", 2556

$credentials = [nil, 0]
$server = nil

system("cls")

while true
  cmd = AP.input()

  case cmd.split(" ")[0]
  when "login"
    USERMGM.login(cmd.split(" ")[1], cmd.split(" ")[2])
  end
end
