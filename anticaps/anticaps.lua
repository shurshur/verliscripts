-- anticaps.lua
-- v 2006-10-10
-- (c) Shurik & Vipous, 2006
-- TODO: cleanup
-- Может распространяться только по условиям лицензии GNU GPL версии 3.0 или выше.
-- //May be redistributed only under terms of GNU GPL version 3.0 or higher.//

dofile("/etc/verlihub/scripts/functions.lua.inc");

-- Botname
botname = "-Aliki-"
-- Message less than minchecklen will not be checked for capslock
minchecklen = 16
-- Maximum percents of upper letters
maxuppers = 40

--VH_OnParsedMsgChat
function VH_OnParsedMsgChat(nick, data)
	l = string.len(data);
	if l<minchecklen then
		return 1
	end
	if string.find(data,"urn:tree:tiger") then
		return 1
	end
	s = 0
	a = 0
	for i=1,l do
		c = string.sub(data,i,i)
		l = UtilFunk.lower(c)
		u = UtilFunk.upper(c)
--		MsgUser(botname,nick,"check char " .. i .. ": c=[" .. c .. "] l=[" .. l .. "] u=[" .. u .. "]")
		if not (c==l) then
			s=s+1
		end
		if not (u==l) then
			a=a+1
		end
	end
	if a==0 then
		p=0
	else
		p=100*s/a
	end
	if p > maxuppers then
		p = string.format("%.2f",p)
		MsgUser(botname,nick,"Тест на capslock: " .. s .. "/" .. a .. ", " .. p .. "% заглавных букв, сообщение не пропущено в чат!")
		return 0
	end
	return 1
end

UtilFunk ={}

UtilFunk.lower = function (str)
	for x=192,223 do
		str=string.gsub(str, string.char(x),string.char(x+32))
	end
	for x=65,90 do
		str=string.gsub(str, string.char(x),string.char(x+32))
	end
	return str
end

UtilFunk.upper = function (str)
	for x=192+32,223+32 do
		str=string.gsub(str, string.char(x),string.char(x-32))
	end
	for x=65+32,90+32 do
		str=string.gsub(str, string.char(x),string.char(x-32))
	end
	return str
end

UtilFunk.lowerr = function (str)
	for x=192,223 do
	    rep="([А-Я])("..string.char(x)..")".."([А-Я])"
	    repto="%1"..string.char(x+32).."%3"
	    str=string.gsub(str, rep,repto)
	end  
	for x=65,90 do
		rep="([A-Z])("..string.char(x)..")".."([A-Z])"
	    repto="%1"..string.char(x+32).."%3"
	    str=string.gsub(str, rep,repto)
	end
	return str
end
