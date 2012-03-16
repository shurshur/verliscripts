--|                                                      |--
--| Common Functions Library v 3.1                       |--
--|     Author: Hellkeepa (hellkeeper_1@hotmail.com)     |--
--|                                                      |--
--| CopyLeft, but please let me know if you change       |--
--| anything. Always remember to credit original author: |--
--| No-one appreciates having their work stolen. ;-)     |--
--|                                                      |--
--| Code added by:                                       |--
--|     Hurbold (Admin @ VerliHub forum)                 |--
--|                                                      |--

--|                                                      |--
--| To use these functions simple require() the file     |--
--| into your existing script, and use them like like    |--
--| nothing happened. ;-)                                |--
--| You should place a note in your readme that users    |--
--| should make sure their "LUA_PATH" system variable is |--
--| correctly set, as it would prevent the script from   |--
--| working correctly otherwise.                         |--
--|                                                      |--
--| Updated versions of this script are to be found at   |--
--| the official VerliHUB WIKI, the direct address is:   |--
--|     www.verlihub.net/wiki/?VerlihubLuaScripts        |--
--| Just scroll down a bit, and you should see it. :-)   |--
--|                                                      |--

--[[ Changelog:
-- 3.1	Added HubSoft function "KickUser()".

-- 3.0	Added the following event handlers:
			** hub.OnUserLogout()
			** hub.Timer()
			** hub.GetChat()
			** hub.Unload()
		One HubSoft function:
			** RemoveBot()
		And the following user-function:
			** ParseMyInfo(nick)
		Thanks to Hurbold for that one. :-)

-- 2.0	Sectioned the library up a bit, and labeled the
		different sections. Also added four event handlers:
			** hub.OnOpCmd()
			** hub.OnUserCmd()
			** hub.OnUserLogin()
			** hub.GetPm()

-- 1.0	First revision, added the following functions:
			** SQ()
			** SF()
			** CloseConn()
			** MsgPm()
			** MsgUser()
			** MsgOps()
			** MsgMain()
			** AddBot()
			** GetConfig()
			** GetNickList()
			** GetIp()
			** GetHost()
			** GetMyInfo()
			** UserClass()
			** GetUserCount()
			** IsClass()
			** MenuOpt()
			** MenuPmOpt()
			** MenuDiv()
			** MenuCheck()
--]]--


--|------------------------------------------------------|--
--|                    Event handlers                    |--
--|------------------------------------------------------|--

hub = {};

-- Runs the Unload event handler for cleaning up after a script.
function UnLoad()
	if (hub.Unload ~= nil) then
		return hub.Unload();
	end;

	return 1;
end;

-- Intercepts Operator commands for the script.
function VH_OnOperatorCommand(nick, data)
	if (hub.OnOpCmd ~= nil) then
		return hub.OnOpCmd(nick, data);
	end;

	return 1;
end;

-- Intercepts User commands for the script.
function VH_OnUserCommand(nick, data)
	if (hub.OnUserCmd ~= nil) then
		return hub.OnUserCmd(nick, data);
	end;

	return 1;
end;

-- Intercepts Main Chat for the script.
function VH_OnParsedMsgChat(from, data)
	if (hub.GetChat ~= nil) then
		return hub.GetChat(from, data);
	end;

	return 1;
end;

-- Intercepts PMs for the script.
function VH_OnParsedMsgPm(from, data, to)
	if (hub.GetPm ~= nil) then
		return hub.GetPm(from, data, to);
	end;

	return 1;
end;

-- Intercepts user logins for the script.
function VH_OnUserLogin(nick)
	if (hub.OnUserLogin ~= nil) then
		return hub.OnUserLogin(nick);
	end;

	return 1;
end;

-- Intercepts user logouts for the script.
function VH_OnUserLogout(nick)
	if (hub.OnUserLogout ~= nil) then
		return hub.OnUserLogout(nick);
	end;

	return 1;
end;

-- Timer function.
function VH_OnTimer()
	if (hub.Timer ~= nil) then
		return hub.Timer();
	end;

	return 1;
end;


--|------------------------------------------------------|--
--|                  HUBSoft functions                   |--
--|------------------------------------------------------|--

-- SQL-query shorthand function.
function SQ(sql)
	return VH:SQLQuery(sql);
end;

-- SQL-fetch shorthand function.
function SF(row)
	return VH:SQLFetch(row);
end;

-- Kicks the given user off the HUB, with given reason.
function KickUser (kicker, user, reason)
	return VH:KickUser (kicker, user, reason);
end;

-- Close the connection for the given user.
function CloseConn(nick)
	return VH:CloseConnection(nick);
end;

-- Sends private messages to spesified user.
function MsgPm(botname, user, data)
	return VH:SendDataToUser("$To: "..user.." From: "..botname.." $<"..botname.."> "..data.."|", user);
end;

-- Sends message to user in main chat.
function MsgUser(botname, user, data)
	return VH:SendDataToUser("<"..botname.."> "..data.."|", user);
end;

-- Sends raw message to user.
function MsgRaw(user, data)
	return VH:SendDataToUser(data.."|", user);
end;

-- Sends PM to all Operators, or higher.
function MsgOps(botname, data, lev_min)
	return VH:SendPMToAll(data, botname, lev_min, 10);
end;

-- Sends messages to main, for users between "lev_min" and "lev_max".
function MsgMain(botname, data, lev_min, lev_max)
	return VH:SendDataToAll("<"..botname.."> "..data.."|", lev_min, lev_max);
end;

-- Adds as bot to the nicklist.
function AddBot(nick, desc, email)
	return VH:AddRobot(nick, 10, desc, "Bot ", email, "0");
end;

-- Removes a bot from the nicklist.
function RemoveBot(nick)
	return VH:DelRobot(nick);
end;

-- Returns value of config variable "var".
function GetConfig(var)
	-- Define local variables, for later use.
	local res, val;

	-- Get value of config variable "var".
	res, val = VH:GetConfig("config", var);

	-- Check if extraction was successful.
	if (not res) then
		-- Extraction failed, return empty string.
		return "";
	end;

	-- Success, return value.
	return val;
end;

-- Returns the userlist from the HUB.
function GetNickList()
	local res, Nicks = VH:GetNickList();

	if (not res) then
		return false;
	end;

	return Nicks;
end;

-- Retrieves the IP of the given user.
function GetIp(nick)
	local res, IP = VH:GetUserIP(nick);

	if (not res) then
		return false;
	end;

	return IP;
end;

-- Retrieves the hostname of the given user.
function GetHost(nick)
	local res, Host = VH:GetUserHost(nick);

	if (not res) then
		return false;
	end;

	return Host;
end;

-- Retrieves the MyINFO of the selected user.
function GetMyInfo(nick)
	local res, MyINFO = VH:GetMyINFO(nick);

	if (not res) then
		return false;
	end;

	return MyINFO;
end;

-- Retrieves class of user.
function UserClass(nick)
	-- Define local variables, for later use.
	local res, class;

	-- Get class of user "nick".
	res, class = VH:GetUserClass(nick);

	-- Check if retrieval was successful.
	if (res) then
		-- Return class.
		return class;
	end;

	-- Failed, return false.
	return false;
end;


--|------------------------------------------------------|--
--|                   Common functions                   |--
--|------------------------------------------------------|--

-- Parse a user's MyINFO
-- Returns the following list as an array:
	-- [0] => Client
	-- [1] => Version
	-- [2] => Mode
	-- [3] => Unreg Hubs
	-- [4] => Reg Hubs
	-- [5] => Op Hubs
	-- [6] => Total hubs
	-- [7] => Slots
	-- [8] => Share
	-- [9] => Description
	-- [10] => Speed
	-- [11] => Control flag
	-- [12] => Email.
function ParseMyInfo(nick)
	-- Define local variables, for later use
	local tempshare, myinfo, tag, desc, speed, flag, email, share, fshare;
	local client, version, mode, hubs, reghubs, ophubs, slots, thubs;

	-- Get the full MyINFO string
	myinfo = GetMyInfo(nick);

	-- Extract the user's tag from MyINFO first
	_, _, tag = string.find (myinfo, "^%$MyINFO %$ALL [^ ]+ [^$]*(%b<>)");

	-- If the user has no tag, give him one
	if tag == nil then
		tag = "<XX V:0.0,M:N,H:0/0/0,S:0>";

		-- Parse the rest of his MyINFO
		_, _, desc, speed, flag, email, share = string.find(myinfo, "^%$MyINFO %$ALL [^ ]+ ([^$]*)%$ $([^%c]+)([%c]+)[$]+([^$]*)%$(%S*)%$");
	else
		-- User has a tag in MyINFO, so parse the whole thing
		_, _, desc, speed, flag, email, share = string.find(myinfo, "^%$MyINFO %$ALL [^ ]+ ([^$]*)%b<>%$ $([^%c]+)([%c]+)[$]+([^$]*)%$(%S*)%$");
	end

	-- Prepare share for formatting
	tempshare = share / 1024 / 1024 / 1024;
	tempshare = string.format("%0.2f", tempshare);

	-- If the share is 6 digits or less, GB
	if string.len(tempshare) <= 6 then
		fshare = tempshare.." GB";
	else
		-- More than 6 digits, TB
		fshare = string.format("%0.2f", share / 1024).." TB";
	end

	-- Parse the user's tag, either his real one, or the one we gave him
	_, _, client, version, mode, hubs, reghubs, ophubs, slots = string.find(tag, "<(.+)V:(.+),M:([APN]),H:(%d+)%/(%d+)%/(%d+),S:(%d+)");

	-- Sum hub counts
	thubs = ((hubs+reghubs)+ophubs);
	return {client, version, mode, hubs, reghubs, ophubs, thubs, slots, fshare, desc, speed, flag, email}
end;

-- Count users online.
function GetUserCount()
	-- Define local variables, for later use.
	local count, users, nick;
	count = 0;

	-- Get list over active users.
	_, users = GetNickList();
	_, _, users = string.find(users, "%$[Nn]ick[lL]ist%s(.*)");

	-- Spool through online users.
	for nick in string.gfind(users, "([^%$%|]+)%$%$") do
		count = count + 1;
	end;

	-- Return user-count.
	return count;
end;

-- Checks if user is of required class or higher.
function IsClass(nick, class_min)
	-- Define local variables, for later use.
	local class;

	-- Get class of user "nick".
	class = UserClass(nick);

	-- Check if retrieval was successful, and class is higher than mininum class required.
	if (class and class >= class_min) then
		-- Has the needed access.
		return true;
	end;

	-- Don't have sufficient access, or failed checking.
	return false;
end;

-- Send a menu option to user.
function MenuOpt(user, mtype, context, menu, title, cmd)
	mtype, context = MenuCheck (mtype, context);
	return MsgRaw ("$UserCommand "..mtype..context..menu.."\\"..title.."$<%[mynick]> "..cmd.."&#124;|", user);
end;

-- Sends a menu option, for PM commands, to user.
function MenuPmOpt(user, sendto, mtype, context, menu, title, cmd)
	mtype, context = MenuCheck (mtype, context);
	return MsgRaw ("$UserCommand "..mtype..context..menu.."\\"..title.."$$To "..sendto.." From: %[mynick] $<%[mynick]> "..cmd.."&#124;|", user);
end;

-- Sends a menu divider to the user.
function MenuDiv(user, context)
	_, context = MenuCheck ("", context);
	return MsgRaw ("$UserCommand 0 "..context.."|", user);
end;

-- Verifies and fixes the context and type for user-command menus.
function MenuCheck(mt, mc)
	if (not mt or mt == "") then
		-- Default value if not set.
		mt = "1";
	end;

	if (not mc or mc == "") then
		-- Default value if not set.
		mc = "3";
	end;

	mt = mt.." ";
	mc = mc.." ";

	return mt, mc;
end;

--[[-- Flag values for the MenuOpt functions.
Context:
-- 1:	HUB menu.
-- 2:	User menu.
-- 4:	Search menu.
-- 8:	FileList menu.

Type:
-- 0:	Seperator.
-- 1:	Raw.
-- 2:	Raw, once per nick.
-- 255:	Del prev context menus.
--]]--