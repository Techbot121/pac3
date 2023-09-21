include("parts.lua")
include("shortcuts.lua")
if SERVER then
	include("pac3/editor/server/combat_bans.lua")
end

pace = pace


local function rebuild_bookmarks()
	pace.bookmarked_ressources = pace.bookmarked_ressources or {}

	--here's some default favorites
	if not pace.bookmarked_ressources["models"] or table.IsEmpty(pace.bookmarked_ressources["models"]) then
		pace.bookmarked_ressources["models"] = {
			"models/pac/default.mdl",
			"models/pac/plane.mdl",
			"models/pac/circle.mdl",
			"models/hunter/blocks/cube025x025x025.mdl",
			"models/editor/axis_helper.mdl",
			"models/editor/axis_helper_thick.mdl"
		}
	end

	if not pace.bookmarked_ressources["sound"] or table.IsEmpty(pace.bookmarked_ressources["sound"]) then
		pace.bookmarked_ressources["sound"] = {
			"music/hl1_song11.mp3",
			"npc/combine_gunship/dropship_engine_near_loop1.wav",
			"ambient/alarms/warningbell1.wav",
			"phx/epicmetal_hard7.wav",
			"phx/explode02.wav"
		}
	end

	if not pace.bookmarked_ressources["materials"] or table.IsEmpty(pace.bookmarked_ressources["materials"]) then
		pace.bookmarked_ressources["materials"] = {
			"models/debug/debugwhite",
			"vgui/null",
			"debug/env_cubemap_model",
			"models/wireframe",
			"cable/physbeam",
			"cable/cable2",
			"effects/tool_tracer",
			"effects/flashlight/logo",
			"particles/flamelet[1,5]",
			"sprites/key_[0,9]",
			"vgui/spawnmenu/generating",
			"vgui/spawnmenu/hover"
		}
	end

	if not pace.bookmarked_ressources["proxy"] or table.IsEmpty(pace.bookmarked_ressources["proxy"]) then
		pace.bookmarked_ressources["proxy"] = {
			--[[["user"] = {
				
			},]]
			["fades and transitions"] ={
				{
					nicename = "standard clamp fade (in)",
					expression = "clamp(timeex(),0,1)",
					explanation = "the simplest fade.\nthis is normalized, which means you'll often multiply this whole unit by the amount you want, like a distance.\ntimeex() starts at 0, moves gradually to 1 and stops progressing at 1 due to the clamp"
				},
				{
					nicename = "standard clamp fade (out)",
					expression = "clamp(1 - timeex(),0,1)",
					explanation = "the simplest fade's reverse.\nthis is normalized, which means you'll often multiply this whole unit by the amount you want, like a distance.\ntimeex() starts at 1, moves gradually to 0 and stops progressing at 0 due to the clamp"
				},
				{
					nicename = "standard clamp fade (delayed in)", 
					expression = "clamp(-1 + timeex(),0,1)",
					explanation = "the basic fade is delayed by the fact that the clamp makes sure the negative values are pulled back to 0 until the first argument crosses 0 into the clamp's range."
				},
				{
					nicename = "standard clamp fade (delayed out)",
					expression = "clamp(2 - timeex(),0,1)",
					explanation = "the reverse fade is delayed by the fact that the clamp makes sure the values beyond 1 are pulled back to 1 until the first argument crosses 1 into the clamp's range."
				},
				{
					nicename = "standard clamp fade (in and out)",
					expression = "clamp(timeex(),0,1)*clamp(3 - timeex(),0,1)",
					explanation = "this is just compounding both fades. the second clamp's 3 is comprised of 1 (the clamp max) + 1 (the delay BEFORE the fade) + 1 (the delay BETWEEN the fades)"
				},
				{
					nicename = "quick ease setup",
					expression = "easeInBack(clamp(timeex(),0,1))",
					explanation = "get started quickly with the new easing functions.\nsearch \"ease\" in the proxy's input list to see how to write them in pac3, or look at the gmod wiki to see previews of each"
				},
			},
			["pulses"] = {
				{
					nicename = "bell pulse",
					expression = "(0 + 1*sin(PI*timeex())^16)",
					explanation = "a basic normalized pulse, using a sine power."
				},
				{
					nicename = "square-like throb",
					expression = "(0 + 1 * (cos(PI*timeex())^16) ^0.3)",
					explanation = "a throbbing-like pulse, made by combining a sine power with a fractionnal power.\nthis is better explained visually, so either test it right here in game or go look at a graph to see how x, and cos or sin behave with powers.\ntry x^pow and sin(x)^pow, and try different pows"
				},
				{
					nicename = "binary pulse",
					expression = "floor(1 + sin(PI*timeex()))",
					explanation = "an on-off pulse, in other words a square wave.\nthis one completes one cycle every 2 seconds.\nfloor rounds down between 1 and 0 with nothing in-between."
				},
				{
					nicename = "saw wave (up)",
					expression = "(timeex()%1)",
					explanation = "a sawtooth wave. it can repeat a 0-1 transition."
				},
				{
					nicename = "saw wave (down)",
					expression = "(1 - timeex()%1)",
					explanation = "a sawtooth wave. it can repeat a 1-0 transition."
				},
				{
					nicename = "triangle wave",
					expression = "(clamp(-1+timeex()%2,0,1) + clamp(1 - timeex()%2,0,1))",
					explanation = "a triangle wave. it goes back and forth linearly like a saw up and down."
				}
			},
			["facial expressions"] = {
				{
					nicename = "normal slow blink",
					expression = "3*clamp(sin(timeex())^100,0,1)",
					explanation = "a normal slow blink.\nwhile flexes usually have a range of 0-1, the 3 outside of the clamp is there to trick the value into going faster in case they're too slow to reach their target"
				},
				{
					nicename = "normal fast blink",
					expression = "8*clamp(sin(timeex())^600,0,1)",
					explanation = "a normal slow blink.\nwhile flexes usually have a range of 0-1, the 8 outside of the clamp is there to trick the value into going faster in case they're too slow to reach their target\nif it's still not enough, use another flex with less blinking amount to provide the additionnal distance for the blink"
				},
				{
					nicename = "babble",
					expression = "sin(12*timeex())^2",
					explanation = "a basic piece to move the mouth semi-convincingly for voicelines.\nthere'll never be dynamic lipsync in pac3, but this is a start."
				},
				{
					nicename = "voice smoothener",
					expression = "clamp(feedback() + 70*voice_volume()*ftime() - 15*ftime(),0,2)",
					explanation = "uses a feedback() setup to raise the mouth's value gradually against a constantly lowering value, which should be more smoothly than a direct input"
				},
				{
					nicename = "look side (legacy symmetrical look)",
					expression = "3*(-1 + 2*pose_parameter(\"head_yaw\"))",
					explanation = "an expression to mimic the head's yaw"
				},
				{
					nicename = "look side (new)",
					expression = "pose_parameter_true(\"head_yaw\")",
					explanation = "an expression to mimic the head's yaw, but it requires your model to have this standard pose parameter"
				},
				{
					nicename = "look up",
					expression = "(-1 + 2*owner_eye_angle_pitch())",
					explanation = "an expression to mimic the head's pitch on a [-1,1] range"
				},
				{
					nicename = "single eyeflex direction (up)",
					expression = "-0.03*pose_parameter_true(\"head_pitch\")",
					explanation = "plug into an eye_look_up flex or an eye bone with a higher multiplier"
				},
				{
					nicename = "single eyeflex direction (down)",
					expression = "0.03*pose_parameter_true(\"head_pitch\")",
					explanation = "plug into an eye_look_down flex or an eye bone with a higher multiplier"
				},
				{
					nicename = "single eyeflex direction (left)",
					expression = "0.03*pose_parameter_true(\"head_yaw\")",
					explanation = "plug into an eye_look_left flex or an eye bone with a higher multiplier"
				},
				{
					nicename = "single eyeflex direction (right)",
					expression = "-0.03*pose_parameter_true(\"head_yaw\")",
					explanation = "plug into an eye_look_right flex or an eye bone with a higher multiplier"
				},
			},
			["spatial"] = {
				{
					nicename = "random position (cloud)",
					expression = "150*random(-1,1),150*random(-1,1),150*random(-1,1)",
					explanation = "position a part randomly across X,Y,Z\nbut constantly blinking everywhere, because random generates a new number every frame.\nyou should only use this for parts that emit things into the world"
				},
				{
					nicename = "random position (once)",
					expression = "150*random_once(0,-1,1),150*random_once(1,-1,1),150*random_once(2,-1,1)",
					explanation = "position a part randomly across X,Y,Z\nbut once, because random_once only generates a number once.\nit, however, needs distinct numbers in the first arguments to distinguish them every time you write the function."
				},
				{
					nicename = "distance-based fade",
					expression = "clamp((250/500) + 1 - (eye_position_distance() / 500),0,1)",
					explanation = "a fading based on the viewer's distance. 250 and 500 are the example distances, 250 is where the expression starts diminishing, and 750 is where we reach 0."
				},
				{
					nicename = "distance between two points",
					expression = "part_distance(uid1,uid2)",
					explanation = "Trick question! You have some homework! You need to find out your parts' UIDs first.\ntry tools -> copy global id, then paste those in place of uid1 and uid2"
				},
				{
					nicename = "revolution (orbit)",
					expression = "150*sin(time()),150*cos(time()),0",
					explanation = "Trick question! You might need to rearrange the expression depending on which coordinate system we're at. For a thing on a pos_noang bone, it works as is. But for something on your head, you would need to swap x and z\n0,150*cos(time()),150*sin(time())"
				},
				{
					nicename = "spin",
					expression = "0,360*time(),0",
					explanation = "a simple spinner on Y"
				}
			},
			["experimental things"] = {
				{
					nicename = "control a boolean directly with an event",
					expression = "event_alternative(uid1,0,1)",
					explanation = "trick question! you need to find out your event's part UID first and substitute uid1\n"
				},
				{
					nicename = "feedback system controlled with 2 events",
					expression = "feedback() + ftime()*(event_alternative(uid1,0,1) + event_alternative(uid2,0,-1))",
					explanation = "trick question! you need to find out your event parts' UIDs first and substitute uid1 and uid2.\nthe new event_alternative function gets an event's state\nwe can inject that into our feedback system to act as a positive or negative speed"
				},
				{
					nicename = "basic if-else statement",
					expression = "number_operator_alternative(1,\">\",0,100,50)",
					explanation = "might be niche but here's a basic alternator thing, you can compare the 1st and 3rd args with numeric operators like \"above\", \"<\", \"=\", \"~=\" etc. to choose between the 4th and 5th args\nit goes like this\nnumber_operator_alternative(1,\">\",0,100,50)\nif 1>0, return 100, else return 50"
				},
				{
					nicename = "pick from 3 random colors",
					expression = "number_operator_alternative(random_once(1), \"<\", 0.333, 1, number_operator_alternative(random_once(1), \">\", 0.666, 1.0, 0.75)),number_operator_alternative(random_once(1), \"<\", 0.333, 1, number_operator_alternative(random_once(1), \">\", 0.666, 0.8, 0.65)),number_operator_alternative(random_once(1), \"<\", 0.333, 1, number_operator_alternative(random_once(1), \">\", 0.666, 1.0, 0.58))",
					explanation =
						"using a shared random source, you can nest number_operator_alternative functions to get a 3-way branching random choice\n0.333 and 0.666 correspond to the chance slices where each choice gets decided so you can change the probabilities by editing these numbers\nBecause of the fact we're going deep, it's not easily readable so I'll lay out each component.\n\n" ..
						"R:  number_operator_alternative(random_once(1), \"<\", 0.333, 1, number_operator_alternative(random_once(1), \">\", 0.666, 1.0, 0.75))\n"..
						"G:  number_operator_alternative(random_once(1), \"<\", 0.333, 1, number_operator_alternative(random_once(1), \">\", 0.666, 0.8, 0.65))\n"..
						"B:  number_operator_alternative(random_once(1), \"<\", 0.333, 1, number_operator_alternative(random_once(1), \">\", 0.666, 1.0, 0.58))\n\n"..
						"The first choice is white (1,1,1), the second choice is light pink (1,0.8,1) like a strawberry milk, the third choice is light creamy brown (0.75,0.65,0.58) like chocolate milk"
				},
				{
					nicename = "feedback command attractor",
					expression = "feedback() + ftime()*(command(\"destination\") - feedback())",
					explanation =
						"This thing uses a principle of iteration similar to exponential functions to attract the feedback toward any target\n"..
						"The delta bit will get smaller and smaller as the gap between destination and feedback closes, stabilizing at 0, thereby stopping.\n"..
						"You will utilize pac_proxy commands to set the destination target: \"pac_proxy destination 2\" will make the expression tend toward 2."
				}
			}
		}
		
	end

end

local PANEL = {}

local player_ban_list = {}
local player_combat_ban_list = {}

local function encode_table_to_file(str)
	local data = {}
	if not file.Exists("pac3_config", "DATA") then
		file.CreateDir("pac3_config")
		
	end
	

	if str == "pac_editor_shortcuts" then
		data = pace.PACActionShortcut
		file.Write("pac3_config/" .. str..".txt", util.TableToKeyValues(data))
	elseif str == "pac_editor_partmenu_layouts" then
		data = pace.operations_order
		file.Write("pac3_config/" .. str..".txt", util.TableToJSON(data))
	elseif str == "pac_part_categories" then
		data = pace.partgroups
		file.Write("pac3_config/" .. str..".txt", util.TableToKeyValues(data))
	elseif str == "bookmarked_ressources" then
		rebuild_bookmarks()
		for category, tbl in pairs(pace.bookmarked_ressources) do
			data = tbl
			str = category
			file.Write("pac3_config/bookmarked_" .. str..".txt", util.TableToKeyValues(data))
		end
		
	end

end

local function decode_table_from_file(str)
	if str == "bookmarked_ressources" then
		rebuild_bookmarks()
		local ressource_types = {"models", "sound", "materials", "sprites"}
		for _, category in pairs(ressource_types) do
			data = file.Read("pac3_config/bookmarked_" .. category ..".txt", "DATA")
			if data then pace.bookmarked_ressources[category] = util.KeyValuesToTable(data) end
		end
		return
	end

	local data = file.Read("pac3_config/" .. str..".txt", "DATA")
	if not data then return end

	if str == "pac_editor_shortcuts" then
		pace.PACActionShortcut = util.KeyValuesToTable(data)

	elseif str == "pac_editor_partmenu_layouts" then
		pace.operations_order = util.JSONToTable(data)
		
	elseif str == "pac_part_categories" then
		pace.partgroups = util.KeyValuesToTable(data)
	
	end


end

decode_table_from_file("bookmarked_ressources")
pace.bookmarked_ressources = pace.bookmarked_ressources or {}

function pace.SaveRessourceBookmarks()
	encode_table_to_file("bookmarked_ressources")
end

function PANEL:Init()
	local master_pnl = vgui.Create("DPropertySheet", self)
	master_pnl:Dock(FILL)

	local properties_filter = pace.FillWearSettings(master_pnl)
	master_pnl:AddSheet("Wear / Ignore", properties_filter)

	local editor_settings = pace.FillEditorSettings(master_pnl)
	master_pnl:AddSheet("Editor menu Settings", editor_settings)

	local editor_settings2 = pace.FillEditorSettings2(master_pnl)
	master_pnl:AddSheet("Editor menu Settings 2", editor_settings2)


	if game.SinglePlayer() or LocalPlayer():IsAdmin() then

		local general_sv_settings = pace.FillServerSettings(master_pnl)
		master_pnl:AddSheet("General Settings (SV)", general_sv_settings)

		local combat_sv_settings = pace.FillCombatSettings(master_pnl)
		master_pnl:AddSheet("Combat Settings (SV)", combat_sv_settings)

		local ban_settings = pace.FillBanPanel(master_pnl)
		master_pnl:AddSheet("Bans (SV)", ban_settings)

		local combat_ban_settings = pace.FillCombatBanPanel(master_pnl)
		master_pnl:AddSheet("Combat Bans (SV)", combat_ban_settings)
		
	end
	
	
	self.sheet = master_pnl
	
	--local properties_shortcuts = pace.FillShortcutSettings(pnl)
	--pnl:AddSheet("Editor Shortcuts", properties_shortcuts)
end

vgui.Register( "pace_settings", PANEL, "DPanel" )

function pace.OpenSettings()
	if IsValid(pace.settings_panel) then
		pace.settings_panel:Remove()
	end
	local pnl = vgui.Create("DFrame")
	pnl:SetTitle("pac settings")
	pace.settings_panel = pnl
	pnl:SetSize(800,600)
	pnl:MakePopup()
	pnl:Center()
	pnl:SetSizable(true)

	local pnl = vgui.Create("pace_settings", pnl)
	pnl:Dock(FILL)
end

concommand.Add("pace_settings", function()
	pace.OpenSettings()
end)


function pace.FillBanPanel(pnl)
	local pnl = pnl
	local BAN = vgui.Create("DPanel", pnl)
	local ply_state_list = player_ban_list or {}

	local ban_list = vgui.Create("DListView", BAN)
		ban_list:SetText("ban list")
		ban_list:SetSize(400,400)
		ban_list:SetPos(10,10)
	
		ban_list:AddColumn("Player name")
		ban_list:AddColumn("SteamID")
		ban_list:AddColumn("State")
		ban_list:SetSortable(false)
		for _,ply in pairs(player.GetAll()) do
			--print(ply, pace.IsBanned(ply))
			ban_list:AddLine(ply:Name(),ply:SteamID(),player_ban_list[ply] or "Allowed")
		end

		function ban_list:DoDoubleClick( lineID, line )
			--MsgN( "Line " .. lineID .. " was double clicked!" )
			local state = line:GetColumnText( 3 )

			if state == "Banned" then state = "Allowed"
			elseif state == "Allowed" then state = "Banned" end
			line:SetColumnText(3,state)
			ply_state_list[player.GetBySteamID(line:GetColumnText( 2 ))] = state
			PrintTable(ply_state_list)
		end
	
	local ban_confirm_list_button = vgui.Create("DButton", BAN)
		ban_confirm_list_button:SetText("Send ban list update to server")
		
		ban_confirm_list_button:SetTooltip("WARNING! Unauthorized use will be notified to the server!")
		ban_confirm_list_button:SetColor(Color(255,0,0))
		ban_confirm_list_button:SetSize(200, 40)
		ban_confirm_list_button:SetPos(450, 10)
		function ban_confirm_list_button:DoClick()
			net.Start("pac.BanUpdate")
			net.WriteTable(ply_state_list)
			net.SendToServer()
		end
	local ban_request_list_button = vgui.Create("DButton", BAN)
		ban_request_list_button:SetText("Request ban list from server")
		--ban_request_list_button:SetColor(Color(255,0,0))
		ban_request_list_button:SetSize(200, 40)
		ban_request_list_button:SetPos(450, 60)
		
		function ban_request_list_button:DoClick()
			net.Start("pac.RequestBanStates")
			net.SendToServer()
		end

		net.Receive("pac.SendBanStates", function()
			local players = net.ReadTable()
			player_ban_list = players
			PrintTable(players)
		end)
		

	return BAN
end

function pace.FillCombatBanPanel(pnl)
	local pnl = pnl
	local BAN = vgui.Create("DPanel", pnl)
	pac.global_combat_whitelist = pac.global_combat_whitelist or {}
	

	local ban_list = vgui.Create("DListView", BAN)
		ban_list:SetText("Combat ban list")
		ban_list:SetSize(400,400)
		ban_list:SetPos(10,10)
	
		ban_list:AddColumn("Player name")
		ban_list:AddColumn("SteamID")
		ban_list:AddColumn("State")
		ban_list:SetSortable(false)
		if GetConVar('pac_sv_combat_whitelisting'):GetBool() then
			ban_list:SetTooltip( "Whitelist mode: Default players aren't allowed to use the combat features until set to Allowed" )
		else
			ban_list:SetTooltip( "Blacklist mode: Default players are allowed to use the combat features" )
		end

		local combat_bans_temp_merger = {}

		for _,ply in pairs(player.GetAll()) do
			combat_bans_temp_merger[ply:SteamID()] = pac.global_combat_whitelist[ply:SteamID()]-- or {nick = ply:Nick(), steamid = ply:SteamID(), permission = "Default"}
		end

		for id,data in pairs(pac.global_combat_whitelist) do
			combat_bans_temp_merger[id] = data
		end
		
		for id,data in pairs(combat_bans_temp_merger) do
			ban_list:AddLine(data.nick,data.steamid,data.permission)
		end

		function ban_list:DoDoubleClick( lineID, line )
			--MsgN( "Line " .. lineID .. " was double clicked!" )
			local state = line:GetColumnText( 3 )

			if state == "Banned" then state = "Default"
			elseif state == "Default" then state = "Allowed"
			elseif state == "Allowed" then state = "Banned" end
			line:SetColumnText(3,state)
			pac.global_combat_whitelist[string.lower(line:GetColumnText( 2 ))].permission = state
			PrintTable(pac.global_combat_whitelist)
		end
	
	local ban_confirm_list_button = vgui.Create("DButton", BAN)
		ban_confirm_list_button:SetText("Send combat ban list update to server")
		
		ban_confirm_list_button:SetTooltip("WARNING! Unauthorized use will be notified to the server!")
		ban_confirm_list_button:SetColor(Color(255,0,0))
		ban_confirm_list_button:SetSize(200, 40)
		ban_confirm_list_button:SetPos(450, 10)
		function ban_confirm_list_button:DoClick()
			net.Start("pac.CombatBanUpdate")
			net.WriteTable(pac.global_combat_whitelist)
			net.WriteBool(true)
			net.SendToServer()
		end
	local ban_request_list_button = vgui.Create("DButton", BAN)
		ban_request_list_button:SetText("Request ban list from server")
		--ban_request_list_button:SetColor(Color(255,0,0))
		ban_request_list_button:SetSize(200, 40)
		ban_request_list_button:SetPos(450, 60)
		
		function ban_request_list_button:DoClick()
			net.Start("pac.RequestCombatBanStates")
			net.SendToServer()
		end

		net.Receive("pac.SendCombatBanStates", function()
			pac.global_combat_whitelist = net.ReadTable()
			PrintTable(pac.global_combat_whitelist)
		end)
		

	return BAN
end

function pace.FillCombatSettings(pnl)
	local pnl = pnl

	local master_list = vgui.Create("DCategoryList", pnl)
	master_list:Dock(FILL)
	--general
	do
		local general_list = master_list:Add("General")
		general_list.Header:SetSize(40,40)
		general_list.Header:SetFont("DermaLarge")
		local general_list_list = vgui.Create("DListLayout")
		general_list_list:DockPadding(20,0,20,20)
		general_list:SetContents(general_list_list)

		local sv_prop_protection_props_box = vgui.Create("DCheckBoxLabel", general_list_list)
		sv_prop_protection_props_box:SetText("Enforce generic prop protection for player-owned props and physics entities")
		sv_prop_protection_props_box:SetSize(400,30)
		sv_prop_protection_props_box:SetConVar("pac_sv_prop_protection")


		local sv_combat_whitelisting_box = vgui.Create("DCheckBoxLabel", general_list_list)
		sv_combat_whitelisting_box:SetText("Restrict new pac3 combat (damage zone, lock, force) to only whitelisted users.")
		sv_combat_whitelisting_box:SetSize(400,30)
		sv_combat_whitelisting_box:SetConVar("pac_sv_combat_whitelisting")
		sv_combat_whitelisting_box:SetTooltip("off = Blacklist mode: Default players are allowed to use the combat features\non = Whitelist mode: Default players aren't allowed to use the combat features until set to Allowed")

	end

	do --hitscan
		--[[
			pac_sv_hitscan
			pac_sv_hitscan_max_bullets
			pac_sv_hitscan_max_damage
			pac_sv_hitscan_divide_max_damage_by_max_bullets
		]]

		local hitscans_list = master_list:Add("Hitscans")
		hitscans_list.Header:SetSize(40,40)
		hitscans_list.Header:SetFont("DermaLarge")
		local hitscans_list_list = vgui.Create("DListLayout")
		hitscans_list_list:DockPadding(20,0,20,20)
		hitscans_list:SetContents(hitscans_list_list)

		local sv_hitscans_box = vgui.Create("DCheckBoxLabel", hitscans_list_list)
			sv_hitscans_box:SetText("allow serverside physical projectiles")
			sv_hitscans_box:SetSize(400,30)
			sv_hitscans_box:SetConVar("pac_sv_projectiles")

		local hitscans_max_dmg_numbox = vgui.Create("DNumSlider", hitscans_list_list)
			hitscans_max_dmg_numbox:SetText("Max hitscan damage (per bullet, per multishot,\ndepending on the next setting)")
			hitscans_max_dmg_numbox:SetValue(GetConVar("pac_sv_hitscan_max_damage"):GetInt())
			hitscans_max_dmg_numbox:SetMin(0) hitscans_max_dmg_numbox:SetDecimals(0) hitscans_max_dmg_numbox:SetMax(1000000)
			hitscans_max_dmg_numbox:SetSize(400,30)
			hitscans_max_dmg_numbox:SetConVar("pac_sv_hitscan_max_damage")

		local sv_hitscans_distribute_box = vgui.Create("DCheckBoxLabel", hitscans_list_list)
			sv_hitscans_distribute_box:SetText("force hitscans to distribute their total damage accross bullets. if off, every bullet does full damage; if on, adding more bullets doesn't do more damage")
			sv_hitscans_distribute_box:SetSize(400,30)
			sv_hitscans_distribute_box:SetConVar("pac_sv_hitscan_divide_max_damage_by_max_bullets")

		local hitscans_max_numbullets_numbox = vgui.Create("DNumSlider", hitscans_list_list)
			hitscans_max_numbullets_numbox:SetText("Maximum number of bullets for hitscan multishots")
			hitscans_max_numbullets_numbox:SetValue(GetConVar("pac_sv_hitscan_max_bullets"):GetInt())
			hitscans_max_numbullets_numbox:SetMin(1) hitscans_max_numbullets_numbox:SetDecimals(0) hitscans_max_numbullets_numbox:SetMax(500)
			hitscans_max_numbullets_numbox:SetSize(400,30)
			hitscans_max_numbullets_numbox:SetConVar("pac_sv_hitscan_max_bullets")
	end

	do --projectiles
		local projectiles_list = master_list:Add("Projectiles")
		projectiles_list.Header:SetSize(40,40)
		projectiles_list.Header:SetFont("DermaLarge")
		local projectiles_list_list = vgui.Create("DListLayout")
		projectiles_list_list:DockPadding(20,0,20,20)
		projectiles_list:SetContents(projectiles_list_list)

		local sv_projectiles_box = vgui.Create("DCheckBoxLabel", projectiles_list_list)
			sv_projectiles_box:SetText("allow serverside physical projectiles")
			sv_projectiles_box:SetSize(400,30)
			sv_projectiles_box:SetConVar("pac_sv_projectiles")

		local projectile_max_phys_radius_numbox = vgui.Create("DNumSlider", projectiles_list_list)
			projectile_max_phys_radius_numbox:SetText("Max projectile physical radius")
			projectile_max_phys_radius_numbox:SetValue(GetConVar("pac_sv_projectile_max_phys_radius"):GetInt())
			projectile_max_phys_radius_numbox:SetMin(0) projectile_max_phys_radius_numbox:SetDecimals(0) projectile_max_phys_radius_numbox:SetMax(1000)
			projectile_max_phys_radius_numbox:SetSize(400,30)
			projectile_max_phys_radius_numbox:SetConVar("pac_sv_projectile_max_phys_radius")

		local projectile_max_dmg_radius_numbox = vgui.Create("DNumSlider", projectiles_list_list)
			projectile_max_dmg_radius_numbox:SetText("Max projectile damage radius")
			projectile_max_dmg_radius_numbox:SetValue(GetConVar("pac_sv_projectile_max_damage_radius"):GetInt())
			projectile_max_dmg_radius_numbox:SetMin(0) projectile_max_dmg_radius_numbox:SetDecimals(0) projectile_max_dmg_radius_numbox:SetMax(5000)
			projectile_max_dmg_radius_numbox:SetSize(400,30)
			projectile_max_dmg_radius_numbox:SetConVar("pac_sv_projectile_max_damage_radius")

		local projectile_max_attract_radius_numbox = vgui.Create("DNumSlider", projectiles_list_list)
			projectile_max_attract_radius_numbox:SetText("Max projectile attract radius")
			projectile_max_attract_radius_numbox:SetValue(GetConVar("pac_sv_projectile_max_attract_radius"):GetInt())
			projectile_max_attract_radius_numbox:SetMin(0) projectile_max_attract_radius_numbox:SetDecimals(0) projectile_max_attract_radius_numbox:SetMax(100000000)
			projectile_max_attract_radius_numbox:SetSize(400,30)
			projectile_max_attract_radius_numbox:SetConVar("pac_sv_projectile_max_attract_radius")

		local projectile_max_dmg_numbox = vgui.Create("DNumSlider", projectiles_list_list)
			projectile_max_dmg_numbox:SetText("Max projectile damage")
			projectile_max_dmg_numbox:SetValue(GetConVar("pac_sv_projectile_max_damage"):GetInt())
			projectile_max_dmg_numbox:SetMin(0) projectile_max_dmg_numbox:SetDecimals(0) projectile_max_dmg_numbox:SetMax(100000000)
			projectile_max_dmg_numbox:SetSize(400,30)
			projectile_max_dmg_numbox:SetConVar("pac_sv_projectile_max_damage")

		local projectile_max_speed_numbox = vgui.Create("DNumSlider", projectiles_list_list)
			projectile_max_speed_numbox:SetText("Max projectile speed")
			projectile_max_speed_numbox:SetValue(GetConVar("pac_sv_projectile_max_speed"):GetInt())
			projectile_max_speed_numbox:SetMin(0) projectile_max_speed_numbox:SetDecimals(0) projectile_max_speed_numbox:SetMax(50000)
			projectile_max_speed_numbox:SetSize(400,30)
			projectile_max_speed_numbox:SetConVar("pac_sv_projectile_max_speed")

		local projectile_max_mass_numbox = vgui.Create("DNumSlider", projectiles_list_list)
			projectile_max_mass_numbox:SetText("Max projectile mass")
			projectile_max_mass_numbox:SetValue(GetConVar("pac_sv_projectile_max_mass"):GetInt())
			projectile_max_mass_numbox:SetMin(0) projectile_max_mass_numbox:SetDecimals(0) projectile_max_mass_numbox:SetMax(500000)
			projectile_max_mass_numbox:SetSize(400,30)
			projectile_max_mass_numbox:SetConVar("pac_sv_projectile_max_mass")
	end

	do --damage zone
		local damagezone_list = master_list:Add("Damage Zone")
			damagezone_list.Header:SetSize(40,40)
			damagezone_list.Header:SetFont("DermaLarge")
			local damagezone_list_list = vgui.Create("DListLayout")
			damagezone_list_list:DockPadding(20,0,20,20)
			damagezone_list:SetContents(damagezone_list_list)

		local sv_dmgzone_box = vgui.Create("DCheckBoxLabel", damagezone_list_list)
			sv_dmgzone_box:SetText("Allow damage zone")
			sv_dmgzone_box:SetSize(400,30)
			sv_dmgzone_box:SetConVar("pac_sv_damage_zone")

		local max_dmgzone_radius_numbox = vgui.Create("DNumSlider", damagezone_list_list)
			max_dmgzone_radius_numbox:SetText("Max damage zone radius")
			max_dmgzone_radius_numbox:SetValue(GetConVar("pac_sv_damage_zone_max_radius"):GetInt())
			max_dmgzone_radius_numbox:SetMin(0) max_dmgzone_radius_numbox:SetDecimals(0) max_dmgzone_radius_numbox:SetMax(50000)
			max_dmgzone_radius_numbox:SetSize(400,30)
			max_dmgzone_radius_numbox:SetConVar("pac_sv_damage_zone_max_radius")

		local max_dmgzone_length_numbox = vgui.Create("DNumSlider", damagezone_list_list)
			max_dmgzone_length_numbox:SetText("Max damage zone length")
			max_dmgzone_length_numbox:SetValue(GetConVar("pac_sv_damage_zone_max_length"):GetInt())
			max_dmgzone_length_numbox:SetMin(0) max_dmgzone_length_numbox:SetDecimals(0) max_dmgzone_length_numbox:SetMax(50000)
			max_dmgzone_length_numbox:SetSize(400,30)
			max_dmgzone_length_numbox:SetConVar("pac_sv_damage_zone_max_length")

		local max_dmgzone_damage_numbox = vgui.Create("DNumSlider", damagezone_list_list)
			max_dmgzone_damage_numbox:SetText("Max damage zone damage")
			max_dmgzone_damage_numbox:SetValue(GetConVar("pac_sv_damage_zone_max_damage"):GetInt())
			max_dmgzone_damage_numbox:SetMin(0) max_dmgzone_damage_numbox:SetDecimals(0) max_dmgzone_damage_numbox:SetMax(100000000)
			max_dmgzone_damage_numbox:SetSize(400,30)
			max_dmgzone_damage_numbox:SetConVar("pac_sv_damage_zone_max_damage")

		local sv_dmgzone_allow_dissolve_box = vgui.Create("DCheckBoxLabel", damagezone_list_list)
			sv_dmgzone_allow_dissolve_box:SetText("Allow damage entity dissolvers")
			sv_dmgzone_allow_dissolve_box:SetSize(400,30)
			sv_dmgzone_allow_dissolve_box:SetConVar("pac_sv_damage_zone_allow_dissolve")
			
	end

	do --lock part
		local lock_list = master_list:Add("Lock part")
			lock_list.Header:SetSize(40,40)
			lock_list.Header:SetFont("DermaLarge")
			local lock_list_list = vgui.Create("DListLayout")
			lock_list_list:DockPadding(20,0,20,20)
			lock_list:SetContents(lock_list_list)

		local sv_lock_allow_box = vgui.Create("DCheckBoxLabel", lock_list_list)
			sv_lock_allow_box:SetText("Allow lock part")
			sv_lock_allow_box:SetSize(400,30)
			sv_lock_allow_box:SetConVar("pac_sv_lock")
		
		local sv_lock_grab_box = vgui.Create("DCheckBoxLabel", lock_list_list)
			sv_lock_grab_box:SetText("Allow lock part grabbing")
			sv_lock_grab_box:SetSize(400,30)
			sv_lock_grab_box:SetConVar("pac_sv_lock_grab")

		local sv_lock_grab_ply_box = vgui.Create("DCheckBoxLabel", lock_list_list)
			sv_lock_grab_ply_box:SetText("Allow grabbing players")
			sv_lock_grab_ply_box:SetSize(400,30)
			sv_lock_grab_ply_box:SetConVar("pac_sv_lock_allow_grab_ply")

		local sv_lock_grab_npc_box = vgui.Create("DCheckBoxLabel", lock_list_list)
			sv_lock_grab_npc_box:SetText("Allow grabbing NPCs")
			sv_lock_grab_npc_box:SetSize(400,30)
			sv_lock_grab_npc_box:SetConVar("pac_sv_lock_allow_grab_npc")

		local sv_lock_grab_ents_box = vgui.Create("DCheckBoxLabel", lock_list_list)
			sv_lock_grab_ents_box:SetText("Allow grabbing other entities")
			sv_lock_grab_ents_box:SetSize(400,30)
			sv_lock_grab_ents_box:SetConVar("pac_sv_lock_allow_grab_ent")

		local sv_lock_teleport_box = vgui.Create("DCheckBoxLabel", lock_list_list)
			sv_lock_teleport_box:SetText("Allow lock part teleportation")
			sv_lock_teleport_box:SetSize(400,30)
			sv_lock_teleport_box:SetConVar("pac_sv_lock_teleport")

		local max_lock_radius_numbox = vgui.Create("DNumSlider", lock_list_list)
			max_lock_radius_numbox:SetText("Max lock part grab range")
			max_lock_radius_numbox:SetValue(GetConVar("pac_sv_lock_max_grab_radius"):GetInt())
			max_lock_radius_numbox:SetMin(0) max_lock_radius_numbox:SetDecimals(0) max_lock_radius_numbox:SetMax(5000)
			max_lock_radius_numbox:SetSize(400,30)
			max_lock_radius_numbox:SetConVar("pac_sv_lock_max_grab_radius")
	end

	do --force
		local force_list = master_list:Add("Force part")
			force_list.Header:SetSize(40,40)
			force_list.Header:SetFont("DermaLarge")
			local force_list_list = vgui.Create("DListLayout")
			force_list_list:DockPadding(20,0,20,20)
			force_list:SetContents(force_list_list)

		local sv_force_box = vgui.Create("DCheckBoxLabel", force_list_list)
			sv_force_box:SetText("Allow force part")
			sv_force_box:SetSize(400,30)
			sv_force_box:SetConVar("pac_sv_force")

		local max_force_radius_numbox = vgui.Create("DNumSlider", force_list_list)
			max_force_radius_numbox:SetText("Max force part radius")
			max_force_radius_numbox:SetValue(GetConVar("pac_max_contraption_entities"):GetInt())
			max_force_radius_numbox:SetMin(0) max_force_radius_numbox:SetDecimals(0) max_force_radius_numbox:SetMax(50000)
			max_force_radius_numbox:SetSize(400,30)
			max_force_radius_numbox:SetConVar("pac_sv_force_max_radius")

		local max_force_length_numbox = vgui.Create("DNumSlider", force_list_list)
			max_force_length_numbox:SetText("Max force part length")
			max_force_length_numbox:SetValue(GetConVar("pac_max_contraption_entities"):GetInt())
			max_force_length_numbox:SetMin(0) max_force_length_numbox:SetDecimals(0) max_force_length_numbox:SetMax(50000)
			max_force_length_numbox:SetSize(400,30)
			max_force_length_numbox:SetConVar("pac_sv_force_max_length")

		local max_force_amount_numbox = vgui.Create("DNumSlider", force_list_list)
			max_force_amount_numbox:SetText("Max force part amount")
			max_force_amount_numbox:SetValue(GetConVar("pac_max_contraption_entities"):GetInt())
			max_force_amount_numbox:SetMin(0) max_force_amount_numbox:SetDecimals(0) max_force_amount_numbox:SetMax(10000000)
			max_force_amount_numbox:SetSize(400,30)
			max_force_amount_numbox:SetConVar("pac_sv_force_max_amount")
	end
	return master_list
end

function pace.FillServerSettings(pnl)
	local pnl = pnl

	local master_list = vgui.Create("DCategoryList", pnl)
	master_list:Dock(FILL)
	
	--models/entity
			--[[
				pac_allow_blood_color
				pac_allow_mdl
				pac_allow_mdl_entity
				pac_modifier_model
				pac_modifier_size
			]]
	
	local model_category = master_list:Add("Allowed Playermodel Mutations")
	model_category.Header:SetSize(40,40)
	model_category.Header:SetFont("DermaLarge")
	local model_category_list = vgui.Create("DListLayout")
	model_category_list:DockPadding(20,0,20,20)
	model_category:SetContents(model_category_list)

	local pac_allow_blood_color_box = vgui.Create("DCheckBoxLabel", master_list)
		pac_allow_blood_color_box:SetText("Blood")
		pac_allow_blood_color_box:SetSize(400,30)
		pac_allow_blood_color_box:SetConVar("pac_allow_blood_color")
		model_category_list:Add(pac_allow_blood_color_box)
	local pac_allow_mdl_box = vgui.Create("DCheckBoxLabel", master_list)
		pac_allow_mdl_box:SetText("MDL")
		pac_allow_mdl_box:SetSize(400,30)
		pac_allow_mdl_box:SetConVar("pac_allow_mdl")
		model_category_list:Add(pac_allow_mdl_box)
	local pac_allow_mdl_entity_box = vgui.Create("DCheckBoxLabel", master_list)
		pac_allow_mdl_entity_box:SetText("Entity MDL")
		pac_allow_mdl_entity_box:SetSize(400,30)
		pac_allow_mdl_entity_box:SetConVar("pac_allow_mdl_entity")
		model_category_list:Add(pac_allow_mdl_entity_box)
	local pac_modifier_model_box = vgui.Create("DCheckBoxLabel", master_list)
		pac_modifier_model_box:SetText("Entity model")
		pac_modifier_model_box:SetSize(400,30)
		pac_modifier_model_box:SetConVar("pac_modifier_model")
		model_category_list:Add(pac_modifier_model_box)
	local pac_modifier_size_box = vgui.Create("DCheckBoxLabel", master_list)
		pac_modifier_size_box:SetText("Entity size")
		pac_modifier_size_box:SetSize(400,30)
		pac_modifier_size_box:SetConVar("pac_modifier_size")
		model_category_list:Add(pac_modifier_size_box)
	
	--movement and mass
		--[[
			pac_free_movement
		]]
	
	local movement_category = master_list:Add("Player Movement")
	movement_category.Header:SetSize(40,40)
	movement_category.Header:SetFont("DermaLarge")
	local movement_category_list = vgui.Create("DListLayout")
	movement_category_list:DockPadding(20,20,20,20)
	movement_category:SetContents(movement_category_list)

	local pac_allow_movement_form = vgui.Create("DComboBox", movement_category_list)
		pac_allow_movement_form:SetText("Allow PAC player movement")
		--pac_allow_movement_form:SetSize(400,20)
		pac_allow_movement_form:SetSortItems(false)

		pac_allow_movement_form:AddChoice("disabled")
		pac_allow_movement_form:AddChoice("disabled if noclip not allowed")
		pac_allow_movement_form:AddChoice("enabled")

		pac_allow_movement_form.OnSelect = function(_, _, value)
			if value == "disabled" then
				net.Start("pac_send_sv_cvar")
				net.WriteString("pac_free_movement")
				net.WriteString("0")
				net.SendToServer()
				--pac_allow_movement_form.form = generic_form("PAC player movement is disabled.")
			elseif value == "disabled if noclip not allowed" then
				net.Start("pac_send_sv_cvar")
				net.WriteString("pac_free_movement")
				net.WriteString("-1")
				net.SendToServer()
				--pac_allow_movement_form.form = generic_form("PAC player movement is disabled if noclip is not allowed.")
			elseif value == "enabled" then
				net.Start("pac_send_sv_cvar")
				net.WriteString("pac_free_movement")
				net.WriteString("1")
				net.SendToServer()
				--pac_allow_movement_form.form = generic_form("PAC player movement is enabled.")
			end
		end
		
		--mode:ChooseOption(mode_str)
		
	local pac_player_movement_allow_mass_box = vgui.Create("DCheckBoxLabel", movement_category_list)
		pac_player_movement_allow_mass_box:SetText("Allow Modify Mass")
		pac_player_movement_allow_mass_box:SetSize(400,30)
		movement_category_list:Add(pac_player_movement_allow_mass_box)
		pac_player_movement_allow_mass_box:SetConVar("pac_player_movement_allow_mass")

	local playermovement_min_mass_numbox = vgui.Create("DNumSlider", movement_category_list)
		playermovement_min_mass_numbox:SetText("Mimnimum mass players can set for themselves")
		playermovement_min_mass_numbox:SetValue(GetConVar("pac_player_movement_min_mass"):GetFloat())
		playermovement_min_mass_numbox:SetMin(0.01) playermovement_min_mass_numbox:SetDecimals(0) playermovement_min_mass_numbox:SetMax(1000000)
		playermovement_min_mass_numbox:SetSize(400,30)
		movement_category_list:Add(playermovement_min_mass_numbox)
		playermovement_min_mass_numbox:SetConVar("pac_player_movement_min_mass")
		

	local playermovement_max_mass_numbox = vgui.Create("DNumSlider", movement_category_list)
		playermovement_max_mass_numbox:SetText("Maximum mass players can set for themselves")
		playermovement_max_mass_numbox:SetValue(GetConVar("pac_player_movement_max_mass"):GetFloat())
		playermovement_max_mass_numbox:SetMin(0.01) playermovement_max_mass_numbox:SetDecimals(0) playermovement_max_mass_numbox:SetMax(1000000)
		playermovement_max_mass_numbox:SetSize(400,30)
		movement_category_list:Add(playermovement_max_mass_numbox)
		playermovement_max_mass_numbox:SetConVar("pac_player_movement_max_mass")
		

	local pac_player_movement_allow_mass_dmgscaling_box = vgui.Create("DCheckBoxLabel", movement_category_list)
		pac_player_movement_allow_mass_dmgscaling_box:SetText("Allow damage scaling of physics damage based on player's mass")
		pac_player_movement_allow_mass_dmgscaling_box:SetSize(400,30)
		movement_category_list:Add(pac_player_movement_allow_mass_dmgscaling_box)
		pac_player_movement_allow_mass_dmgscaling_box:SetConVar("pac_player_movement_physics_damage_scaling")
		movement_category_list:Add(pac_player_movement_allow_mass_dmgscaling_box)

		
	--wear limits and bans
		--[[
			pac_sv_draw_distance
			pac_sv_hide_outfit_on_death WORKSHOP DEPRECATED
			pac_submit_limit
			pac_submit_spam
			pac_ban
			pac_unban
		]]
	
	local wear_list = master_list:Add("Server wearing/drawing")
	wear_list.Header:SetSize(40,40)
	wear_list.Header:SetFont("DermaLarge")
	local draw_distance_list = vgui.Create("DListLayout")
	draw_distance_list:DockPadding(20,0,20,20)
	wear_list:SetContents(draw_distance_list)

	local draw_dist_numbox = vgui.Create("DNumSlider", draw_distance_list)
		draw_dist_numbox:SetText("Server draw distance")
		draw_dist_numbox:SetValue(GetConVar("pac_sv_draw_distance"):GetInt())
		draw_dist_numbox:SetMin(0) draw_dist_numbox:SetDecimals(0) draw_dist_numbox:SetMax(50000)
		draw_dist_numbox:SetSize(400,30)
		draw_dist_numbox:SetConVar("pac_sv_draw_distance")

	local pac_submit_limit_numbox = vgui.Create("DNumSlider", draw_distance_list)
		pac_submit_limit_numbox:SetText("pac_submit limit")
		pac_submit_limit_numbox:SetValue(GetConVar("pac_submit_limit"):GetInt())
		pac_submit_limit_numbox:SetMin(0) pac_submit_limit_numbox:SetDecimals(0) pac_submit_limit_numbox:SetMax(100)
		pac_submit_limit_numbox:SetSize(400,30)
		pac_submit_limit_numbox:SetConVar("pac_submit_limit")

	local pac_submit_spam_box = vgui.Create("DCheckBoxLabel", draw_distance_list)
		pac_submit_spam_box:SetText("prevent pac_submit spam")
		pac_submit_spam_box:SetSize(400,30)
		pac_submit_spam_box:SetConVar("pac_submit_spam")


	
	--misc
		--[[
			sv_pac_webcontent_allow_no_content_length
			sv_pac_webcontent_limit
			pac_to_contraption_allow
			pac_max_contraption_entities
			pac_restrictions
		]]
	local misc_list = master_list:Add("Misc")
	misc_list.Header:SetSize(40,40)
	misc_list.Header:SetFont("DermaLarge")
	local misc_list_list = vgui.Create("DListLayout")
	misc_list_list:DockPadding(20,0,20,20)
	misc_list:SetContents(misc_list_list)
	local webcontent_no_content_box = vgui.Create("DCheckBoxLabel", misc_list_list)
		webcontent_no_content_box:SetText("allow downloads with no content length")
		webcontent_no_content_box:SetSize(400,30)
		webcontent_no_content_box:SetConVar("sv_pac_webcontent_allow_no_content_length")

	local contraption_box = vgui.Create("DCheckBoxLabel", misc_list_list)
		contraption_box:SetText("allow contraptions")
		contraption_box:SetSize(400,30)
		contraption_box:SetConVar("pac_to_contraption_allow")
	
	local contraption_entities_numbox = vgui.Create("DNumSlider", misc_list_list)
		contraption_entities_numbox:SetText("PAC3 contraption entities limit")
		contraption_entities_numbox:SetValue(GetConVar("pac_max_contraption_entities"):GetInt())
		contraption_entities_numbox:SetMin(0) contraption_entities_numbox:SetDecimals(0) contraption_entities_numbox:SetMax(200)
		contraption_entities_numbox:SetSize(400,30)
		contraption_entities_numbox:SetConVar("pac_max_contraption_entities")

	local cam_restrict_box = vgui.Create("DCheckBoxLabel", misc_list_list)
		cam_restrict_box:SetText("restrict PAC editor camera movement")
		cam_restrict_box:SetSize(400,30)
		cam_restrict_box:SetConVar("pac_restrictions")
	

	return master_list
end



--part order, shortcuts
function pace.FillEditorSettings(pnl)

	local buildlist_partmenu = {}
	local f = vgui.Create( "DPanel", pnl )
	f:SetSize(800)
	f:Center()

	local LeftPanel = vgui.Create( "DPanel", f ) -- Can be any panel, it will be stretched

	local partmenu_order_presets = vgui.Create("DComboBox",LeftPanel)
	partmenu_order_presets:SetText("Select a part menu preset")
	partmenu_order_presets:AddChoice("factory preset")
	partmenu_order_presets:AddChoice("expanded PAC4.5 preset")
	partmenu_order_presets:AddChoice("custom preset")
	partmenu_order_presets:AddChoice("bulk select poweruser")
	partmenu_order_presets:SetX(10) partmenu_order_presets:SetY(10)
	partmenu_order_presets:SetWidth(200)
	partmenu_order_presets:SetHeight(20)

	local partmenu_apply_button = vgui.Create("DButton", LeftPanel)
	partmenu_apply_button:SetText("Apply")
	partmenu_apply_button:SetX(220)
	partmenu_apply_button:SetY(10)
	partmenu_apply_button:SetWidth(65)
	partmenu_apply_button:SetImage('icon16/accept.png')
	
	local partmenu_clearlist_button = vgui.Create("DButton", LeftPanel)
	partmenu_clearlist_button:SetText("Clear")
	partmenu_clearlist_button:SetX(285)
	partmenu_clearlist_button:SetY(10)
	partmenu_clearlist_button:SetWidth(65)
	partmenu_clearlist_button:SetImage('icon16/application_delete.png')

	local partmenu_savelist_button = vgui.Create("DButton", LeftPanel)
	partmenu_savelist_button:SetText("Save")
	partmenu_savelist_button:SetX(350)
	partmenu_savelist_button:SetY(10)
	partmenu_savelist_button:SetWidth(70)
	partmenu_savelist_button:SetImage('icon16/disk.png')
	


	local partmenu_choices = vgui.Create("DScrollPanel", LeftPanel)
	local partmenu_choices_textAdd = vgui.Create("DLabel", LeftPanel)
	partmenu_choices_textAdd:SetText("ADD MENU COMPONENTS")
	partmenu_choices_textAdd:SetFont("DermaDefaultBold")
	partmenu_choices_textAdd:SetColor(Color(0,200,0))
	partmenu_choices_textAdd:SetWidth(200)
	partmenu_choices_textAdd:SetX(10)
	partmenu_choices_textAdd:SetY(30)

	local partmenu_choices_textRemove = vgui.Create("DLabel", LeftPanel)
	partmenu_choices_textRemove:SetText("DOUBLE CLICK TO REMOVE")
	partmenu_choices_textRemove:SetColor(Color(200,0,0))
	partmenu_choices_textRemove:SetFont("DermaDefaultBold")
	partmenu_choices_textRemove:SetWidth(200)
	partmenu_choices_textRemove:SetX(220)
	partmenu_choices_textRemove:SetY(30)

	local partmenu_previews = vgui.Create("DListView", LeftPanel)
	partmenu_previews:AddColumn("index")
	partmenu_previews:AddColumn("control name")
	partmenu_previews:SetSortable(false)
	partmenu_previews:SetX(220)
	partmenu_previews:SetY(50)
	partmenu_previews:SetHeight(320)
	partmenu_previews:SetWidth(200)


	
	local shortcutaction_choices = vgui.Create("DComboBox", LeftPanel)
	shortcutaction_choices:SetText("Select a PAC action")
	for _,name in ipairs(pace.PACActionShortcut_Dictionary) do
		shortcutaction_choices:AddChoice(name)
	end
	shortcutaction_choices:SetX(10) shortcutaction_choices:SetY(400)
	shortcutaction_choices:SetWidth(170)
	shortcutaction_choices:SetHeight(20)
	shortcutaction_choices:ChooseOptionID(1)
	
	function shortcutaction_choices:Think()
		self.next = self.next or 0
		self.found = self.found or false
		if self.next < RealTime() then self.found = false end
		if self:IsHovered() then 
			if input.IsKeyDown(KEY_UP) then
				if not self.found then self:ChooseOptionID(math.Clamp(self:GetSelectedID() + 1,1,table.Count(pace.PACActionShortcut_Dictionary))) self.found = true self.next = RealTime() + 0.3 end
			elseif input.IsKeyDown(KEY_DOWN) then
				if not self.found then self:ChooseOptionID(math.Clamp(self:GetSelectedID() - 1,1,table.Count(pace.PACActionShortcut_Dictionary))) self.found = true self.next = RealTime() + 0.3 end
			else self.found = false end
		else self.found = false
		end
	end
	
	local shortcuts_description_text = vgui.Create("DLabel", LeftPanel)
	shortcuts_description_text:SetFont("DermaDefaultBold")
	shortcuts_description_text:SetText("Edit keyboard shortcuts")
	shortcuts_description_text:SetColor(Color(0,0,0))
	shortcuts_description_text:SetWidth(200)
	shortcuts_description_text:SetX(10)
	shortcuts_description_text:SetY(380)

	local shortcutaction_presets = vgui.Create("DComboBox", LeftPanel)
	shortcutaction_presets:SetText("Select a shortcut preset")
	shortcutaction_presets:AddChoice("factory preset", pace.PACActionShortcut_Default)
	shortcutaction_presets:AddChoice("no CTRL preset", pace.PACActionShortcut_NoCTRL)
	shortcutaction_presets:AddChoice("Cedric's preset", pace.PACActionShortcut_Cedric)
	shortcutaction_presets:SetX(10) shortcutaction_presets:SetY(420)
	shortcutaction_presets:SetWidth(170)
	shortcutaction_presets:SetHeight(20)
	function shortcutaction_presets:OnSelect(num, name, data)
		pace.PACActionShortcut = data
		pac.Message("Selected shortcut preset: " .. name)
		for i,v in pairs(data) do
			if #v > 0 then MsgC(Color(50,250,50), i .. "\n") end
			for i2,v2 in pairs(v) do
				MsgC(Color(0,250,250), "\t" .. table.concat(v2, "+") .. "\n")
			end
		end
	end
	

	local shortcutaction_choices_textCurrentShortcut = vgui.Create("DLabel", LeftPanel)
	shortcutaction_choices_textCurrentShortcut:SetText("Shortcut to edit:")
	shortcutaction_choices_textCurrentShortcut:SetColor(Color(0,60,160))
	shortcutaction_choices_textCurrentShortcut:SetWidth(200)
	shortcutaction_choices_textCurrentShortcut:SetX(200)
	shortcutaction_choices_textCurrentShortcut:SetY(420)
	
	
	local shortcutaction_index = vgui.Create("DNumberWang", LeftPanel)
	shortcutaction_index:SetToolTip("index")
	shortcutaction_index:SetValue(1)
	shortcutaction_index:SetMin(1)
	shortcutaction_index:SetMax(10)
	shortcutaction_index:SetWidth(30)
	shortcutaction_index:SetHeight(20)
	shortcutaction_index:SetX(180)
	shortcutaction_index:SetY(400)

	local function update_shortcutaction_choices_textCurrentShortcut(num)
		shortcutaction_choices_textCurrentShortcut:SetText("<No shortcut at index "..num..">")
		num = tonumber(num)
		local action, val = shortcutaction_choices:GetSelected()
		local strs = {}
		
		if action and action ~= "" then
			if pace.PACActionShortcut[action] and pace.PACActionShortcut[action][num] then
				for i,v in ipairs(pace.PACActionShortcut[action][num]) do
					strs[i] = v
				end
				shortcutaction_choices_textCurrentShortcut:SetText("Shortcut to edit: " .. table.concat(strs, " + "))
			else
				shortcutaction_choices_textCurrentShortcut:SetText("<No shortcut at index "..num..">")
			end
		end
	end
	update_shortcutaction_choices_textCurrentShortcut(1)

	function shortcutaction_index:OnValueChanged(num)
		update_shortcutaction_choices_textCurrentShortcut(num)
	end

	function shortcutaction_choices:OnSelect(i, action)
		shortcutaction_index:OnValueChanged(shortcutaction_index:GetValue())
	end

	local binder1 = vgui.Create("DBinder", LeftPanel)
	binder1:SetX(10)
	binder1:SetY(440)
	binder1:SetHeight(30)
	binder1:SetWidth(90)
	function binder1:OnChange( num )
		if not num or num == 0 then return end
		if not input.GetKeyName( num ) then return end
		LocalPlayer():ChatPrint("New bound key 1: "..input.GetKeyName( num ))
		pace.FlashNotification("New bound key 1: "..input.GetKeyName( num ))
	end

	local binder2 = vgui.Create("DBinder", LeftPanel)
	binder2:SetX(105)
	binder2:SetY(440)
	binder2:SetHeight(30)
	binder2:SetWidth(90)
	function binder2:OnChange( num )
		if not num or num == 0 then return end
		if not input.GetKeyName( num ) then return end
		LocalPlayer():ChatPrint("New bound key 2: "..input.GetKeyName( num ))
		pace.FlashNotification("New bound key 2: "..input.GetKeyName( num ))
	end

	local binder3 = vgui.Create("DBinder", LeftPanel)
	binder3:SetX(200)
	binder3:SetY(440)
	binder3:SetHeight(30)
	binder3:SetWidth(90)
	function binder3:OnChange( num )
		if not num or num == 0 then return end
		if not input.GetKeyName( num ) then return end
		LocalPlayer():ChatPrint("New bound key 3: "..input.GetKeyName( num ))
		pace.FlashNotification("New bound key 3: "..input.GetKeyName( num ))
	end

	local function send_active_shortcut_to_assign(tbl)
		local action = shortcutaction_choices:GetValue()
		local index = shortcutaction_index:GetValue()
		
		if not tbl then
			pace.PACActionShortcut[action] = pace.PACActionShortcut[action] or {}
			pace.PACActionShortcut[action][index] = pace.PACActionShortcut[action][index] or {}

			if table.IsEmpty(pace.PACActionShortcut[action][index]) then
				pace.PACActionShortcut[action][index] = nil
				if table.IsEmpty(pace.PACActionShortcut[action]) then
					pace.PACActionShortcut[action] = nil
				end
			else
				pace.PACActionShortcut[action][index] = nil
			end
		elseif not table.IsEmpty(tbl) then
			pace.AssignEditorShortcut(shortcutaction_choices:GetValue(), tbl, shortcutaction_index:GetValue())
		end
		encode_table_to_file("pac_editor_shortcuts")
	end

	local bindclear = vgui.Create("DButton", LeftPanel)
	bindclear:SetText("clear keys")
	bindclear:SetTooltip("deletes the current shortcut at the current index")
	bindclear:SetX(10)
	bindclear:SetY(480)
	bindclear:SetHeight(30)
	bindclear:SetWidth(90)
	bindclear:SetColor(Color(200,0,0))
	function bindclear:DoClick()
		binder1:SetSelectedNumber(0)
		binder2:SetSelectedNumber(0)
		binder3:SetSelectedNumber(0)
		send_active_shortcut_to_assign()
		update_shortcutaction_choices_textCurrentShortcut(shortcutaction_index:GetValue())
	end

	local bindoverwrite = vgui.Create("DButton", LeftPanel)
	bindoverwrite:SetText("confirm")
	bindoverwrite:SetTooltip("applies the current shortcut combination at the current index")
	bindoverwrite:SetX(105)
	bindoverwrite:SetY(480)
	bindoverwrite:SetHeight(30)
	bindoverwrite:SetWidth(90)
	bindoverwrite:SetColor(Color(0,200,0))
	function bindoverwrite:DoClick()
		local tbl = {}
		local i = 1
		--print(binder1:GetValue(), binder2:GetValue(), binder3:GetValue())
		if binder1:GetValue() ~= 0 then tbl[i] = input.GetKeyName(binder1:GetValue()) i = i + 1 end
		if binder2:GetValue() ~= 0 then tbl[i] = input.GetKeyName(binder2:GetValue()) i = i + 1 end
		if binder3:GetValue() ~= 0 then tbl[i] = input.GetKeyName(binder3:GetValue()) end
		if not table.IsEmpty(tbl) then
			pace.FlashNotification("Combo " .. shortcutaction_index:GetValue() .. " committed: " .. table.concat(tbl," "))
			if not pace.PACActionShortcut[shortcutaction_choices:GetValue()] then
				pace.PACActionShortcut[shortcutaction_choices:GetValue()] = {}
			end
			send_active_shortcut_to_assign(tbl)
			update_shortcutaction_choices_textCurrentShortcut(shortcutaction_index:GetValue())
		end
		encode_table_to_file("pac_editor_shortcuts")
	end

	local bindcapture_text = vgui.Create("DLabel", LeftPanel)
	bindcapture_text:SetFont("DermaDefaultBold")
	bindcapture_text:SetText("")
	bindcapture_text:SetColor(Color(0,0,0))
	bindcapture_text:SetX(300)
	bindcapture_text:SetY(480)
	bindcapture_text:SetSize(300, 30)
	function bindcapture_text:Think()
		self:SetText(pace.bindcapturelabel_text)
	end
	local bindcapture = vgui.Create("DButton", LeftPanel)
	bindcapture:SetText("capture input")
	bindcapture:SetX(200)
	bindcapture:SetY(480)
	bindcapture:SetHeight(30)
	bindcapture:SetWidth(90)
	pace.bindcapturelabel_text = ""
	function bindcapture:DoClick()
		pace.delayshortcuts = RealTime() + 5
		local input_active = {}
		local no_input = true
		local inputs_str = ""
		local previous_inputs_str = ""
		pace.FlashNotification("Recording input... Release one key when you're done")

		hook.Add("Tick", "pace_buttoncapture_countdown", function()
			pace.delayshortcuts = RealTime() + 5
			local inputs_tbl = {}
			inputs_str = ""
			for i=1,172,1 do --build bool list of all current keys
				if input.IsKeyDown(i) then
					input_active[i] = true
					inputs_tbl[i] = true
					no_input = false
					inputs_str = inputs_str .. input.GetKeyName(i) .. " "
				else
					input_active[i] = false
				end
			end
			pace.bindcapturelabel_text = "Recording input:\n" .. inputs_str
			
			if previous_inputs_tbl and table.Count(previous_inputs_tbl) > 0 then
				if table.Count(inputs_tbl) < table.Count(previous_inputs_tbl) then
					pace.FlashNotification("ending input!" .. previous_inputs_str)

					local tbl = {}
					local i = 1
					for key,bool in pairs(previous_inputs_tbl) do
						tbl[i] = input.GetKeyName(key)
						i = i + 1
					end
					--print(shortcutaction_choices:GetValue(), shortcutaction_index:GetValue())
					pace.AssignEditorShortcut(shortcutaction_choices:GetValue(), tbl, shortcutaction_index:GetValue())
					--pace.PACActionShortcut[shortcutaction_choices:GetValue()][shortcutaction_index:GetValue()] = tbl
					pace.delayshortcuts = RealTime() + 5
					pace.bindcapturelabel_text = "Recorded input:\n" .. previous_inputs_str
					hook.Remove("Tick", "pace_buttoncapture_countdown")
				end
			end
			previous_inputs_str = inputs_str
			previous_inputs_tbl = inputs_tbl
		end)
		
	end

	local bulkbinder = vgui.Create("DBinder", LeftPanel)
	function bulkbinder:OnChange( num )
		GetConVar("pac_bulk_select_key"):SetString(input.GetKeyName( num ))
	end
	bulkbinder:SetX(210)
	bulkbinder:SetY(400)
	bulkbinder:SetSize(80,20)
	bulkbinder:SetText("bulk select key")

	local function ClearPartMenuPreviewList()
		local i = 0
		while (partmenu_previews:GetLine(i + 1) ~= nil) do
			i = i+1
		end
		for v=i,0,-1 do
			if partmenu_previews:GetLine(v) ~= nil then partmenu_previews:RemoveLine(v) end
			v = v - 1
		end
	end

	local function FindImage(option_name) 
		if option_name == "save" then
			return pace.MiscIcons.save
		elseif option_name == "load" then
			return pace.MiscIcons.load
		elseif option_name == "wear" then
			return pace.MiscIcons.wear
		elseif option_name == "remove" then
			return pace.MiscIcons.clear
		elseif option_name == "copy" then
			return pace.MiscIcons.copy
		elseif option_name == "paste" then
			return pace.MiscIcons.paste
		elseif option_name == "cut" then
			return 'icon16/cut.png'
		elseif option_name == "paste_properties" then
			return pace.MiscIcons.replace
		elseif option_name == "clone" then
			return pace.MiscIcons.clone
		elseif option_name == "partsize_info" then
			return'icon16/drive.png'
		elseif option_name == "bulk_apply_properties" then
			return 'icon16/application_form.png'
		elseif option_name == "bulk_select" then
			return 'icon16/table_multiple.png'
		elseif option_name == "spacer" then
			return 'icon16/application_split.png'
		elseif option_name == "hide_editor" then
			return 'icon16/application_delete.png'
		elseif option_name == "expand_all" then
			return 'icon16/arrow_down.png'
		elseif option_name == "collapse_all" then
			return 'icon16/arrow_in.png'
		elseif option_name == "copy_uid" then
			return pace.MiscIcons.uniqueid
		elseif option_name == "help_part_info" then
			return 'icon16/information.png'
		elseif option_name == "reorder_movables" then 
			return 'icon16/application_double.png'
		end
		return 'icon16/world.png'
	end

	partmenu_choices:SetY(50)
	partmenu_choices:SetX(10)
	for i,v in pairs(pace.operations_all_operations) do
		local pnl = vgui.Create("DButton", menu)
		pnl:SetText(string.Replace(string.upper(v),"_"," "))
		pnl:SetImage(FindImage(v))

		function pnl:DoClick()
			table.insert(buildlist_partmenu,v)
			partmenu_previews:AddLine(#buildlist_partmenu,v)
		end
		partmenu_choices:AddItem(pnl)
		pnl:SetHeight(18)
		pnl:SetWidth(200)
		pnl:SetY(20*(i-1))
	end
	
	partmenu_choices:SetWidth(200)
	partmenu_choices:SetHeight(320)
	partmenu_choices:SetVerticalScrollbarEnabled(true)
	

	local RightPanel = vgui.Create( "DTree", f )
	Test_Node = RightPanel:AddNode( "Test", "icon16/world.png" )
	test_part = pac.CreatePart("base") //the menu needs a part to get its full version in preview
	function RightPanel:DoRightClick()
		temp_list = pace.operations_order
		pace.operations_order = buildlist_partmenu
		pace.OnPartMenu(test_part)
		temp_list = pace.operations_order
		pace.operations_order = temp_list
	end
	function RightPanel:DoClick()
		temp_list = pace.operations_order
		pace.operations_order = buildlist_partmenu
		pace.OnPartMenu(test_part)
		temp_list = pace.operations_order
		pace.operations_order = temp_list
	end 
	test_part:Remove() //dumb workaround but it works


	local div = vgui.Create( "DHorizontalDivider", f )
	div:Dock( FILL )
	div:SetLeft( LeftPanel )
	div:SetRight( RightPanel )
	
	div:SetDividerWidth( 8 )
	div:SetLeftMin( 50 )
	div:SetRightMin( 50 )
	div:SetLeftWidth( 450 )
	partmenu_order_presets.OnSelect = function( self, index, value )
		local temp_list = {"wear","save","load"}
		if value == "factory preset" then
			temp_list = table.Copy(pace.operations_default)
		elseif value == "expanded PAC4.5 preset" then
			temp_list = table.Copy(pace.operations_experimental)
		elseif value == "bulk select poweruser" then
			temp_list = table.Copy(pace.operations_bulk_poweruser)
		elseif value == "custom preset" then
			temp_list = {"wear","save","load"}
		end
		ClearPartMenuPreviewList()
		for i,v in ipairs(temp_list) do
			partmenu_previews:AddLine(i,v)
		end
		buildlist_partmenu = temp_list
	end

	function partmenu_apply_button:DoClick() 
		pace.operations_order = buildlist_partmenu
	end

	function partmenu_clearlist_button:DoClick() 
		ClearPartMenuPreviewList()
		buildlist_partmenu = {}
	end

	function partmenu_savelist_button:DoClick()
		encode_table_to_file("pac_editor_partmenu_layouts")
	end

	function partmenu_previews:DoDoubleClick(id, line)
		table.remove(buildlist_partmenu,id)
		
		ClearPartMenuPreviewList()
		for i,v in ipairs(buildlist_partmenu) do
			partmenu_previews:AddLine(i,v)
		end

		PrintTable(buildlist_partmenu)
	end

	return f
end

--camera movement
function pace.FillEditorSettings2(pnl)
	local panel = vgui.Create( "DPanel", pnl )
	--[[ movement binds
		CreateConVar("pac_editor_camera_forward_bind", "w")
	
		CreateConVar("pac_editor_camera_back_bind", "s")
	
		CreateConVar("pac_editor_camera_moveleft_bind", "a")
	
		CreateConVar("pac_editor_camera_moveright_bind", "d")
	
		CreateConVar("pac_editor_camera_up_bind", "space")
	
		CreateConVar("pac_editor_camera_down_bind", "")
		
		]]

	--[[pace.camera_movement_binds = {
		["forward"] = pace.camera_forward_bind,
		["back"] = pace.camera_back_bind,
		["moveleft"] = pace.camera_moveleft_bind,
		["moveright"] = pace.camera_moveright_bind,
		["up"] = pace.camera_up_bind,
		["down"] = pace.camera_down_bind,
		["slow"] = pace.camera_slow_bind,
		["speed"] = pace.camera_speed_bind
		}
	]]

	local movement_binders_label = vgui.Create("DLabel", panel)
	movement_binders_label:SetText("PAC editor camera movement")
	movement_binders_label:SetFont("DermaDefaultBold")
	movement_binders_label:SetColor(Color(0,0,0))
	movement_binders_label:SetSize(200,40)
	movement_binders_label:SetPos(30,5)

	local forward_binder = vgui.Create("DBinder", panel)
		forward_binder:SetSize(40,40)
		forward_binder:SetPos(100,40)
		forward_binder:SetTooltip("move forward")
		forward_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["forward"]:GetString()))
		function forward_binder:OnChange(num)
			pace.camera_movement_binds["forward"]:SetString(input.GetKeyName( num ))
		end

	local back_binder = vgui.Create("DBinder", panel)
		back_binder:SetSize(40,40)
		back_binder:SetPos(100,80)
		back_binder:SetTooltip("move back")
		back_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["back"]:GetString()))
		function back_binder:OnChange(num)
			pace.camera_movement_binds["back"]:SetString(input.GetKeyName( num ))
		end

	local moveleft_binder = vgui.Create("DBinder", panel)
		moveleft_binder:SetSize(40,40)
		moveleft_binder:SetPos(60,80)
		moveleft_binder:SetTooltip("move left")
		moveleft_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["moveleft"]:GetString()))
		function moveleft_binder:OnChange(num)
			pace.camera_movement_binds["moveleft"]:SetString(input.GetKeyName( num ))
		end

	local moveright_binder = vgui.Create("DBinder", panel)
		moveright_binder:SetSize(40,40)
		moveright_binder:SetPos(140,80)
		moveright_binder:SetTooltip("move right")
		moveright_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["moveright"]:GetString()))
		function moveright_binder:OnChange(num)
			pace.camera_movement_binds["moveright"]:SetString(input.GetKeyName( num ))
		end

	local up_binder = vgui.Create("DBinder", panel)
		up_binder:SetSize(40,40)
		up_binder:SetPos(180,40)
		up_binder:SetTooltip("move up")
		up_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["up"]:GetString()))
		function up_binder:OnChange(num)
			pace.camera_movement_binds["up"]:SetString(input.GetKeyName( num ))
		end

	local down_binder = vgui.Create("DBinder", panel)
		down_binder:SetSize(40,40)
		down_binder:SetPos(180,80)
		down_binder:SetTooltip("move down")
		down_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["down"]:GetString()))
		function down_binder:OnChange(num)
			print(num, input.GetKeyName( num ))
			pace.camera_movement_binds["down"]:SetString(input.GetKeyName( num ))
		end

	local slow_binder = vgui.Create("DBinder", panel)
		slow_binder:SetSize(40,40)
		slow_binder:SetPos(20,80)
		slow_binder:SetTooltip("go slow")
		slow_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["slow"]:GetString()))
		function slow_binder:OnChange(num)
			pace.camera_movement_binds["slow"]:SetString(input.GetKeyName( num ))
		end

	local speed_binder = vgui.Create("DBinder", panel)
		speed_binder:SetSize(40,40)
		speed_binder:SetPos(20,40)
		speed_binder:SetTooltip("go fast")
		speed_binder:SetValue(input.GetKeyCode(pace.camera_movement_binds["speed"]:GetString()))
		function speed_binder:OnChange(num)
			pace.camera_movement_binds["speed"]:SetString(input.GetKeyName( num ))
		end
	
	return panel
end

function pace.GetPartMenuComponentPreviewForMenuEdit(menu, option_name)
	local pnl = vgui.Create("DButton", menu)
	pnl:SetText(string.Replace(string.upper(option_name),"_"," "))
	return pnl
end


decode_table_from_file("pac_editor_shortcuts")
decode_table_from_file("pac_editor_partmenu_layouts")
decode_table_from_file("pac_part_categories")