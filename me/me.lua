-- me.lua 1.0
-- by Shurik
-- May be redistributed only under terms of GNU GPL version 3.0 or higher.

function VH_OnParsedMsgChat(nick, data)
  if (string.find(data,"^/me%s")) then
  	_, _, action = string.find(data,"^/me%s+(.+)")
	VH:SendDataToAll("** "..nick.." "..action.."|",0,10)
	return 0
  end
  return 1
end

