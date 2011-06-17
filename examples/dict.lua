function get_status(sock, valid)
	local line, err = sock:receive()
	local code, par
	if not line then sock:close() return err end
	_, _, code = strfind(line, "^(%d%d%d)")
	code = tonumber(code)
	if code ~= valid then return code end
	if code == 150 then
		_,_,_, par = strfind(line, "^(%d%d%d) (%d*)")
		par = tonumber(par)
	end
	return nil, par
end

function get_def(sock)
	local line, err = sock:receive()
	local def = ""
	while (not err) and line ~= "." do
		def = def .. line .. "\n"
		line, err = sock:receive()
	end
	if err then sock:close() return nil, err 
	else return def end
end

function dict_open()
	local sock, err = connect("dict.org", 2628)
	if not sock then return nil, err end
	sock:timeout(10)
  	local code, par = get_status(sock, 220)
	if code then return nil, code end
	return sock
end

function dict_define(sock, word, dict)
	dict = dict or "web1913"
  	sock:send("DEFINE " .. dict .. " " .. word .. "\r\n")
  	local code, par = get_status(sock, 150)
	if code or not par then return nil, code end
	local defs = ""
	for i = 1, par do
		local def
  		code, par = get_status(sock, 151)
		if code then return nil, code end
		def, err = get_def(sock)
		if not def then return nil, err end
		defs = defs .. def .. "\n"
	end
  	code, par = get_status(sock, 250)
	if code then return nil, code end
	return gsub(defs, "%s%s$", "")
end

function dict_close(sock)
	sock:send("QUIT\r\n")
	local code, par = get_status(sock, 221)
	sock:close()
	return code
end

function dict_get(word, dict)
	local sock, err = dict_open()
	if not sock then return nil, err end
	local defs, err = dict_define(sock, word, dict)
	dict_close(sock)
	return defs, err
end
