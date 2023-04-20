--[[
	Idiotbox v7
	Rewrite by AdolfRoxler -> TG NGGUH
	
	Phizz, the creator
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
		["anti-aim"] = {
			status = true,
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
	local template = DefaultConfig
	for index, path in ipairs(pathArray) do
		if pathArray[index + 2]==nil then
			if typeof(pathArray[index + 1]) == typeof(template[path]) and pathArray[index + 1]~=nil and template[path]~=nil then tabl[path] = pathArray[index + 1] end
		else
			if tabl[path]==nil then
				break
			end
			if typeof(tabl[path]) == typeof(template[path]) and tabl[path]~=nil and template[path]~=nil then
				tabl = tabl[path] 
				template = template[path] else break end
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

local function FakeLag(cmd)
	if cmd:CommandNumber()==0 then return end
	packetcount = packetcount +1
	bsendpacket = queue>=14 and true
	packetcount = packetcont>=14 and 0 or packetcount
end

local function Movement(cmd)
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
local function CreateMenu()
	-- Frame
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(500,400)
	Frame:Center()
	Frame:SetTitle("")
	Frame:ShowCloseButton(false)
	Frame:SetDraggable(false)
	Frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
	end
	-- Tabs inherits frame
	local TabPanel = vgui.Create("DPropertySheet", Frame)
	TabPanel:SetPos(5, 30)
	TabPanel:SetSize(Frame:GetWide() - 10, Frame:GetTall() - 35)
	--Table of tabs
	local Tabs = {
        { Name = "Aimbot", Panel = vgui.Create("DPanel", TabPanel) },
        { Name = "Anti-Aim", Panel = vgui.Create("DPanel", TabPanel) },
        { Name = "Visuals", Panel = vgui.Create("DPanel", TabPanel) },
        { Name = "Misc", Panel = vgui.Create("DPanel", TabPanel) },
        { Name = "Settings", Panel = vgui.Create("DPanel", TabPanel) }
    }
	--Return tabs in frame and the menu
	for k, v in pairs(Tabs) do
        TabPanel:AddSheet(v.Name, v.Panel, nil, false, false)
    end

    return Frame
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
--hook.Add("CreateMove", "Movement", Movement)
