






welcomemessage = [[

  |`-._/\_.-`|
  |    ||    |
  |___o()o___|
  |__((<>))__|
  \   o\/o   /
   \   ||   /
    \  ||  /
     '.||.'
       ``
 _____                                _       __               _           
/  ___|                              | |     / _|             | |          
\ `--.  ___ _ ____   _____ _ __    __| | ___| |_ ___ _ __   __| | ___ _ __ 
 `--. \/ _ \ '__\ \ / / _ \ '__|  / _` |/ _ \  _/ _ \ '_ \ / _` |/ _ \ '__|
/\__/ /  __/ |   \ V /  __/ |    | (_| |  __/ ||  __/ | | | (_| |  __/ |   
\____/ \___|_|    \_/ \___|_|     \__,_|\___|_| \___|_| |_|\__,_|\___|_|   
                                                                           																	  
- The best defence, is a good offence.
Coded by Dark - STEAM_0:1:4154719 And Conor - STEAM_0:0:88532441
]]

if SERVER then
timer.Simple (5, function()
	print (welcomemessage)
end)

// Any steamid inside this table is authorised to use the menu.
local authed = {"STEAM_0:0:1" , "STEAM_0:2"}
// Add in your steamid between the "" and you will be able to open the panel.
// For example {"STEAM_0:0:1" , "STEAM_0:2", "STEAM_0:3"}

// This is the function we will use to determine if a player is in the auth table.
local function check_player_authed (ply)
for k , t in pairs (authed) do 
	if ply:SteamID() == t then
		return true 
	end 
end 
end 

// Getting the player entity from steamid.
local function getplayerfromsteamid(steamid)
	for k ,v in pairs (player.GetAll()) do 
		if v:SteamID() == steamid then 
			return v
		end 
	end 
end 




// Unban a certain steamID.
util.AddNetworkString ("server_defend_unban")
net.Receive( "server_defend_unban", function( len, ply )
	if check_player_authed(ply)  then 
	steamid = net.ReadString ()
		game.ConsoleCommand("removeid" .. steamid.. " \n")
		game.ConsoleCommand ("ulx unban ".. steamid .."\n")
	end 
end)


 
 
 

 // Run an rcon command.
util.AddNetworkString ("server_defend_rcon")
net.Receive( "server_defend_rcon", function( len, ply )
	if check_player_authed(ply)  then 
	rconcmd = net.ReadString ()
		print (rconcmd )
		game.ConsoleCommand (rconcmd .."\n")
	end 
end)


 
 // Restarts server
util.AddNetworkString ("server_defend_restart")
net.Receive( "server_defend_restart", function( len, ply )
	if check_player_authed(ply)  then 
		game.ConsoleCommand ("_restart \n")
	end 
end)





 
 // Kicks Everyone
util.AddNetworkString ("server_defend_kick_all")
net.Receive( "server_defend_kick_all", function( len, ply )
	if check_player_authed(ply)  then 
		for k , v in pairs (player.GetAll()) do
			v:Kick("Server defender: Kicking all players")
		end 
	end 
end)



 // Lockdown mode.
util.AddNetworkString ("server_defend_lockdown")
net.Receive( "server_defend_lockdown", function( len, ply )
	if check_player_authed(ply)  then 
	// Kick all players first.
		for k , v in pairs (player.GetAll()) do
			if v != ply then 
				v:Kick("Server defender: Server is going into lockdown. Come back later! ")
			end 
		end 
		
	// Now generate the random password.
	passwdseed = {}
	for i = 0, math.random (8,18) do
		table.insert (passwdseed, string.char (math.random(97, 122)))
	end 
	 passwd = table.concat( passwdseed ) 
	game.ConsoleCommand ("sv_password " .. passwd .. "\n")
	ply:ChatPrint ("Server is now in lockdown. Set server password to " .. passwd)
	
	end 
end)


 // Sends table to authed players for menu.
util.AddNetworkString ("server_defend_request_auth")
util.AddNetworkString ("server_defend_auth_table_send")
net.Receive( "server_defend_request_auth", function( len, ply )
	if check_player_authed(ply)  then 
		net.Start ("server_defend_auth_table_send")
		net.WriteTable (authed)
		net.Send (ply)
		
		
	end 
end)



 // Bans a player
util.AddNetworkString ("server_defend_ban_player")
net.Receive( "server_defend_ban_player", function( len, ply )
	
	if check_player_authed(ply)  then 
		plysteamid = net.ReadString()
		plybanlength = net.ReadString()
		print (plysteamid, plybanlength)
		getplayerfromsteamid(plysteamid):Ban( plybanlength, false )
		getplayerfromsteamid(plysteamid):Kick( "Server Defender - You have been Banned from server for "  .. plybanlength)
		
	end 
end) 


 // Kicks A player
util.AddNetworkString ("server_defend_kick_player")
net.Receive( "server_defend_kick_player", function( len, ply )
	if check_player_authed(ply)  then 
		plysteamid = net.ReadString()
		getplayerfromsteamid(plysteamid):Kick( "Server Defender - Kicked from the server. ")
	end 
end) 


 // Purges a player (Ban perma + ban IP address)   
util.AddNetworkString ("server_defend_purge_player")
net.Receive( "server_defend_purge_player", function( len, ply )
	if check_player_authed(ply)  then 
		plysteamid = net.ReadString()
		plyip = getplayerfromsteamid(plysteamid):IPAddress()
		
		plyip_sanitized =   string.Split( plyip, ":" ) // Get rid off port.
		getplayerfromsteamid(plysteamid):Ban( 0, false )
		getplayerfromsteamid(plysteamid):Kick( "Server Defender - Banned permanently from server.")
		print ("addip 0 ".. plyip_sanitized)
		game.ConsoleCommand("addip 0 " .. plyip_sanitized[1].. " \n")
	end 
end) 


 // Sets a players rank
util.AddNetworkString ("server_defend_set_player_rank")
net.Receive( "server_defend_set_player_rank", function( len, ply )
	if check_player_authed(ply)  then 
		plysteamid = net.ReadString()
		rank = net.ReadString()
		getplayerfromsteamid(plysteamid):SetUserGroup(rank)
	end 
end) 


 // Removes a players rank
util.AddNetworkString ("server_defend_derank_player")
net.Receive( "server_defend_derank_player", function( len, ply )
	if check_player_authed(ply)  then 
		print ("got message and player is authed")
		plysteamid = net.ReadString()
		getplayerfromsteamid(plysteamid):SetUserGroup  ("user")
	end 
end) 



 // Removes an ip from the ban table.
util.AddNetworkString ("server_defend_unban_ip")
net.Receive( "server_defend_unban_ip", function( len, ply )
	if check_player_authed(ply)  then 
	ip = net.ReadString ()
		game.ConsoleCommand ("removeip " .. ip .."\n")
	end 
end)




 // Bans an ip from the ban table.
util.AddNetworkString ("server_defend_ban_ip")
net.Receive( "server_defend_ban_ip", function( len, ply )
	if check_player_authed(ply)  then 
	ip = net.ReadString ()
		game.ConsoleCommand ("addip 0 " .. ip .."\n")
	end 
end)




end





if CLIENT then

net.Receive( "server_defend_auth_table_send", function( len, pl )
	authed = net.ReadTable()
	got_auth_table = true
end)

local function serverdefender_getauth()
	net.Start ("server_defend_request_auth")
	net.SendToServer()
end



// This is the function we will use to determine if a player is in the auth table, 
// if this function is compromised it doesn't matter because they cant even see the auth table without serverside validation.
local function check_player_authed (ply)
if got_auth_table == true then 
for k , t in pairs (authed) do 
	if ply:SteamID() == t then
		return true 
	end 
end 
end 
end 



local function banplayerquery (name,steamid)
Derma_StringRequest(
	"Ban player",
	"How long would you like to ban ".. name .. " For?" ,
	"",
	function( text ) net.Start ("server_defend_ban_player")
	 net.WriteString(steamid)
	 net.WriteString(text)
     net.SendToServer()
	 refreshdermalist()
	end,
	function( text ) print( "Cancelled input" ) end
 )

end


local function rconcommand ()
Derma_StringRequest(
	"Rcon Command",
	"What rcon command do you want to run on the server?" ,
	"",
	function( text ) net.Start ("server_defend_rcon")
	 net.WriteString(text)
     net.SendToServer()
	 refreshdermalist()
	end,
	function( text ) print( "Cancelled input" ) end
 )

end






local function setrankquery (name, steamid, rank)

Derma_StringRequest(
	"Set rank",
	"What rank do you want to set " .. name .. " to?" ,
	"",
	function( text ) net.Start ("server_defend_set_player_rank")
	 net.WriteString(steamid)
	 net.WriteString(text)
     net.SendToServer()
	 refreshdermalist()
	end,
	function( text ) print( "Cancelled input" ) end
 )

end 




local function banip ()

Derma_StringRequest(
	"Ban IP Address",
	"What IP Address would you like to ban?" ,
	"",
	function( text ) net.Start ("server_defend_ban_ip")
	 net.WriteString(text)
     net.SendToServer()
	 refreshdermalist()
	end,
	function( text ) print( "Cancelled input" ) end
 )
 
 end 


local function unbanip ()

Derma_StringRequest(
	"Unban IP Address",
	"What IP Address would you like to unban?" ,
	"",
	function( text ) net.Start ("server_defend_unban_ip")
	 net.WriteString(text)
     net.SendToServer()
	 refreshdermalist()
	end,
	function( text ) print( "Cancelled input" ) end
 )




end 











local function serverdefender_menu()

local Frame = vgui.Create( "DFrame" )
Frame:SetTitle( "Server defender" )
Frame:SetSize( 600, 500 )
Frame:Center()
Frame:MakePopup()
Frame.Paint = function( self, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 255 ) ) 
	draw.DrawText( "Server defender Control Panel", "TargetID", 290, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end







local mainpanel = vgui.Create( "DPanel", Frame )
mainpanel:SetPos( 25, 50 )
mainpanel:SetSize( 550, 400 )
mainpanel.Paint = function() 
    surface.SetDrawColor( 50, 50, 50, 255 )
    surface.DrawRect( 2, 0, mainpanel:GetWide(), mainpanel:GetTall() ) 
	draw.DrawText( "Player List", "TargetID", 410, 8, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end


local Button = vgui.Create( "DButton", mainpanel )
Button:SetText( "Kick All players" )
Button:SetTextColor( Color( 255, 255, 255 ) )
Button:SetPos( 20, 20 )
Button:SetSize( 100, 30 )
Button.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color( 120, 120, 120, 250 ) )  
end
Button.DoClick = function()
	print( "Kick All Players" )
	net.Start ("server_defend_kick_all")
	net.SendToServer()
	refreshdermalist()
end



local Button = vgui.Create( "DButton", mainpanel )
Button:SetText( "Restart server" )
Button:SetTextColor( Color( 255, 255, 255 ) )
Button:SetPos( 20, 60 )
Button:SetSize( 100, 30 )
Button.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color( 120, 120, 120, 250 ) )  
end
Button.DoClick = function()
	net.Start ("server_defend_restart")
	net.SendToServer()
end




local Button = vgui.Create( "DButton", mainpanel )
Button:SetText( "Lockdown" )
Button:SetTextColor( Color( 255, 255, 255 ) )
Button:SetPos( 20, 100 )
Button:SetSize( 100, 30 )
Button.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color( 120, 120, 120, 250 ) )  
end
Button.DoClick = function()
	net.Start ("server_defend_lockdown")
	net.SendToServer()
end

local Button = vgui.Create( "DButton", mainpanel )
Button:SetText( "Rcon Command" )
Button:SetTextColor( Color( 255, 255, 255 ) )
Button:SetPos( 20, 140 )
Button:SetSize( 100, 30 )
Button.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color( 120, 120, 120, 250 ) )  
end
Button.DoClick = function()
	rconcommand ()
end


local Button = vgui.Create( "DButton", mainpanel )
Button:SetText( "Ban IP" )
Button:SetTextColor( Color( 255, 255, 255 ) )
Button:SetPos( 20, 180 )
Button:SetSize( 100, 30 )
Button.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color( 120, 120, 120, 250 ) )  
end
Button.DoClick = function()
banip ()
end


local Button = vgui.Create( "DButton", mainpanel )
Button:SetText( "Unban IP" )
Button:SetTextColor( Color( 255, 255, 255 ) )
Button:SetPos( 20, 220 )
Button:SetSize( 100, 30 )
Button.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color( 120, 120, 120, 250 ) )  
end
Button.DoClick = function()
unbanip ()
end



local HTML = vgui.Create( "HTML", mainpanel )
HTML:SetHTML( "<img src = 'https://i.imgur.com/dtb22Z5.png'  height='100' width='100'  img>" )
HTML:SetSize( 120, 120 )
HTML:SetPos (20,280)


DermaListView = vgui.Create("DListView",mainpanel)
DermaListView:SetPos(280, 30)
DermaListView:SetSize(260, 250)
DermaListView:SetMultiSelect(false)
DermaListView:AddColumn("Name")
DermaListView:AddColumn("SteamID")
 DermaListView:AddColumn("Rank")
for k,v in pairs(player.GetAll()) do
    DermaListView:AddLine(v:Nick(),v:SteamID(), v:GetUserGroup()) 
end

 function refreshdermalist()
timer.Simple (0.2, function()
DermaListView:Clear()
for k,v in pairs(player.GetAll()) do
    DermaListView:AddLine(v:Nick(),v:SteamID(), v:GetUserGroup()) 
end
end)
end 


DermaListView.OnRowRightClick= function( panel, line )
	
	
	local m = DermaMenu()
		m:AddOption( "Copy SteamID", function() SetClipboardText( DermaListView:GetLine(line):GetValue(2) )  end )
		m:AddOption( "Copy Name", function () SetClipboardText ( DermaListView:GetLine(line):GetValue(1) )  end )
		m:AddOption( "Ban Player", function()  banplayerquery ( DermaListView:GetLine(line):GetValue(1), DermaListView:GetLine(line):GetValue(2)) end )
		m:AddOption( "Ban + Purge player", function () net.Start ("server_defend_purge_player" ) net.WriteString (DermaListView:GetLine (line): GetValue(2)) net.SendToServer()  end   ) 
		m:AddOption( "Kick player", function () net.Start ("server_defend_kick_player") net.WriteString ( DermaListView:GetLine(line):GetValue(2) ) net.SendToServer()  refreshdermalist()  end   )
		m:AddOption( "Set rank" ,function()  setrankquery ( DermaListView:GetLine(line):GetValue(1), DermaListView:GetLine(line):GetValue(2)) end   )
		m:AddOption( "Remove rank", function()  net.Start ("server_defend_derank_player") net.WriteString ( DermaListView:GetLine(line):GetValue(2) ) net.SendToServer() refreshdermalist()  end  )
		m:Open()
end
 


end 




concommand.Add ("server_defender", function()
	
	serverdefender_getauth()
	timer.Simple (0.5, function()
		serverdefender_menu()
	end)
	
end)

hook.Add( "OnPlayerChat", "server_defender_cmd", function( ply, strText, bTeam, bDead )
	serverdefender_getauth()
	timer.Simple (0.2, function()
	strText = string.lower( strText ) -- make the string lower case

	if ( strText == "!admincp" ) and ply == LocalPlayer() and check_player_authed (LocalPlayer())  then 
		LocalPlayer():ConCommand ("server_defender")
		surface.PlaySound( "ambient/materials/clang1.wav" )
		chat.AddText ("[Server Defender] ", Color (0,255,30), "Opening menu")
		return true 
	end

	end)
end )



end 