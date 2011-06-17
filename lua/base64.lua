-----------------------------------------------------------------------------
-- base64 convertion routines for the Lua language
-- Author: Diego Nehab
-- Date: 26/12/2000
-- Conforms to: RFC 1521
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Direct and inverse convertion tables
-----------------------------------------------------------------------------
local t64 = {
	[0] = 'A', [1] = 'B', [2] = 'C', [3] = 'D', [4] = 'E', [5] = 'F', [6] = 'G',
	[7] = 'H', [8] = 'I', [9] = 'J', [10] = 'K', [11] = 'L', [12] = 'M',
	[13] = 'N', [14] = 'O', [15] = 'P', [16] = 'Q', [17] = 'R', [18] = 'S',
	[19] = 'T', [20] = 'U', [21] = 'V', [22] = 'W', [23] = 'X', [24] = 'Y',
	[25] = 'Z', [26] = 'a', [27] = 'b', [28] = 'c', [29] = 'd', [30] = 'e',
	[31] = 'f', [32] = 'g', [33] = 'h', [34] = 'i', [35] = 'j', [36] = 'k',
	[37] = 'l', [38] = 'm', [39] = 'n', [40] = 'o', [41] = 'p', [42] = 'q',
	[43] = 'r', [44] = 's', [45] = 't', [46] = 'u', [47] = 'v', [48] = 'w',
	[49] = 'x', [50] = 'y', [51] = 'z', [52] = '0', [53] = '1', [54] = '2',
	[55] = '3', [56] = '4', [57] = '5', [58] = '6', [59] = '7', [60] = '8',
	[61] = '9', [62] = '+', [63] = '/', 
}

local f64 = {
	['A'] = 0, ['B'] = 1, ['C'] = 2, ['D'] = 3, ['E'] = 4, ['F'] = 5, ['G'] = 6,
	['H'] = 7, ['I'] = 8, ['J'] = 9, ['K'] = 10, ['L'] = 11, ['M'] = 12,
	['N'] = 13, ['O'] = 14, ['P'] = 15, ['Q'] = 16, ['R'] = 17, ['S'] = 18,
	['T'] = 19, ['U'] = 20, ['V'] = 21, ['W'] = 22, ['X'] = 23, ['Y'] = 24,
	['Z'] = 25, ['a'] = 26, ['b'] = 27, ['c'] = 28, ['d'] = 29, ['e'] = 30,
	['f'] = 31, ['g'] = 32, ['h'] = 33, ['i'] = 34, ['j'] = 35, ['k'] = 36,
	['l'] = 37, ['m'] = 38, ['n'] = 39, ['o'] = 40, ['p'] = 41, ['q'] = 42,
	['r'] = 43, ['s'] = 44, ['t'] = 45, ['u'] = 46, ['v'] = 47, ['w'] = 48,
	['x'] = 49, ['y'] = 50, ['z'] = 51, ['0'] = 52, ['1'] = 53, ['2'] = 54,
	['3'] = 55, ['4'] = 56, ['5'] = 57, ['6'] = 58, ['7'] = 59, ['8'] = 60,
	['9'] = 61, ['+'] = 62, ['/'] = 63, 
}

-----------------------------------------------------------------------------
-- Converts a three byte sequence into its four character base64 
-- representation
-----------------------------------------------------------------------------
local t2f = function(a,b,c)
	local s = strbyte(a)*65536 + strbyte(b)*256 + strbyte(c) 
	local ca, cb, cc, cd
	cd = mod(s, 64)
	s = (s - cd) / 64
	cc = mod(s, 64)
	s = (s - cc) / 64
	cb = mod(s, 64)
	ca = (s - cb) / 64
	return %t64[ca] .. %t64[cb] .. %t64[cc] .. %t64[cd]
end

-----------------------------------------------------------------------------
-- Converts a four character base64 representation into its three byte
-- sequence
-----------------------------------------------------------------------------
local f2t = function(a,b,c,d)
	local s = %f64[a]*262144 + %f64[b]*4096 + %f64[c]*64 + %f64[d] 
	local ca, cb, cc
	cc = mod(s, 256)
	s = (s - cc) / 256
	cb = mod(s, 256)
	ca = (s - cb) / 256
	return strchar(ca, cb, cc)
end

-----------------------------------------------------------------------------
-- Creates a base64 representation of an incomplete last block
-----------------------------------------------------------------------------
local to64pad = function(s)
	local a, b, ca, cb, cc
	_,_, a, b = strfind(s, "(.?)(.?)")
	if b == "" then 
		s = strbyte(a)*16
		cb = mod(s, 64)
		ca = (s - cb)/64
		return %t64[ca] .. %t64[cb] .. "=="
	end
	s = strbyte(a)*1024 + strbyte(b)*4
	cc = mod(s, 64)
	s = (s - cc) / 64
	cb = mod(s, 64)
	ca = (s - cb)/64
	return %t64[ca] .. %t64[cb] .. %t64[cc] .. "="
end

-----------------------------------------------------------------------------
-- Decodes the base64 representation of an incomplete last block
-----------------------------------------------------------------------------
local from64pad = function(s)
	local a, b, c, d
	local ca, cb
	_,_, a, b, c, d = strfind(s, "(.)(.)(.)(.)")
	if d ~= "=" then return %f2t(a,b,c,d) 
	elseif c ~= "=" then
		s = %f64[a]*1024 + %f64[b]*16 + %f64[c]/4
		cb = mod(s, 256)
		ca = (s - cb)/256
		return strchar(ca, cb)
	else
		s = %f64[a]*4 + %f64[b]/16 
		ca = mod(s, 256)
		return strchar(ca)
	end
end

-----------------------------------------------------------------------------
-- Encodes a string into its base64 representation
-- Input 
--   s: binary string to be encoded
-- Returns
--   string with corresponding base64 representation
-----------------------------------------------------------------------------
function base64(s)
	local l = strlen(s)
	local m = mod(l, 3)
	l = l - m
	if l > 0 then whole = gsub(strsub(s, 1, l), "(.)(.)(.)", %t2f)
	else whole = "" end
	if m > 0 then pad = %to64pad(strsub(s, l+1))
	else pad = "" end
	return whole .. pad
end

-----------------------------------------------------------------------------
-- Decodes a string from its base64 representation
-- Input 
--   s: base64 string
-- Returns
--   decoded binary string
-----------------------------------------------------------------------------
function unbase64(s)
	s = gsub(s, "%s", "")
	local l = strlen(s)
	local whole, pad
	if l > 4 then whole = gsub(strsub(s, 1, -5), "(.)(.)(.)(.)", %f2t)
	else whole = "" end
	pad = %from64pad(strsub(s, -4))
	return whole .. pad
end
