-----------------------------------------------------------------------------
-- UDP sample: echo protocol server
-- LuaSocket sample files
-- Author: Diego Nehab
-- RCS ID: $Id: echosrvr.lua,v 1.6 2003/08/16 00:06:04 diego Exp $
-----------------------------------------------------------------------------
host = host or "127.0.0.1"
port = port or 7
if arg then
    host = arg[1] or host
    port = arg[2] or port
end
print("Binding to host '" ..host.. "' and port " ..port.. "...")
udp, err = socket.udp()
assert(udp, err)
ret, err = udp:setsockname(host, port)
assert(ret, err) 
udp:settimeout(5)
ip, port = udp:getsockname()
assert(ip, port)
print("Waiting packets on " .. ip .. ":" .. port .. "...")
while 1 do
	dgram, ip, port = udp:receivefrom()
	if not dgram then print(ip) 
	else 
		print("Echoing from " .. ip .. ":" .. port)
		udp:sendto(dgram, ip, port)
	end
end
