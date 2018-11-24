module APHT
	def APHT::content_type(path)
		ext = File.extname(path).split(".").last
		CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
	end

	def APHT::securePath(request)
		path = URI.unescape(URI(request).path)

		clean = []

		path.split("/").each do |part|
			next if part.empty? || part == '.'
			part == '..' ? clean.pop : clean << part
		end

		File.join(WEB_ROOT, *clean)
	end

	def APHT::streamFile(file, socket, code = "200 OK")
		File.open(file, "rb") do |f1|
			socket.print "HTTP/1.1 #{code}\r\n" +
			"Content-Type: #{APHT::content_type(f1)}\r\n" +
			"Content-Length: #{f1.size}\r\n" +
			"Connection: close\r\n"
			socket.print "\r\n"
			IO.copy_stream(f1, socket)
		end
	end
end
