require "openssl"

class Fulfillment
	def auth(request)
	  	case request[:Content][:Request]
	  	when "login"
	  	when "logout"
	  	when "edit"
	  	end

		return {:Code=>"400 Bad Request", :Content=>{:Response=>"Hash algorithm not supported"}}, true
		return {:Content=>{:Response=>newhash}}, true
	end
end


class OnServerStartup
end
