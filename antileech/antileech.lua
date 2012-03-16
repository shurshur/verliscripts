--[[
antileech.lua v 2009-06-22
Corbina edition
(c) Shurik, 2009
���������� ��� Corbina Central Hub
����� ���������������� ������ �� �������� �������� GNU GPL ������ 3.0 ��� ����.
//Specially for Corbina Central Hub//
//May be redistributed only under terms of GNU GPL version 3.0 or higher.//

������� �������� �� ���������� ��������: ������ ������������ ���� �����
���������� ���������� ����������� ������ ���� ��� �������� � ����.
��� �������� �� ������ ��������� maxper% �� ���� ������ ������������ � ����
������ maxlim ��.

��������, ����� maxper = 10%, maxlim = 200 ��. ����� ������������ � 50 ��
���� ����� ���������� ����� � 2 ��, � ��� ������������ � ������� �����
�� ������ � ���� ������. ������ 2 �� ����� ���� � ������ �����, �� �� ������
5 �� (10% �� 50 ��). � �� �� ����� ��� ������������ � ����� 5 �� �����������
��������� �������� ������ ���������� �� 500 �� (10% �� ����), � 200 ��, ��
���� �� ���� ���� ����������� ��������� ��, ������� ������.

���� ���� ������������ �� ��� ��� ���� �������� ���������� � �����
���������� ������������� �����������, �� ������� ����� �������������
��������. ������������ ����� �������������� �������� ��� ������� �
������� ��������� ������, ��������������� �����������.

�������:

+setlimit 25 - �������� ������� � ���������� ����� � 25 ��

+unsetlimit - ��������� �������

+getlimit - ������ ������� ��������� �������� (�������/�������� � �����)

���� �� ������������� RCTM �������������� �� ������� dlblock.lua.

� ���������, ��-�� ������������ ������� $Direction ��������� DC, ���� ���
������������ ����� ������� ������� ���� � �����, ������� � ������������
50% ����� �������� � ����, ��� ��� ��� ����� ����� ������ � ���������������.
� ���� ������ ������� ������, �� ������ �������� � ���� ����� ������
�������� ������ ������������.
--]]

dofile("/etc/verlihub/scripts/functions.lua.inc");
dofile("/etc/verlihub/scripts/parsemyinfo.lua.inc");

-- Botname (will be set to hub_security in Main)
botname = "FIXME"

-- MySQL table
tbl = "antileech"

-- maximum value for limit (Gb)
maxlim = 200

-- maximum value of limit/share (%)
maxper = 10

-- unit (Gb)
--unit = 1000*1000*1000
unit = 1024*1024*1024

-- Debug
debug = false
admin = "Shurik"

-- timer iterator
ti = 0
-- timer iterator max (300 seconds between reloads)
ti_max = 300
-- ttl for rctm records (seconds)
exceed = 30

limit = {
}

share = {
}

rctm = {
}

function Main()
	_, botname = VH:GetConfig("config","hub_security")
	query = "CREATE TABLE IF NOT EXISTS "..tbl.." (nick VARCHAR(255) NOT NULL PRIMARY KEY,`limit` INT NOT NULL DEFAULT 0)"
	res, err = VH:SQLQuery(query)
	if not res then
		Debug("ERROR in query "..query)
	end
	return 1
end

function VH_OnUserCommand(nick, data)
	if(string.find(data,"[%+]sss")) then
		local sha = defifnil(GetShare(nick), -1)
		MsgUser(botname, nick, "���� "..sha)
		return 0
	end
	if(string.find(data,"[%+]unsetlimit")) then
		UnsetLimit(nick)
		return 0
	end
	if(string.find(data,"[%+]setlimit%s")) then
		res, _, lim = string.find(data,"[%+]setlimit%s(%d+)")
		if not res then
			MsgUser(botname, nick, "����� �������� ������ ���� ������!")
			return 0
		end
		SetLimit(nick, tonumber(lim))
		return 0
	end
	if(string.find(data,"[%+]getlimit")) then
		lim = limit[nick]
		if lim == nil then
			MsgUser(botname, nick, "������� ��������")
			return 0
		end
		MsgUser(botname, nick, "������� �������, ����� "..lim.." ��")
		return 0
	end
	return 1
end

function VH_OnParsedMsgMyINFO(nick, data)
	local info = ParseMyInfo(nick, data)
	if not info then
		Debug("VH:MYINFO share for "..nick.." was not detected ["..data.."]")
		return 1
	end
	--Debug("MYINFO "..nick.." share="..info['share'])
	share[nick] = info['share']
	RecheckLimit(nick)
	return 1
end

function VH_OnUserLogout(nick)
	share[nick] = nil
	rctm[nick] = nil
	return 1
end

function VH_OnParsedMsgAny(nick, data)

	-- On RevConnectToMe
	if (string.sub(data, 1, 15) == "$RevConnectToMe") then
		-- Get the sender and receiver nicks
		local _, _, fromnick, tonick = string.find(data, "$RevConnectToMe%s+(%S+)%s+(%S+)" )
		lim = limit[tonick]
		vlim = lim
		if vlim == nil then
			vlim = 0
		end
		--Debug("RCTM "..fromnick.."->"..tonick.." limit "..vlim)
		sha = GetShare(fromnick)
		if vlim>0 and (sha == nil or (lim ~=nil and sha<lim*unit)) then
			MsgPm(botname,fromnick,"�� ������ ��������� �� ����� "..vlim.." ��, ����� ������ � ������������ "..tonick)
			--Debug("REJECT RCTM "..nick.."->"..tonick)
			return 0
		else
			rctm[tonick] = os.clock()
			--Debug("ACCEPT future CTM from RCTM for "..nick.."->"..tonick)
			return 1
		end
		--Debug("ACCEPT RCTM "..nick.."->"..tonick)
	-- On ConnectToMe
	elseif (string.sub(data, 1, 12) == "$ConnectToMe") then
		-- Get receiver nick
		local _, _, tonick = string.find(data, "$ConnectToMe%s+(%S+)%s+.*" )
		lim = limit[tonick]
		vlim = lim
		if vlim == nil then
			vlim = 0
		end
		--Debug("CTM "..nick.."->"..tonick.." vlim "..vlim)
		if rctm[nick] ~= nil then
			rctm[nick] = nil
			--Debug("ACCEPT CTM from RCTM for "..nick.."->"..tonick)
			return 1
		end
		sha = GetShare(nick)
		if vlim>0 and (sha == nil or (lim ~= nil and sha<lim*unit)) then
			MsgPm(botname,nick,"�� ������ ��������� �� ����� "..vlim.." ��, ����� ������ � ������������ "..tonick)
			--Debug("REJECT CTM "..nick.."->"..tonick)
			return 0
		end
		--Debug("ACCEPT CTM "..nick.."->"..tonick)
	end

	return 1

end

function VH_OnTimer()
	--Debug("timer")
	if ti == 0 then
		LoadLimits()
	end
	ti = ti + 1
	if ti == ti_max then
		ti = 0
	end
	now = os.clock()
	for n,t in pairs(rctm) do
		if t+exceed<now then
			rctm[nick] = nil
		end
	end
	return 1
end

function GetShare(nick)
	local sha = share[nick]
	if not sha then
		local data = GetMyInfo(nick)
		if not data then
			Debug("MYINFO for "..nick.." was not found")
			return 0
		end
		local info = ParseMyInfo(nick, data)
		if not info then
			Debug("MYINFO share for "..nick.." was not detected")
			return 0
		end
		sha = info['share']
		share[nick] = sha
	end
	return sha
end

function ClearLimit(nick)
	-- hack: don't clear limit if user is not logged in
	local ip = GetIp(nick)
	if not ip then
		return
	end
	limit[nick] = nil
	VH:SQLQuery("DELETE FROM "..tbl.." WHERE nick='"..nick.."'")
end

function CheckLimit(sha,lim)
	--Debug("CheckLimit("..sha..","..lim*unit..")")
	if lim ~= nil and ((lim*unit > maxper*sha/100) or (lim>maxlim)) then
		return false
	end
	return true
end

function RecheckLimit(nick)
	lim = limit[nick]
	sha = GetShare(nick)
	if lim ~= nil and sha~= nil and not CheckLimit(sha,lim) then
		Debug("Limit "..lim.." overflow for "..nick)
		ClearLimit(nick)
		--- ��������� ��������� �� ��������� ��� ������!!! ��� ������?
		MsgPm(botname,nick,"���� ���� � ��������� ������������ ��� ����, ����� ������������� ����������� � �������� � ������� "..lim.." ��, ������� ������� ��� ��������. �� ������ �������� ��� �����, ������ ������� �������� �����������.")
	end
end

function SetLimit(nick,lim)
	sha = GetShare(nick)
	if not sha then
		MsgUser(botname,nick,"������ ����������� ����� ����. ���������� ��������� �� ���")
		return 0
	end
	if CheckLimit(sha,lim) then
		limit[nick]=lim
		VH:SQLQuery("REPLACE INTO "..tbl.." (nick,`limit`) VALUES ('"..nick.."',"..lim..")")
		MsgUser(botname,nick,"����� �������� ���������� � "..lim.." ��")
		return 1
	end
	MsgUser(botname,nick,"����� �������� ������ ���� �� ������ "..maxper.."% ����� ���� � �� ������ "..maxlim.." ��")
	return 0
end

function UnsetLimit(nick,lim)
	ClearLimit(nick)
	MsgUser(botname,nick,"������� ��������")
end

function LoadLimits()
	--Debug("LoadLimits")
	limit = { }
	res, rows = VH:SQLQuery("SELECT nick,`limit` FROM "..tbl)
	if not res then
		Debug("ERROR query in LoadLimits")
		return 0
	end
	for x=0,rows-1 do
		res,nick,lim = VH:SQLFetch(x)
		lim = tonumber(lim)
		if lim and lim>0 then
			limit[nick]=lim
		end
		RecheckLimit(nick)
	end
	return 1
end

function Debug(msg)
	if debug then
		MsgUser(botname,admin,"DEBUG: "..msg)
	end
end

