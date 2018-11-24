module HTTPMethods
	def HTTPMethods::function(socket, path, args)
		if File.exist?(path) && !File.directory?(path) # 200 OK
			APHT::streamFile(path, socket)
		else # 404 Not Found
			APHT::streamFile("service/404.html", socket, "400 Bad Request")
		end
	end
end
