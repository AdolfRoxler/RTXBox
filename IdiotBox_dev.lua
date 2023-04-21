--[[
	Idiotbox v7
	Rewrite by AdolfRoxler -> TG NGGUH
	
	Phizz, the creator
	
	New contributors willing to be credited have been added
]]
--- Changelogs ---
local Changelogs = [[
New features include:
	- Dynamic configs
]]
--- Initial Values ---
local ProtectedFilenames = {["IdiotBox_latest.lua"]=true,["IdiotBox_backup.lua"]=true,["IdiotBox_dev.lua"]=true}
local build = 700
local folder = "IdiotBox"
local self = LocalPlayer()
--- Memory setup ---
local Entities = FindMetaTable("Entity")
local Players = FindMetaTable("Player")
local Commands = FindMetaTable("CUserCmd")
local Weapons = FindMetaTable("Weapon")
local Angles = FindMetaTable("Angle")
local Vectors = FindMetaTable("Vector")
local Materials = FindMetaTable("IMaterial")

require("bsendpacket")
require("fhook")
require("ChatClear")
require("dickwrap")
require("big")
--- Event setup ---
gameevent.Listen("entity_killed")
gameevent.Listen("player_disconnect")
gameevent.Listen("player_hurt")
--- Convar ---
CreateClientConVar("idiot_changename", "www.IB4G.net | Cry, dawg!", true, false)
--- Font aliases ---
surface.CreateFont("VisualsFont", {font = "Tahoma", size = 12, antialias = false, outline = true})
surface.CreateFont("MenuFont", {font = "Tahoma", size = 12, weight = 674, antialias = false, outline = true})
surface.CreateFont("MenuFont2", {font = "Tahoma", size = 12, antialias = true, outline = true})
surface.CreateFont("MainFont", {font = "Tahoma", size = 16, weight = 1300, antialias = false, outline = false})
surface.CreateFont("MainFont2", {font = "Tahoma", size = 11, weight = 640, antialias = false, outline = true})
surface.CreateFont("MainFont3", {font = "Tahoma", size = 13, weight = 800, antialias = false, outline = true})
surface.CreateFont("MiscFont", {font = "Tahoma", size = 12, weight = 900, antialias = false, outline = true})
surface.CreateFont("MiscFont2", {font = "Tahoma", size = 12, weight = 900, antialias = false, outline = false})
surface.CreateFont("MiscFont3", {font = "Tahoma", size = 13, weight = 674, antialias = false, outline = true})
--- Creditation ---

-- PS: From Phizz' list
local Contributors = {
	["STEAM_0:0:63644275"] = "Creator",
	["STEAM_0:0:162667998"] = "Creator",
	["STEAM_0:1:126050820"] = "Ex-manager",
	
	["STEAM_0:0:196578290"] = "Code dev",
	["STEAM_0:1:193781969"] = "Code dev",
	["STEAM_0:0:109145007"] = "Code dev",
	["STEAM_0:0:205376238"] = "Code dev",
	["STEAM_0:0:158432486"] = "Code dev",
	["STEAM:0:0:41908082"] = "Code dev",
	
	["STEAM_0:1:188710062"] = "Tester",
	["STEAM_0:1:191270548"] = "Tester",
	["STEAM_0:1:404757"] = "Tester",
	["STEAM_0:1:69536635"] = "Tester",
	["STEAM_0:0:150101893"] = "Tester",
	["STEAM_0:1:75441355"] = "Tester",
	
	["STEAM_0:0:453611223"] = "Multihelper",
	["STEAM_0:1:155573857"] = "Helper",
	
	["STEAM_0:1:59798110"] = "Advertiser",
	["STEAM_0:1:4375194"] = "Advertiser",
	
	["STEAM_0:1:101813068"] = "User #1",
}
--- Function 'speedener' ---
local V3 = Vector3
local NewCmdVar = CreateClientConVar
local typeof = type
local lowercase = string.lower
local uppercase = string.upper
local ScreenX = ScrW
local ScreenY = ScrH
--- Config ---
local DefaultConfig = {
	["general"] = {
		["optimize"] = false,
		["freecam"] = false,
		["anti-afk"] = false,
		["anti-ads"] = false,
		["anti-blind"] = false,
	},
	["esp"] = {},
	["gfuel"] = {
		["movement"] = {
			bhop = {status = false, auto = false},
		},
		["anti-aim"] = {
			status = false,
		},
		["aimbot"] = {
			status = false, 
			fov = 90, 
			interpolation = false, 
			silent = false, 
			afire = false, 
			azoom = false, 
			astop = false, 
			lock = false, 
			allowplayers = true,
			allowbots = true,
			allowteam = false,
			allowenemy = true,
			allowfriends = false,
			allowadmins = true,
			allowfrozen = false,
			allowednoclipped = false,
			alloweddriving = false,
			allowedtransparent = false,
			allowedoverheald = false,
			maxdistance = 1500, 
			maxvel = 1000, 
			maxhealth = 500,
			priority = "crosshair", 
		},
		["triggerbot"] = {status = false, smooth = false, azoom = false, astop = false, acrouch = false},
	},
	["hvh"] = {},
	["visuals"] = {
		thirdperson = {status = false, distance = 100}
	},
	["ttt"] = {
		["traitor-finder"] = false,
		["ignore-detectives"] = false,
		["ignore-traitors"] = false,
		["anti-roundreport"] = false,
		["anti-panels"] = false,
		["propkill"] = false,
	},
	["murder"] = {
		["murderer-finder"] = false,
		["anti-roundreport"] = false,
		["hide-footprints"] = false,
		["no-blackscreens"] = false,
	},
	["darkrp"] = {
		["anti-arrest"] = false,
		["prop-opacity"] = {status = false, opacity = 1},
		["show-money"] = false,
	},
	["miscellaneous"] = {
		["custom-name"] = "",
		["tooltips"] = false,
		["panic-mode"] = false,
		
		["no-recoil"] = false,
		["no-spread"] = false,
		["predict-projectiles"] = false,
		["auto-reload"] = false,
		["rapid-fire"] = {status = false, primary = true, delay=0},
		["abuse-interpolation"] = false,
		["abuse-bullet-time"] = false,
		["draw-fov-circle"] = false,
		["sight-lines"] = false,
		["wall-check"] = false,
	},
}

local CurrentConfig = DefaultConfig
--- Config Editor [MESS] ---
local function TranslateValue(str)
	local tr = lowercase(str)
	if str=="on" or str=="true" or str==1 then tr=true
	elseif str=="off" or str=="false" or str==0 then tr=false
	end
	return tr
end

local function changeData(tabl,pathArray) --- stolen from devforum | Source: https://devforum.roblox.com/t/how-to-make-equivalent-of-instancegetfullname-for-tables/1114061
	--send pathArray to client
	local template = table.Copy(DefaultConfig)
	for index, path in ipairs(pathArray) do
		if pathArray[index + 2]==nil then
			if typeof(pathArray[index + 1]) == typeof(template[path]) and pathArray[index + 1]~=nil and template[path]~=nil then tabl[path] = pathArray[index + 1] end
		else
			if tabl[path]==nil then
				break
			end
			if typeof(tabl[path]) == typeof(template[path]) and tabl[path]~=nil and template[path]~=nil then
				tabl = tabl[path] 
				template = template[path] 
				else break end
		end
	end
end

local function readData(tabel,pathArray) --- as you can guess this is to read values
	--send pathArray to client
	local template = table.Copy(DefaultConfig)
	local tabl = table.Copy(tabel)
	for index, path in ipairs(pathArray) do
		if typeof(template)~="table" then return tabl end
		
		if pathArray[index + 1]==nil then
			--if template[path]~=nil then 
			return tabl
			--end
		else
			if tabl[path]==nil then
				break
			end
			if typeof(tabl[path]) == typeof(template[path]) and tabl[path]~=nil and template[path]~=nil then
				tabl = tabl[path]
				template = template[path] 
			else break end
		end
	end
end

concommand.Add("idiot_setvalue", function(caller, cmd, args)
	local Lego = {}
	for _,N in pairs(args) do Lego[#Lego+1] = tonumber(N) or TranslateValue(lowercase(N)) end
	changeData(CurrentConfig,Lego)
end,nil,"Manually set values within IdiotBox. You should use this inside autoexec binds for your own toggles.")

--- DEBOUNCES ---
local menutoggle = false
local menudebounce = false
--- VARIABLES ---
local FakeX,FakeY = 0,0
local packetcount = 0
--- FUNCTIONS ---
function RotationCompensation(pCmd, flYawRotation)
    local yaw,flSpeed
    local vMove = Vector(pCmd:GetForwardMove(), pCmd:GetSideMove(), 0)

    flSpeed = vMove:Length2D()

    local cmdView = pCmd:GetViewAngles()
    cmdView:Normalize()

    local angMoveRotation = EyeAngles().y
    if isnumber(flYawRotation) then
        angMoveRotation = angMoveRotation - flYawRotation
    end

    --print("yaw rot move", angMoveRotation)

    yaw = math.deg(math.atan2(vMove.y, vMove.x))
    yaw = math.rad(cmdView.y - angMoveRotation + yaw)

    pCmd:SetForwardMove(math.cos(yaw) * flSpeed)
    pCmd:SetSideMove(math.sin(yaw) * flSpeed)

    if cmdView.x < -90 or cmdView.x > 90 then
        pCmd:SetForwardMove(-pCmd:GetForwardMove())
        pCmd:SetSideMove(-pCmd:GetSideMove())
    end
end

function bhop(cmd)
    if not CurrentConfig["gfuel"]["movement"].bhop.status then return end
    if self:IsOnGround() then if CurrentConfig["gfuel"]["movement"].bhop.auto then cmd:AddKey( IN_JUMP ) end return end
    if cmd:KeyDown( IN_JUMP ) then
        cmd:RemoveKey( IN_JUMP )
    end
end

local function FakeLag(cmd)
	if cmd:CommandNumber()==0 then return end
	packetcount = packetcount +1
	bsendpacket = queue>=14 and true
	packetcount = packetcont>=14 and 0 or packetcount
end

local function Movement(cmd)
	bhop(cmd)
	if cmd:CommandNumber()==0 then return end
	if CurrentConfig["gfuel"]["anti-aim"].status == true then
		if not bsendpacket then
			cmd:SetViewAngles(Angle(FakeX,FakeY,0))
			RotationCompensation(cmd)
		end
	end
end
local function Camera(ply, pos, ang, fov)


	local ThirdPerson = {
        origin = pos - (ang:Forward() * CurrentConfig["visuals"].thirdperson.distance) or pos,
        ang = ang,
        fov = fov,
        drawviewer =  CurrentConfig["visuals"].thirdperson.status
	}

    if CurrentConfig["visuals"].thirdperson.status then
        return ThirdPerson
    end
end
--- MENU TEST ---
local tabselect = "MainMenu"

local function DrawUpperText(w, h)
	surface.SetFont("MenuFont")
	local tw, th = surface.GetTextSize("")
	surface.SetTextPos(50, 15 - th / 2)
	surface.SetTextColor(HSVToColor(RealTime() * 45 % 360, 1, 1))
	surface.SetFont("MainFont")
	surface.DrawText("IdiotBox v6.9.b7")
	surface.SetTextPos(160, 18 - th / 2)
	surface.SetTextColor(0, 155, 230, 175)
	surface.SetFont("MainFont2")
	surface.DrawText("Latest build: April 15th 2023")
end

local function CreateSection(r, x, y, w, h, text)
	draw.RoundedBox(r, x, y, w, h, Color(40, 40, 60, 255))
	draw.SimpleText(text, "MainFont3", x+35, y-7, Color(50, 50, 250, 255),TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
end

local function CheckBox(text, parent, x, y, entry, type)
	local ibCheckbox = vgui.Create( "DCheckBoxLabel", parent)
	ibCheckbox:SetPos( x, y )
	ibCheckbox:SetFont("MainFont3")
	ibCheckbox:SetText(text)
	ibCheckbox:SetTextColor(color_white)
	ibCheckbox:SetValue( readData(CurrentConfig,entry) )
	ibCheckbox:SizeToContents()
	function ibCheckbox.Button:Paint(w, h)
		if readData(CurrentConfig,entry) then
			draw.RoundedBox(0, 2, 2, w-4, h-4, Color(58, 144, 226))
		else
			draw.RoundedBox(0, 1, 1, w-2, h-2, Color(30, 30, 45))
			if self:IsHovered() then
				draw.RoundedBox(0, 1, 1, w-2, h-2, Color(255, 255, 255, 1))
			end
		end
	end	
	function ibCheckbox:OnChange(val)
		entry[#entry+1] = val
		changeData(CurrentConfig,entry)
	end
	
	if type == "col" then

	elseif type == "bind" then

	end
end

local function CreateMenu()
	-- Frame
	local IdiotFrame = vgui.Create("DFrame")
	IdiotFrame:SetSize(771, 859)
	IdiotFrame:Center()
	IdiotFrame:SetTitle("")
	IdiotFrame:ShowCloseButton(false)
	IdiotFrame:SetDraggable(false)
	IdiotFrame:MakePopup()
	IdiotFrame.Paint = function(self, w, h)
		draw.RoundedBox(60, 0, 0, w, h, Color(50, 50, 250, 255))
		draw.RoundedBox(60, 2, 2, w - 4, h - 4, Color(30, 30, 45))
		DrawUpperText(w, h)
	end
	
	--[[ Panals ]]--
	
	local panel1 = vgui.Create("DPanel", IdiotFrame)
	panel1:Dock(FILL)
	panel1.Paint = function()
		CreateSection(0, 15, 60, 235, 250, "Test")
		--CreateSection(0, 265, 60, 235, 250, "text")
		--CreateSection(0, 515, 60, 235, 250, "text")
	end
	panel1:SetVisible(tabselect == "MainMenu")
	local panel2 = vgui.Create("DPanel", IdiotFrame)
	panel2:Dock(FILL)
	panel2.Paint = function() end
	panel2:SetVisible(tabselect == "Aim")
	local panel3 = vgui.Create("DPanel", IdiotFrame)
	panel3:Dock(FILL)
	panel3.Paint = function() end
	panel3:SetVisible(tabselect == "HVH")
	local panel4 = vgui.Create("DPanel", IdiotFrame)
	panel4:Dock(FILL)
	panel4.Paint = function() end
	panel4:SetVisible(tabselect == "Vis")
	local panel5 = vgui.Create("DPanel", IdiotFrame)
	panel5:Dock(FILL)
	panel5.Paint = function() end
	panel5:SetVisible(tabselect == "Misc")
	local panel6 = vgui.Create("DPanel", IdiotFrame)
	panel6:Dock(FILL)
	panel6.Paint = function() end
	panel6:SetVisible(tabselect == "Dick") -- Make this what ever you wnat.
	
	--[[ Tabs / Designs ]]--
	
	local MainTab = vgui.Create("DButton", IdiotFrame)
	MainTab:SetFont("MainFont3")
	MainTab:SetText("Main Menu")
	MainTab:SetTextColor(Color(0, 205, 255))
	MainTab:SetSize(122, 30)
	MainTab:SetPos(5, 40)
	function MainTab:DoClick()
		tabselect = "MainMenu"
		panel1:SetVisible(true)
		panel2:SetVisible(false)
		panel3:SetVisible(false)
		panel4:SetVisible(false)
		panel5:SetVisible(false)
		panel6:SetVisible(false)
	end
	function MainTab:Paint(w, h)
		if tabselect == "MainMenu" then
			draw.RoundedBox(0, 0, h-2, w, h, Color(0, 155, 255))
		end
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 1))
		end
	end

	local AimTab = vgui.Create("DButton", IdiotFrame)
	AimTab:SetFont("MainFont3")
	AimTab:SetText("Aim Assist")
	AimTab:SetTextColor(Color(0, 205, 255))
	AimTab:SetSize(127, 30)
	AimTab:SetPos(132, 40)
	function AimTab:DoClick()
		tabselect = "Aim"
		panel1:SetVisible(false)
		panel2:SetVisible(true)
		panel3:SetVisible(false)
		panel4:SetVisible(false)
		panel5:SetVisible(false)
		panel6:SetVisible(false)
	end
	function AimTab:Paint(w, h)
		if tabselect == "Aim" then
			draw.RoundedBox(0, 0, h-2, w, h, Color(0, 155, 255))
		end
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 1))
		end
	end

	local HvhTab = vgui.Create("DButton", IdiotFrame)
	HvhTab:SetFont("MainFont3")
	HvhTab:SetText("Hack vs. Hack")
	HvhTab:SetTextColor(Color(0, 205, 255))
	HvhTab:SetSize(127, 30)
	HvhTab:SetPos(259, 40)
	function HvhTab:DoClick()
		tabselect = "HVH"
		panel1:SetVisible(false)
		panel2:SetVisible(false)
		panel3:SetVisible(true)
		panel4:SetVisible(false)
		panel5:SetVisible(false)
		panel6:SetVisible(false)
	end
	function HvhTab:Paint(w, h)
		if tabselect == "HVH" then
			draw.RoundedBox(0, 0, h-2, w, h, Color(0, 155, 255))
		end
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 1))
		end
	end

	local VisTab = vgui.Create("DButton", IdiotFrame)
	VisTab:SetFont("MainFont3")
	VisTab:SetText("Visuals")
	VisTab:SetTextColor(Color(0, 205, 255))
	VisTab:SetSize(127, 30)
	VisTab:SetPos(386, 40)
	function VisTab:DoClick()
		tabselect = "Vis"
		panel1:SetVisible(false)
		panel2:SetVisible(false)
		panel3:SetVisible(false)
		panel4:SetVisible(true)
		panel5:SetVisible(false)
		panel6:SetVisible(false)
	end
	function VisTab:Paint(w, h)
		if tabselect == "Vis" then
			draw.RoundedBox(0, 0, h-2, w, h, Color(0, 155, 255))
		end
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 1))
		end
	end

	local MiscTab = vgui.Create("DButton", IdiotFrame)
	MiscTab:SetFont("MainFont3")
	MiscTab:SetText("Miscellaneous")
	MiscTab:SetTextColor(Color(0, 205, 255))
	MiscTab:SetSize(127, 30)
	MiscTab:SetPos(513, 40)
	function MiscTab:DoClick()
		tabselect = "Misc"
		panel1:SetVisible(false)
		panel2:SetVisible(false)
		panel3:SetVisible(false)
		panel4:SetVisible(false)
		panel5:SetVisible(true)
		panel6:SetVisible(false)
	end
	function MiscTab:Paint(w, h)
		if tabselect == "Misc" then
			draw.RoundedBox(0, 0, h-2, w, h, Color(0, 155, 255))
		end
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 1))
		end
	end

	local LastTab = vgui.Create("DButton", IdiotFrame) -- Whatever you want here
	LastTab:SetFont("MainFont3")
	LastTab:SetText("Change This")
	LastTab:SetTextColor(Color(0, 205, 255))
	LastTab:SetSize(127, 30)
	LastTab:SetPos(640, 40)
	function LastTab:DoClick()
		tabselect = "Dick"
		panel1:SetVisible(false)
		panel2:SetVisible(false)
		panel3:SetVisible(false)
		panel4:SetVisible(false)
		panel5:SetVisible(false)
		panel6:SetVisible(true)
	end
	function LastTab:Paint(w, h)
		if tabselect == "Dick" then
			draw.RoundedBox(0, 0, h-2, w, h, Color(0, 155, 255))
		end
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 1))
		end
	end

	CheckBox("Test CheckBox", panel1, 20, 70, {"gfuel","movement","bhop","status"}, "col")

    return IdiotFrame
end

local menutoggle = false
local menu;

local function toggleMenu()
	if not menutoggle then
		menutoggle = true
		menu = CreateMenu()
	else
		menutoggle = false
		if IsValid(menu) then
			menu:Remove()
		end
	end
end

local function keyPressed(a,b)
	if  input.IsKeyDown(KEY_HOME) and not menudebounce then
		toggleMenu()
		menudebounce = true
	elseif not input.IsKeyDown(KEY_HOME) and menudebounce then menudebounce = not menudebounce
	end
end

hook.Add("Think", "keyPressed", keyPressed)
hook.Add("CalcView", "Camera", Camera)
hook.Add("CreateMove", "Movement", Movement)
