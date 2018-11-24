# https://practicingruby.com/articles/implementing-an-http-file-server

require "socket"
require "uri"

require_relative "core.rb"
require_relative "config.rb"
require_relative "debug.rb"
require_relative "methods/get.rb"
require_relative "methods/function.rb"


server = TCPServer.new('localhost', 80)
APHT::log("Server listening...")

while true
	Thread.start(server.accept) do |socket|
		begin
			request = socket.gets # GET /file.txt HTTP/1.1

			APHT.log("<<<  " + request)

			httpmethod = request.split(" ")[0]
			args = request.split(" ")[1].split("?")[1].split("&")

			path = secureRequest(request.split(" ")[1])
			path = File.join(path, "index.html") if File.directory?(path)
			
			if httpmethod == "GET" && args.nil?
				APHT::HTTPMethods::get(socket, path, args)
			elsif httpmethod == "GET" && !args.nil?
				APHT::HTTPMethods::function(socket, path, args)
			else # 400 Bad Request
				APHT::streamFile("service/400.html", socket, "400 Bad Request")
			end

			socket.close
		rescue # 500 Internal Server Error
			APHT::streamFile("service/500.html", socket, "500 Internal Server Error")
		end
	end
end