-- this examples needs it all
assert(dofile("../lua/code.lua"))
assert(dofile("../lua/ftp.lua"))
assert(dofile("../lua/concat.lua"))
assert(dofile("../lua/url.lua"))
assert(dofile("../lua/http.lua"))

-- formats a number of seconds into human readable form
function nicetime(s)
	local l = "s"
	if s > 60 then
		s = s / 60
		l = "m"
		if s > 60 then
			s = s / 60
			l = "h"
			if s > 24 then
				s = s / 24
				l = "d" -- hmmm
			end
		end
	end
	if l == "s" then return format("%2.0f%s", s, l)
	else return format("%5.2f%s", s, l) end
end

-- formats a number of bytes into human readable form
function nicesize(b)
	local l = "B"
	if b > 1024 then
		b = b / 1024
		l = "KB"
		if b > 1024 then
			b = b / 1024
			l = "MB"
			if b > 1024 then
				b = b / 1024
				l = "GB" -- hmmm
			end
		end
	end
	return format("%7.2f%2s", b, l)
end

-- returns a string with the current state of the download
function gauge(got, dt, size)
	local rate = got / dt
	if size and size >= 1 then
		return format("%s received, %s/s throughput, " ..
			"%.0f%% done, %s remaining", 
            nicesize(got),  
			nicesize(rate), 
			100*got/size, 
			nicetime((size-got)/rate))
	else 
		return format("%s received, %s/s throughput, %s elapsed", 
			nicesize(got), 
			nicesize(rate),
			nicetime(dt))
	end
end

-- creates a new instance of a receive_cb that saves to disk
-- kind of copied from luasocket's manual callback examples
function receive2disk(file, size)
	local aux = {
        start = _time(),
        got = 0,
        file = openfile(file, "wb"),
		size = size
    }
    local receive_cb = function(chunk, err)
        local dt = _time() - %aux.start          -- elapsed time since start
        if not chunk or chunk == "" then
			write("\n")
            closefile(%aux.file)
            return
        end
        write(%aux.file, chunk)
        %aux.got = %aux.got + strlen(chunk)      -- total bytes received
        if dt < 0.1 then return 1 end            -- not enough time for estimate
		write("\r", gauge(%aux.got, dt, %aux.size))
        return 1
    end
	return receive_cb
end

-- downloads a file using the ftp protocol
function getbyftp(url, file)
    local err = FTP.get_cb {
        url = url,
        content_cb = receive2disk(file),
        type = "i"
    }
	print()
	if err then print(err) end
end

-- downloads a file using the http protocol
function getbyhttp(url, file, size)
    local response = HTTP.request_cb(
        {url = url},
		{body_cb = receive2disk(file, size)} 
    )
	print()
	if response.code ~= 200 then print(response.status or response.error) end
end

-- determines the size of a http file
function gethttpsize(url)
	local response = HTTP.request {
		method = "HEAD",
 		url = url
	}
	if response.code == 200 then
		return tonumber(response.headers["content-length"])
	end
end

-- determines the scheme and the file name of a given url
function getschemeandname(url, name)
	-- this is an heuristic to solve a common invalid url poblem
	if not strfind(url, "//") then url = "//" .. url end
	local parsed = URL.parse_url(url, {scheme = "http"})
	if name then return parsed.scheme, name end
	local segment = URL.parse_path(parsed.path)
	name = segment[getn(segment)]
	if segment.is_directory then name = nil end
	return parsed.scheme, name
end

-- gets a file either by http or url, saving as name
function get(url, name)
	local scheme
    scheme, name = getschemeandname(url, name)
	if not name then print("unknown file name")
	elseif scheme == "ftp" then getbyftp(url, name)
	elseif scheme == "http" then getbyhttp(url, name, gethttpsize(url)) 
	else print("unknown scheme" .. scheme) end
end

-- main program
arg = arg or {}
if getn(arg) < 1 then 
	write("Usage:\n  luasocket -f get.lua <remote-url> [<local-file>]\n")
	exit(1)
else get(arg[1], arg[2]) end
