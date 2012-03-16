-- little fixed by Shurik to avoid some warnings...
function defifnil(var, value)
    if var == nil then
	return value
    end
    return var
end

-- Parses myinfo, returns a table.
function ParseMyInfo(nick, myinfo_p)
    -- Define local variables, for later use
    local res, myinfo 
    local tempshare, tag, desc, speed, flag, email, share, fshare;
    local client, version, mode, hubs, reghubs, ophubs, slots, thubs;

    -- If myinfo was supplied to function call use it...
    if (myinfo_p) then
        myinfo = myinfo_p
    -- ... else get it
    else        
        res, myinfo = VH:GetMyINFO(nick)
    end
        
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

    share = defifnil(share, 0)
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
    res, _, client, version, mode, hubs, reghubs, ophubs, slots = string.find(tag, "<(.+)V:(.+),M:([APN5]),H:(%d+)%/(%d+)%/(%d+),S:(%d+)");
    if client == nil then
	return nil
    end
    hubs = defifnil(hubs, 0)
    reghubs = defifnil(reghubs, 0)
    ophubs = defifnil(ophubs, 0)
    slots = defifnil(slots, 0)
    client = string.gsub(client, "%s+", "")

    -- Sum hub counts
    thubs = ((hubs+reghubs)+ophubs);
    
    -- Build user object
    local userobj={
        ["client"]=client,
        ["version"]=version,
        ["mode"]=mode,
        ["hubs"]=tonumber(hubs),
        ["reghubs"]=tonumber(reghubs),
        ["ophubs"]=tonumber(ophubs),
        ["thubs"]=tonumber(thubs),
        ["slots"]=tonumber(slots),
        ["share"]=tonumber(share),
        ["fshare"]=fshare,
        ["desc"]=desc,
        ["speed"]=speed,
        ["flag"]=flag,
        ["email"]=email
    }
    
    return userobj
end
