--|                                                      |--
--| Warn script v 2.1                                    |--
--|     Author: Shurik                                   |--
--|     Modified by:                                     |--
--|         Hellkeepa (hellkeeper_1@hotmail.com)         |--
--|                   09 Dec 2005, v2.0-2.1              |--
--|                                                      |--

-- May be redistributed only under terms of
-- GNU GPL version 3.0 or higher.

--[[ Changelog:
-- 2.1	Fixed a few bugs, set the warning to be sent as
		a PM to the recieving user, and added a sensible
		error message on missing parametre.
-- 2.0	Fixed a few bugs, some poor English, added bot
		variables, and moved the script to the CFL.
-- 1.0 First version, support for "set_max_warn", takes
		set_bot_name from HUB security, and added command "!warn".
--]]--

-- Include the CFL.
dofile("/etc/verlihub/scripts/functions.lua.inc");

-- Use existing bot? "true" is yes, and "false" is no.
use_existing_bot = true;

-- The name for the bot, ignore if "use_existing_bot" is set to "true".
set_bot_name = "WarnScript";

-- Replace with your e-mail address, ignore if "use_existing_bot" is set to "true".
set_bot_email = "your@mail.service";

-- Change this too, if you want; Bot-description, ignore if "use_existing_bot" is set to "true".
set_bot_desc = "Warns and kicks users, so behave!";

-- Max number of warnings a user can recieve without being kicked.
set_max_warn = 2;


--|                                                      |--
--| Please do not edit anything below, unless you        |--
--| _know_ what you're doing: Very good chance of        |--
--| rendering the script unusable otherwise.             |--
--|                                                      |--


warns = {};

function Main()
	if (not use_existing_bot or use_existing_bot == 0) then
		AddBot (set_bot_name, set_bot_email, set_bot_desc);
	else
		set_bot_name = GetConfig ("hub_security")
	end;
end;

function hub.OnOpCmd (nick, data) 
	if (string.find(data, "[%!]warn%s")) then
		_, _, user, reason = string.find (data,"[%!]warn%s(%S+)%s(.+)");

		if (not user or not reason or user == "" or reason == "") then
			MsgUser (set_bot_name, nick, "Please provide both the name of the user, and a reason for the warning.");
			return 0;
		end;

		ip = GetIp(user);

		if (not ip) then
			MsgUser (set_bot_name, nick, "No such user, or failed looking up IP");
			return 0;
		end

		class = UserClass (user);

		if (not IsClass (nick, class + 1)) then
			MsgUser (set_bot_name, nick, "You cannot warn people with a higher class than yourself!")
			return 0
		end

		count = 1;

		if (warns[user]) then
			count = warns[user].count + 1;
		end;

		if (count > set_max_warn) then
			KickUser (set_bot_name, user, "Too many warnings, kicked for: "..reason..")");
			warns[user] = nil;
			return 0;
		end;

		warns[user] = {time = os.clock(), count = count};
		MsgPm (set_bot_name, user, "You've been awarded your "..count.." warning, get 3 warns and you gona be kicked ----> reason: "..reason);
		MsgMain (set_bot_name, "User "..user.." has been warned (warning number "..count..") because: "..reason, 0, 10);
		return 0;
	end;

	return 1;
end;
