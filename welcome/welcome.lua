-- Welcome Script
-- by Shurik
-- Может распространяться только по условиям лицензии GNU GPL версии 3.0 или выше.
-- //May be redistributed only under terms of GNU GPL version 3.0 or higher.//

msgs_tblName = "script_msgs"
default_tblName = "script_defmsgs"
botname = "Unknown"

function Say(data,lowLevel,hiLevel)
	VH:SendDataToAll("<"..botname.."> "..data.."|",lowLevel, hiLevel)
end

function SayUser(data,nick)
	VH:SendDataToUser("<"..botname.."> "..data.."|",nick)
end

function Main()
	res, security = VH:GetConfig("config","hub_security")
	if not res then
		security = "Unknown"
	end
	botname = security
--	VH:AddRobot(botname, 10, "Aliki", "Bot ", "bot@aliki.sbin.ru", "0")
	-- S: Verify the table exists
    query = "CREATE TABLE IF NOT EXISTS "..default_tblName.." (class int, login_msg varchar(50) not null default '', logout_msg varchar(50) not null default '', PRIMARY KEY(class))"
    res, err = VH:SQLQuery(query)
    if not res then
        Say("Error in query: "..query,5, 10)
        Say("Error: "..err,5, 10)
    end
    query = "CREATE TABLE IF NOT EXISTS "..msgs_tblName.." (nick varchar(50), login_msg varchar(50) not null default '', logout_msg varchar(50) not null default '', PRIMARY KEY(nick))"
    res, err = VH:SQLQuery(query)
    if not res then
        Say("Error in query: "..query,5, 10)
        Say("Error: "..err,5, 10)
    end
	-- E: Verify the table exists
end

--VH_OnUserLogin
function VH_OnUserLogin(nick)
	query = "SELECT login_msg FROM "..msgs_tblName.." WHERE nick='"..nick.."'"
	res, rows = VH:SQLQuery(query)
	if rows > 0 then
		res, msg = VH:SQLFetch(0)
		if not (msg == "") then
			msg = string.gsub(msg,"%%%b[nick]",nick)
			Say(msg,0,10)
			return 1
		end
	end
	res, class = VH:GetUserClass(nick)
	if res then
		query = "SELECT login_msg FROM "..default_tblName.." WHERE class="..class;
		res, rows = VH:SQLQuery(query)
		if rows > 0 then
			res, msg = VH:SQLFetch(0)
			if not (msg == "") then
				msg = string.gsub(msg,"%%%b[nick]",nick)
				Say(msg,0,10)
				return 1
			end
		end
	end
	return 1
end

-- VH_OnUserLogout
function VH_OnUserLogout(nick)
	if nick == "[C]SHURIK"
	then
		return 1
	end
	query = "SELECT logout_msg FROM "..msgs_tblName.." WHERE nick='"..nick.."'"
	res, rows = VH:SQLQuery(query)
	if rows > 0 then
		res, msg = VH:SQLFetch(0)
		if not (msg == "") then
			msg = string.gsub(msg,"%%%b[nick]",nick)
			Say(msg,0,10)
			return 1
		end
	end
	res, class = VH:GetUserClass(nick)
	if res then
		query = "SELECT logout_msg FROM "..default_tblName.." WHERE class="..class;
		res, rows = VH:SQLQuery(query)
		if rows > 0 then
			res, msg = VH:SQLFetch(0)
			if not (msg == "") then
				msg = string.gsub(msg,"%%%b[nick]",nick)
				Say(msg,0,10)
				return 1
			end
		end
	end
	return 1
end

--VH_OnOperatorCommand
function VH_OnOperatorCommand(nick, data)
	res, class = VH:GetUserClass(nick)
	if(res and class > 4) then
		if (data=="!lswelcome") then
			SayUser("*** Welcome Messages for nicks:",nick)
			query = "SELECT nick, login_msg, logout_msg FROM "..msgs_tblName
			res, rows = VH:SQLQuery(query)
			if res then
				for x=0,rows-1 do
					local res,nick1,msg1,msg2=VH:SQLFetch(x)
					SayUser("nick: "..nick1.." login_msg: "..msg1.." logout_msg: "..msg2,nick)
				end
			end
			SayUser("*** Welcome Messages for classes:",nick)
			query = "SELECT class, login_msg, logout_msg FROM "..default_tblName
			res, rows = VH:SQLQuery(query)
			if res then
				for x=0,rows-1 do
					local res,class,msg1,msg2=VH:SQLFetch(x)
					SayUser("class: "..class.." login_msg: "..msg1.." logout_msg: "..msg2,nick)
				end
			end
			return 0
		elseif (string.find(data,"!addwelcome%s(%S+)%s(.+)")) then
			_,_,nick1,msg=string.find(data,"!addwelcome%s(%S+)%s(.+)")
			query = "SELECT login_msg FROM "..msgs_tblName.." WHERE nick='"..nick1.."'"
			res,rows = VH:SQLQuery(query)
			if rows > 0 then
				query = "UPDATE "..msgs_tblName.." SET login_msg='"..msg.."' WHERE nick='"..nick1.."'"
			else
				query = "INSERT INTO "..msgs_tblName.." (nick,login_msg,logout_msg) VALUES ('"..nick1.."','"..msg.."','')"
			end
			res,err = VH:SQLQuery(query)
			if res then
				SayUser("*** Welcome message for "..nick1.." added",nick)
			else
			        SayUser("Error in query: "..query,nick)
				SayUser("Error: "..err,nick)
			end
			return 0
		elseif (string.find(data,"!addbye%s(%S+)%s(.+)")) then
			_,_,nick1,msg=string.find(data,"!addbye%s(%S+)%s(.+)")
			query = "SELECT logout_msg FROM "..msgs_tblName.." WHERE nick='"..nick1.."'"
			res,rows = VH:SQLQuery(query)
			if rows > 0 then
				query = "UPDATE "..msgs_tblName.." SET logout_msg='"..msg.."' WHERE nick='"..nick1.."'"
			else
				query = "INSERT INTO "..msgs_tblName.." (nick,login_msg,logout_msg) VALUES ('"..nick1.."','','"..msg.."')"
			end
			res,err = VH:SQLQuery(query)
			if res then
				SayUser("*** Bye message for "..nick1.." added",nick)
			else
			        SayUser("Error in query: "..query,nick)
				SayUser("Error: "..err,nick)
			end
			return 0
		elseif (string.find(data,"!addwelcomeclass%s(%d+)%s(.+)")) then
			_,_,class,msg=string.find(data,"!addwelcomeclass%s(%S+)%s(.+)")
			query = "SELECT login_msg FROM "..default_tblName.." WHERE class='"..class.."'"
			res,rows = VH:SQLQuery(query)
			if rows > 0 then
				query = "UPDATE "..default_tblName.." SET login_msg='"..msg.."' WHERE class='"..class.."'"
			else
				query = "INSERT INTO "..default_tblName.." (class,login_msg,logout_msg) VALUES ('"..class.."','"..msg.."','')"
			end
			res,err = VH:SQLQuery(query)
			if res then
				SayUser("*** Welcome message for class "..class.." added",nick)
			else
			        SayUser("Error in query: "..query,nick)
				SayUser("Error: "..err,nick)
			end
			return 0
		elseif (string.find(data,"!addbyeclass%s(%d+)%s(.+)")) then
			_,_,class,msg=string.find(data,"!addbyeclass%s(%S+)%s(.+)")
			query = "SELECT logout_msg FROM "..default_tblName.." WHERE class='"..class.."'"
			res,rows = VH:SQLQuery(query)
			if rows > 0 then
				query = "UPDATE "..default_tblName.." SET logout_msg='"..msg.."' WHERE class='"..class.."'"
			else
				query = "INSERT INTO "..default_tblName.." (class,login_msg,logout_msg) VALUES ('"..class.."','','"..msg.."')"
			end
			res,err = VH:SQLQuery(query)
			if res then
				SayUser("*** Bye message for class "..class.." added",nick)
			else
			        SayUser("Error in query: "..query,nick)
				SayUser("Error: "..err,nick)
			end
			return 0
		elseif (string.find(data,"!delwelcome%s(%S+)")) then
			_,_,nick1=string.find(data,"!delwelcome%s(%S+)")
			query = "SELECT logout_msg FROM "..msgs_tblName.." WHERE nick='"..nick1.."'"
			res,rows = VH:SQLQuery(query)
			if rows > 0 then
				res,msg=VH:SQLFetch(0)
				if msg=="" then
					query = "DELETE FROM "..msgs_tblName.." WHERE nick='"..nick1.."'"
				else
					query = "UPDATE "..msgs_tblName.." SET login_msg='' WHERE nick='"..nick1.."'"
				end
				res,err = VH:SQLQuery(query)
    				if res then
					SayUser("*** Welcome message for "..nick1.." deleted",nick)
				else
				        SayUser("Error in query: "..query,nick)
					SayUser("Error: "..err,nick)
				end
			end
			return 0
		elseif (string.find(data,"!delbye%s(%S+)")) then
			_,_,nick1=string.find(data,"!delbye%s(%S+)")
			query = "SELECT login_msg FROM "..msgs_tblName.." WHERE nick='"..nick1.."'"
			res,rows = VH:SQLQuery(query)
			if rows > 0 then
				res,msg=VH:SQLFetch(0)
				if msg=="" then
					query = "DELETE FROM "..msgs_tblName.." WHERE nick='"..nick1.."'"
				else
					query = "UPDATE "..msgs_tblName.." SET logout_msg='' WHERE nick='"..nick1.."'"
				end
				res,err = VH:SQLQuery(query)
    				if res then
					SayUser("*** Bye message for "..nick1.." deleted",nick)
				else
				        SayUser("Error in query: "..query,nick)
					SayUser("Error: "..err,nick)
				end
			end
			return 0
		elseif (data == "!welcomehelp") then
			SayUser("*** Welcome Script Commands",nick)
			SayUser("!welcomehelp - This help",nick)
			SayUser("!lswelcome - List messages",nick)
			SayUser("!addwelcome <nick> <message> - Add/modify welcome message for nick",nick)
			SayUser("!addbye <nick> <message> - Add/modify bye message for nick",nick)
			SayUser("!addwelcomeclass <class> <message> - Add/modify welcome message for class (replaces msg_welcome_*)",nick)
			SayUser("!addbyeclass <class> <message> - Add/modify bye message for class",nick)
			SayUser("!delwelcome <nick> - Delete welcome message for nick",nick)
			SayUser("!delbye <nick> - Delete bye message for nick",nick)
			SayUser("*** Follow commands are not implemented yet",nick)
			SayUser("!delwelcomeclass <class> - Delete welcome message for class",nick)
			SayUser("!delbyeclass <class> - Delete bye message for class",nick)
			SayUser("!setwelcomesfromhub - Copy mgs_welcome_* to script's class welcomes",nick)
			SayUser("!setwelcomestohub - Copy script's class welcomes to msg_welcome_*",nick)
			SayUser("!delwelcomesfromhub - Delete all hub msg_welcome_*",nick)
			return 0
		end
	end
	return 1
end

