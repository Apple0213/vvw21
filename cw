if Menu and Menu.Unload then
    Menu:Unload()
end

local StatisticsService = game:GetService("Stats")
local PlayerService = game:GetService("Players")
local InputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera
local Nigger = PlayerService.LocalPlayer
local Mouse = Nigger:GetMouse()

local Menu = loadstring(game:HttpGet("https://raw.githubusercontent.com/Apple0213/wgwgwg/main/dd"))()
local Hooks = loadstring(game:HttpGet("https://rbx.nebula.tokyo/peak/MinHook.lua"))()

local PlayerEntities = {}
local ObjectEntities = {}

local Esp
local Modules = {}
local Teammates
local Prediction = setmetatable({}, {
    __newindex = function(Self, Key, Value)
        rawset(Self, tonumber(Key), tonumber(Value))
    end,
    __index = function(Self, Key)
    	return rawget(Self, tonumber(Key)) or 100
    end
})

local PlayerRig = {
    "Head",
    "UpperTorso",
    "LowerTorso",
    "LeftFoot",
    "LeftLowerLeg",
    "LeftUpperLeg",
    "RightFoot",
    "RightLowerLeg",
    "RightUpperLeg",
    "LeftHead",
    "LeftLowerArm",
    "LeftUpperArm",
    "RightHand",
    "RightLowerArm",
    "RightUpperArm",
    "RootPart"
}

local RigFormat = {
    {From = "Head", To = "UpperTorso"},
    {From = "UpperTorso", To = "LowerTorso"},
    {From = "UpperTorso", To = "RightUpperArm"},
    {From = "UpperTorso", To = "LeftUpperArm"},
    {From = "LeftUpperArm", To = "LeftLowerArm"},
    {From = "LeftLowerArm", To = "LeftHand"},
    {From = "RightUpperArm", To = "RightLowerArm"},
    {From = "RightLowerArm", To = "RightHand"},
    {From = "LowerTorso", To = "LeftUpperLeg"},
    {From = "LeftUpperLeg", To = "LeftLowerLeg"},
    {From = "LowerTorso", To = "RightUpperLeg"},
    {From = "LeftLowerLeg", To = "LeftFoot"},
    {From = "RightUpperLeg", To = "RightLowerLeg"},
    {From = "RightLowerLeg", To = "RightFoot"}
}

local Codes, Event, EventC do
    local Globals = getrenv()._G -- I think they will remove _G and or make it ban you, hence the checks (im paranoid ik and cba to get them in gc)
    local Message = "Looks like the game has updated!! Script no worky worky :pensive: :worried: :sake:"

    Modules.Client = rawget(Globals, "Character")
    Modules.Network = rawget(Globals, "Network")
    Modules.Inventory = rawget(Globals, "Inventory")
    Modules.Interface = rawget(Globals, "UI")
    Modules.Player = rawget(Globals, "Player")
    Modules.Entity = rawget(Globals, "Entity")
    Modules.Camera = rawget(Globals, "Camera")

    assert(type(Modules.Client) == "table", Message)
    assert(type(Modules.Network) == "table", Message)
    assert(type(Modules.Inventory) == "table", Message)
    assert(type(Modules.Interface) == "table", Message)
    assert(type(Modules.Player) == "table", Message)
    assert(type(Modules.Entity) == "table", Message)
    assert(type(Modules.Camera) == "table", Message)

    PlayerEntities = getupvalue(Modules.Player.GetModelFromPart, 1)
    ObjectEntities = getupvalue(Modules.Entity.GetEntityFromPart, 1)

    assert(type(PlayerEntities) == "table", Message)
    assert(type(ObjectEntities) == "table", Message)

    Codes = getupvalue(Modules.Network.Send, 1)
    Event = getupvalue(Modules.Network.Send, 2)

    assert(type(Codes) == "table", Message)
    assert(type(Event) == "userdata", Message)

    Teammates = getupvalue(Modules.Player.SetClanMembers, 1) or {}

    for _, Connection in next, getconnections(Event.OnClientEvent) do
        if tostring(getfenv(Connection.Function).script) == "Client" then
            EventC = Connection

            break
        end
    end

    assert(EventC, Message)

    for _, Upvalue in next, getupvalues(EventC.Function) do
        if type(Upvalue) == "table" then
            if type(rawget(Upvalue, "_msec")) == "function" then
                local _Serialize; _Serialize = Hooks:Add(Upvalue, "Index", "serialize", function(Table)
                    if type(rawget(Table, "violations")) == "table" then -- Anti ban p100
                        rawset(Table, "noReport", true)
                        rawset(Table, "violations", {})
                    end
            
                    return _Serialize(Table)
                end)

                break
            end
        end
    end

    -- assert(Serialize, Message)

    --[[local u12
    local Upvalues = getupvalue(EventC.Function, 9)
    local Indexes = getupvalue(getmetatable(Upvalues).__index, 1)

    for Index, Upvalue in next, Indexes[1][1] do
        if type(Upvalue) == "function" then
            local Wish = getupvalues(Upvalue)

            if type(Wish[7]) == "table" and Wish[7]._msec then -- See if its a MoonSec interpreter
                for _, Instruction in next, Wish[2] do
                    local ArgK = #Instruction == 4 and Instruction[4] or Instruction[3] -- The constant operand
                    
                    if type(ArgK) == "string" then
                        if ArgK == "split" then
                            u12 = Indexes[1][1][Index + 1]

                            break
                        end
                    end
                end
            end
        end
    end

    assert(type(u12) == "table")]]
end

local MapSize = 6500 / 2
local ChunkSize = 812.5 -- 562.5 -- So random
local Traveling = false -- To block our move packets

local function GetLatency()
    return StatisticsService.PerformanceStats.Ping:GetValue() / 1000
end

local function WorldToMap(Position)
    return Vector2.new(Position.X + MapSize, Position.Z + MapSize) 
end

local function MapToWorld(Position)
    return Vector3.new(Position.X - MapSize, 0, Position.Y - MapSize)
end

local function ChunkToWorld(Chunk)
    local Column, Row = Chunk:match("^([a-hA-H])([1-8])$")

    if Column and Row then
        Column, Row = string.byte(Column:lower()) - 97, Row - 1
        
        return Vector3.new(-MapSize + Row * ChunkSize, 0, -MapSize + Column * ChunkSize)
    end
end

-- Qtip wanted some rainbow shit
local Rainbow = Color3.new() do
    local Delta = 5

    Menu:Connect(RunService.RenderStepped, function()
        Rainbow = Color3.fromHSV(tick() % Delta / Delta, 1, 1)
    end)
end

-- if not is_synapse_function(Serialize) then -- Not already hooked
    --[[local _Serialize; _Serialize = Hooks:Add(Serialize, "Closure", function(Table, ...)
        if type(rawget(Table, "violations")) == "table" then -- Anti ban p100
            print("spoofed report", tts(Table))

            rawset(Table, "noReport", true)
            rawset(Table, "violations", {})
        end

        return _Serialize(Table, ...)
    end)]]
-- end

local function math_sec(x)
    return 1 / math.cos(x) 
end

local Send; Send = Hooks:Add(Modules.Network.Send, "Closure", function(Code, ...)
    local Args = {...}

    --[[if Code ~= "Move" then
        print(Code, tts(Args))
    end]]

    if Code == "Move" then
        if Traveling then return end

        if Menu.Flags.invisibility and Menu.Flags.invisibility_bind then
            Args[3] = 0/0
        end

        if Menu.Flags.test_thing then
            Args[1] = Vector3.new(Args[1].X, Args[1].Y, 0/0)
        end

        if Menu.Flags.on_ground then
            local Old = Args[1];
            local Origin = Modules.Client.character.PrimaryPart.Position
            
            local part, position = workspace:FindPartOnRayWithWhitelist(Ray.new(Origin, Vector3.new(0, -5000, 0)), {workspace.Terrain});

            if part then
                -- print(Old.Y, position.Y + 3)

                Args[1] = Vector3.new(Old.X, position.Y + 3, Old.Z);
            end;
        end;
    elseif Code == "UseItem" and Args[1] == "Hit" then
        -- Args change depending on weapon so traverse backwards and prey

        if Menu.Flags.spoof_magnitude then
            Args[type(Args[5]) == "string" and 6 or 5] = Vector3.new(0/0, 0/0, 0/0)
        end
        
        if Menu.Flags.spoof_magnitude then
            for Index = #Args, 1, -1 do
                if type(Args[Index]) == "vector" then
                    Args[Index] = Vector3.new(0/0, 0/0, 0/0)

                    break
                end
            end
        end
    --[[elseif Code == "Crouch" or Code == "Slide" then
        Code = "Crouch"
        Args = {true}]]
    elseif Code == "Slide" and Menu.Flags.test_thing then
        return 
    end

    return Send(Code, unpack(Args))
end)

local Teleport; Teleport = Hooks:Add(Modules.Client.Teleport, "Closure", function(Position) -- v3
    if Menu.Flags.test_shit and not checkcaller() then
        local Origin = Modules.Client.character.PrimaryPart.Position

        Send("Move", Vector3.new(Origin.X, 0/0, Origin.Z), 0, 0/0, nil, -1, -1)

        print("spoofed server teleport", Position)

        return
    end

    return Teleport(Position)
end)

local function FastTravel(Origin, Destination)
    if Traveling then 
        return Menu:Notify("too qucik nigger", 2, Color3.new(1, 0, 0))
    end

    if workspace:FindPartOnRayWithIgnoreList(Ray.new(Origin, Vector3.new(0, 5000, 0)), {workspace.Ignore, workspace.MAP_TOP}) then
        return Menu:Notify("theres something above you dick head?", 2, Color3.new(1, 0, 0))
    end

    Traveling = true

    local Hit, Below = workspace:FindPartOnRayWithIgnoreList(Ray.new(Vector3.new(Destination.X, 5000, Destination.Z), Vector3.new(0, -5000, 0)), {workspace.Ignore})

    Below = Hit and Below.Y + 5 or 1000

    Teleport(Vector3.new(Destination.X, Below, Destination.Z))
    Send("Move", Vector3.new(0/0, 0/0, 0/0), 0, 0/0, nil, -1, -1)
    Send("Move", Vector3.new(Origin.X, 2000, Origin.Z), 0, 0/0, nil, -1, -1)
    Send("Move", Vector3.new(0/0, 0/0, 0/0), 0, 0/0, nil, -1, -1)
    Send("Move", Vector3.new(Destination.X, 2000, Destination.Z), 0, 0/0, nil, -1, -1)
    Send("Move", Vector3.new(0/0, 0/0, 0/0), 0, 0/0, nil, -1, -1)
    Send("Move", Vector3.new(Destination.X, Below, Destination.Z), 0, 0, nil, -1, -1)
    task.wait(GetLatency() * 6)
    
    Traveling = false

    return true
end

--[[local Update; Update = Hooks:Add(UpdateCP, "Closure", function(Delta)
    if Traveling then
        return
    end

    return Update(Delta)
end)]]

-- Syn needs to fix hookfunction for OnClientEvent
--[[local Recive; Recive = Hooks:Add(EventCB, "Closure", function(Event, ...)
    
end)]]

Menu:Connect(Event.OnClientEvent, function(Code, ...)
    local Args = {...}

    if Code == "Message.CreateLog" then
        local UserId, Damage = Args[1]:match("YOU hit .+%(([%d]+)%) from [%d]+s with [%a]+ for ([%d]+) damage")

        if UserId and Damage then
            -- This is kinda the only way to do it because this also accounts for criticals + rejected
            -- Could also take it away based on client damage then adjust using this

            Prediction[UserId] -= Damage 

            if Prediction[UserId] < 0 then
                Menu:Notify("prediction error", 2, Color3.new(1, 1, 0))
            end
        end

        Menu:Notify(Args[1], 2, Args[2] and Color3.new(1, 0, 0) or Color3.new(1, 1, 1))
    end
end)

-- Xd
local GetModelFromPart; GetModelFromPart = Hooks:Add(Modules.Player.GetModelFromPart, "Closure", function(Part, ...)
    for Id, Hitboxes in next, Esp.Hitboxes do
        for _, Hitbox in next, Hitboxes do
            if Hitbox == Part then
                local Entity = PlayerEntities[Id]

                if Entity then
                    return Entity.model, Entity.id
                end
            end
        end
    end

    return GetModelFromPart(Part, ...)
end)



local LoadNewPlayer; LoadNewPlayer = Hooks:Add(Modules.Player.LoadNewPlayer, "Closure", function(UserId, ...)
    Esp.Hitboxes[UserId] = {} -- Quick fix

    Prediction[UserId] = 100 -- Assume 100 (max health)

    return LoadNewPlayer(UserId, ...)
end)

local SetClanMembers; SetClanMembers = Hooks:Add(Modules.Player.SetClanMembers, "Closure", function(Members, ...)
    Teammates = Members or {} -- Not perfect?

    return SetClanMembers(Members, ...)
end)

local Recoil; Recoil = Hooks:Add(Modules.Camera.Recoil, "Closure", function(...)
    if Menu.Flags.no_recoil then
        return
    end

    return Recoil(...)
end)

local blockSprint; blockSprint = Hooks:Add(Modules.Client.blockSprint, "Closure", function(...)
    local Args = {...}

    if Menu.Flags.no_slow then
        Args[1] = false
    end

    return blockSprint(unpack(Args))
end)

local Jump; Jump = Hooks:Add(Modules.Client.Jump, "Closure", function(...)
    if --[[Menu.Flags.infinite_jump or]] Menu.Flags.air_slide then
        Send("Move", Vector3.new(0/0, 0/0, 0/0), 0, 0, nil, -1, -1)
    end

    return Jump(...)
end)

local Level = Regex and 2 or 3

local isGrounded; isGrounded = Hooks:Add(Modules.Client.isGrounded, "Closure", function(...)
    if --[[(Menu.Flags.infinite_jump and getinfo(Level).name == "Jump") or]] (Menu.Flags.air_slide and getinfo(Level).name == "updateCharacter") then
        return true
    end

    if Menu.Flags.air_shots and tostring(getfenv(3).script.Parent) == "ClientControllers" then
        return true
    end

    return isGrounded(...)
end)

local Random; Random = Hooks:Add(getrenv().math.random, "Closure", function(...)
    if Menu.Flags.always_snore and getinfo(Level).name == "Sleep" then
        return 1 -- Cant test atm should work?
    end

    return Random(...)
end)

local MoveFilter
local Move; Move = Hooks:Add(Modules.Player.Move, "Closure", function(...)
    local Args = {...}

    if Menu.Flags.bring_players and Menu.Flags.bring_players_bind and (not MoveFilter or (MoveFilter and MoveFilter[Args[1]])) then
        Args[2] = Modules.Client.character.PrimaryPart.Position + (Camera.CFrame.LookVector * 5)
    elseif Menu.Flags.freeze_players and Menu.Flags.freeze_players_bind then
        return
    end

    if Menu.Flags.resolver then
        if Args[3] ~= Args[3] then -- nan
            Args[3] = 0
        end
    
        if Args[4] ~= Args[4] then -- nan
            Args[4] = 0
        end
    end

    if Menu.Flags.disable_interpolation then
        local Entity = PlayerEntities[Args[1]]

        if Entity then
            Entity.lastPos = Entity.pos
            Entity.pos = Args[2]
            Entity.angleX = Args[3]
            Entity.angleY = Args[4]
            -- Entity.goalindex = 1
            -- Entity.goals = {Entity.pos}

            if Entity.model then
                Entity.model:SetPrimaryPartCFrame(CFrame.new(Entity.pos) * CFrame.fromOrientation(0, Entity.angleY, 0), math.clamp(1 / ((Entity.pos - Entity.lastPos).Magnitude * 5), 0.17, 0.5))
            end

            return
        end
    end

    return Move(unpack(Args))
end)

do
    local EquipUp
    local EquipDown

    EquipUp = Hooks:Add(Modules.Inventory.EquipUp, "Closure", function(...)
        if Menu.Flags.invert_hotbar_scroll then
            return EquipDown(...)
        end

        return EquipUp(...)
    end)

    EquipDown = Hooks:Add(Modules.Inventory.EquipDown, "Closure", function(...)
        if Menu.Flags.invert_hotbar_scroll then
            return EquipUp(...)
        end

        return EquipDown(...)
    end)
end

-- syn release v3 pls no more 300+ line esp
Esp = {Players = {}, Objects = {}} do
    function Esp:Draw(Class, Properties)
        local Object = Drawing.new(Class)

        for Property, Value in next, Properties do
            Object[Property] = Value
        end

        return Object
    end
    
    function Esp:WorldToScreen(Position)
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)

        return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen, ScreenPos.Z
    end

    local PlayerRender = {}; PlayerRender.__index = PlayerRender do
        function PlayerRender.new(Id)
            local self = {}

            self.Id = Id
            self.Entity = PlayerEntities[Id]
            self.Drawings = {
                Box = Esp:Draw("Square", {
                    Visible = false,
                    ZIndex = 2,
                    Transparency = 1,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 1,
                    Size = Vector2.new(),
                    Position = Vector2.new(),
                    Filled = false
                }),
                Name = Esp:Draw("Text", {
                    Visible = false,
                    ZIndex = 2,
                    Transparency = 1,
                    Color = Color3.fromRGB(255, 255, 255),
                    Text =  self.Entity and self.Entity.name or "???",
                    Size = 13,
                    Center = true,
                    Outline = false,
                    OutlineColor = Color3.fromRGB(0, 0, 0),
                    Position = Vector2.new(),
                    Font = 2
                }),
                Health = Esp:Draw("Line", {
                    Visible = false,
                    ZIndex = 2,
                    Transparency = 1,
                    Color = Color3.fromRGB(0, 255, 0),
                    Thickness = 1,
                    From = Vector2.new(),
                    To = Vector2.new()
                }),
                Distance = Esp:Draw("Text", {
                    Visible = false,
                    ZIndex = 2,
                    Transparency = 1,
                    Color = Color3.fromRGB(255, 255, 255),
                    Text = "0m",
                    Size = 13,
                    Center = true,
                    Outline = false,
                    OutlineColor = Color3.fromRGB(0, 0, 0),
                    Position = Vector2.new(),
                    Font = 2
                }),
                Weapon = Esp:Draw("Text", {
                    Visible = false,
                    ZIndex = 2,
                    Transparency = 1,
                    Color = Color3.fromRGB(255, 255, 255),
                    Text = "0m",
                    Size = 13,
                    Center = true,
                    Outline = false,
                    OutlineColor = Color3.fromRGB(0, 0, 0),
                    Position = Vector2.new(),
                    Font = 2
                })
            }

            self.Skeleton = {}

            for _ = 1, #RigFormat do
                table.insert(self.Skeleton, Esp:Draw("Line", {
                    Visible = false,
                    ZIndex = 2,
                    Transparency = 1,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 1,
                    From = Vector2.new(),
                    To = Vector2.new()
                }))
            end

            -- Roblox are stupid
            self.Cham = Menu:Create("Highlight", {
                Name = tostring(self.UserId),
                Enabled = false,
                FillColor = Color3.fromRGB(),
                FillTransparency = 1,
                OutlineColor = Color3.fromRGB(),
                OutlineTransparency = 1,
                Parent = Esp.Chams
            })

            --[[self.Hitboxes = Menu:Create("Folder", {
                Name = self.Id,
                Parent = Esp.Hitboxes
            })]]

            Esp.Hitboxes[self.Id] = {}
            
            return setmetatable(self, PlayerRender)
        end

        function PlayerRender:Update()
            local Entity = PlayerEntities[self.Id]
            local Model = Entity and Entity.model
            local Root = Model and Model:FindFirstChild("HumanoidRootPart")

            if Root then
                local Team = Entity.anims.Sleep.IsPlaying and "sleeping" or table.find(Teammates, self.Id) and "friendly" or "enemy"

                if Menu.Flags[Team .. "_esp"] then
                    local ScreenPos, OnScreen, Depth = Esp:WorldToScreen(Root.Position)

                    if OnScreen then
                        local Scale = (Esp:WorldToScreen(Root.Position - Vector3.new(0, 3, 0)).Y - Esp:WorldToScreen(Root.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                        local Size = Vector2.new(math.round(Scale * 1.5), math.round(Scale * 1.9))
                        local Position = Vector2.new(math.round(ScreenPos.X - Scale * 1.5 / 2), math.round(ScreenPos.Y - Scale * 1.6 / 2))

                        if Menu.Flags[Team .. "_boxes"] then
                            local Drawing = self.Drawings.Box

                            Drawing.Visible = true
                            Drawing.Color = Menu.Flags[Team .. "_box_color"]
                            Drawing.Size = Size
                            Drawing.Position = Position
                        else
                            self.Drawings.Box.Visible = false
                        end

                        if Menu.Flags[Team .. "_names"] then
                            local Drawing = self.Drawings.Name

                            Drawing.Visible = true
                            Drawing.Color = Menu.Flags[Team .. "_name_color"]
                            Drawing.Position = Vector2.new(Position.X + Size.X / 2, Position.Y - 15)
                        else
                            self.Drawings.Name.Visible = false
                        end

                        if Menu.Flags[Team .. "_health"] then
                            local Drawing = self.Drawings.Health
                            local Health = Prediction[self.UserId]

                            Drawing.Visible = true
                            Drawing.From = Vector2.new(Position.X - 2, Position.Y + Size.Y)
                            Drawing.To = Vector2.new(Drawing.From.X, Drawing.From.Y - (Health / 100) * Size.Y)
                        else
                            self.Drawings.Health.Visible = false
                        end

                        if Menu.Flags[Team .. "_weapon"] then
                            local Drawing = self.Drawings.Weapon

                            Drawing.Visible = true
                            Drawing.Color = Menu.Flags[Team .. "_weapon_color"]
                            Drawing.Text = Entity.equippedItem and Entity.equippedItem.id or "NONE"
                            Drawing.Position = Vector2.new(Position.X + Size.X / 2, Position.Y + Size.Y + 3)
                        else
                            self.Drawings.Weapon.Visible = false
                        end

                        if Menu.Flags[Team .. "_distance"] then
                            local Drawing = self.Drawings.Distance

                            Drawing.Visible = true
                            Drawing.Color = Menu.Flags[Team .. "_distance_color"]
                            Drawing.Text = tostring(Menu:Round(Depth / 5, 1)) .. "m" -- Distance from camera not player lmao
                            Drawing.Position = Vector2.new(Position.X + Size.X / 2, Position.Y + Size.Y + (Menu.Flags[Team .. "_weapon"] and 16 or 3))
                        else
                            self.Drawings.Distance.Visible = false
                        end

                        if Menu.Flags[Team .. "_chams"] then
                            local Cham = self.Cham

                            Cham.Enabled = true
                            Cham.Adornee = Model

                            Cham.FillColor = Menu.Flags[Team .. "_cfil_color"]
                            Cham.FillTransparency = Menu.Flags[Team .. "_cfil_alpha"]
                            
                            Cham.OutlineColor = Menu.Flags[Team .. "_cout_color"]
                            Cham.OutlineTransparency = Menu.Flags[Team .. "_cout_alpha"]
                        else
                            self.Cham.Enabled = false
                        end

                        if Menu.Flags[Team .. "_skeleton"] then
                            local Skeleton = self.Skeleton

                            for Index, Joint in next, RigFormat do
                                local From = Model:FindFirstChild(Joint.From)
                                local To = Model:FindFirstChild(Joint.To)

                                if From and To then
                                    Skeleton[Index].Visible = true
                                    Skeleton[Index].Color = Menu.Flags[Team .. "_skeleton_color"]
                                    Skeleton[Index].From = Esp:WorldToScreen(From.Position)
                                    Skeleton[Index].To = Esp:WorldToScreen(To.Position)
                                end
                            end
                        else
                            for Index = 1, #RigFormat do 
                                self.Skeleton[Index].Visible = false 
                            end
                        end
                    else
                        self:Hide()
                    end
                else
                    self:Hide()
                end

                if Menu.Flags.hitbox_extender then
                    local Hitboxes = Esp.Hitboxes[self.Id]

                    for _, Name in next, PlayerRig do
                        local Part = Model:FindFirstChild(Name)

                        if not Menu.Flags.extender_hitboxes[Name] then
                            continue
                        end

                        if not Hitboxes[Name] and Part then
                            Hitbox = Part:Clone()
                            Hitbox.Anchored = true
                            Hitbox.CanCollide = false

                            for _, Child in next, Hitbox:GetChildren() do
                                if Child:IsA("SpecialMesh") then
                                    Child.TextureId = ""
                                else
                                    Child:Destroy()
                                end
                            end
                        end

                        if Part then
                            if not Hitboxes[Name] then
                                local Hitbox = Part:Clone()
                                Hitbox.Anchored = true
                                Hitbox.CanCollide = false
    
                                for _, Child in next, Hitbox:GetChildren() do
                                    if Child:IsA("SpecialMesh") then
                                        Child.TextureId = ""
                                    else
                                        Child:Destroy()
                                    end
                                end

                                Hitboxes[Name] = Hitbox
                            end

                            local Hitbox = Hitboxes[Name]

                            Hitbox.Size = Part.Size * Menu.Flags.extender_amount * (tostring(Part) == "Head" and 0.95 or 0.7)
                            -- Hitbox.Position = Part.Position
                            Hitbox.Transparency = Menu.Flags.extender_visual and Menu.Flags.extender_alpha or 1
                            Hitbox.Color = Menu.Flags.extender_rainbow and Rainbow or Menu.Flags.extender_color
                            Hitbox.Parent = Part
                        end
                    end


                else
                    --[[for _, Hitbox in next, self.Hitboxes:GetChildren() do
                        Hitbox.Parent = nil
                    end]]
                end
            else
                self:Hide()

                --[[for _, Hitbox in next, self.Hitboxes:GetChildren() do
                    Hitbox.Parent = nil
                end]]
            end
        end

        function PlayerRender:Remove()
            Esp.Players[self.Id] = nil

            for _, Drawing in next, self.Drawings do
                Drawing:Remove()
            end

            self.Cham:Destroy()

            for Index = 1, #RigFormat do 
                self.Skeleton[Index]:Remove()
            end
        end

        function PlayerRender:Hide()
            for _, Drawing in next, self.Drawings do
                Drawing.Visible = false
            end

            self.Cham.Enabled = false

            for Index = 1, #RigFormat do 
                self.Skeleton[Index].Visible = false 
            end
        end
    end

    Esp.Chams = Menu:Create("Folder", {
        Parent = game.Lighting
    })

    --[[Esp.Hitboxes = Menu:Create("Folder", {
        Parent = workspace
    })]]

    Esp.Hitboxes = {}

    Esp.Update = Menu:Connect(RunService.RenderStepped, function()
        --[[for _, Player in next, PlayerService:GetPlayers() do
            if Player ~= Nigger then
                if not Esp.Players[Player] then
                    Esp.Players[Player] = PlayerRender.new(Player)
                end

                task.spawn(Esp.Players[Player].Update, Esp.Players[Player])
            end
        end]]

        for Id, Entity in next, PlayerEntities do
            if not Esp.Players[Id] then
                Esp.Players[Id] = PlayerRender.new(Id)
            end
        end

        for Id, PlayerRender in next, Esp.Players do
            task.spawn(PlayerRender.Update, PlayerRender)
        end
    end)

    Menu:Connect(PlayerService.PlayerRemoving, function(Player)
        if Esp.Players[Player.UserId] then
            Esp.Players[Player.UserId]:Remove()
        end
    end)
end

local Crosshair = {Angle = 0, Lines = {}} do -- pasted from v3rm
    function Crosshair:Update()
        local Position = Camera.ViewportSize / 2

        if Menu.Flags.crosshair then
            local Radius = Menu.Flags.crosshair_radius
            local Length = Menu.Flags.crosshair_length
            local Angle = Menu.Flags.crosshair_spin and self.Angle or 0
            
            self.Angle += 1 / Menu.Flags.crosshair_speed

            for Index, Line in next, self.Lines do
                local Offset = Index * math.pi / 2 -- Full circle?

                local FromX = math.cos(Angle + Offset) * (Radius + ((Radius * math.sin(Angle)) / 9))
                local FromY = math.sin(Angle + Offset) * (Radius + ((Radius * math.sin(Angle)) / 9))

                local ToX = math.cos(Angle + Offset) * ((Radius + Length) + ((Radius * math.sin(Angle)) / 9))
                local ToY = math.sin(Angle + Offset) * ((Radius + Length) + ((Radius * math.sin(Angle)) / 9))

                Line.Visible = true
                Line.Transparency = 1
                Line.ZIndex = 3
                Line.Color = Menu.Flags.crosshair_rainbow and Rainbow or Menu.Flags.crosshair_color
                Line.Thickness = Menu.Flags.crosshair_width
                Line.From = Position + Vector2.new(FromX, FromY)
                Line.To = Position + Vector2.new(ToX, ToY)
            end
        else
            for _, Line in next, self.Lines do
                Line.Visible = false
            end
        end

        if Menu.Flags.crosshair_dot then
            self.Dot.Position = Position
            self.Dot.Color = Menu.Flags.crosshair_rainbow and Rainbow or Menu.Flags.crosshair_dot_color
            self.Dot.ZIndex = 3
            self.Dot.Visible = true
            self.Dot.Radius = Menu.Flags.dot_radius
            self.Dot.Transparency = 1
        else
            self.Dot.Visible = false
        end
    end

    function Crosshair:Remove()
        for _, Line in next, self.Lines do
            Line:Remove()
        end

        self.Dot:Remove()
    end

    for Index = 1, 4 do
        Crosshair.Lines[Index] = Esp:Draw("Line", {

        })
    end

    Crosshair.Dot = Esp:Draw("Circle", {
        NumSides = 25,
        Filled = true
    })

    Menu:Connect(RunService.RenderStepped, function()
        Crosshair:Update()
    end)
end

local Unload; Unload = Hooks:Add(Menu, "Index", "Unload", function(...)
    Esp.Update:Disconnect()
    Esp.Chams:Destroy()
    -- Esp.Hitboxes:Destroy()

    --[[for _, Axis in next, Crosshair do
        Axis:Remove()
    end]]

    Crosshair:Remove()

    for _, PlayerRender in next, Esp.Players do
        PlayerRender:Remove()
    end

    for _, ObjectRender in next, Esp.Objects do
        ObjectRender:Remove()
    end

    for Id, Hitboxes in next, Esp.Hitboxes do
        for Name, Hitbox in next, Hitboxes do
            Hitbox:Destroy()
        end
    end

    Hooks:Reset()

    return Unload(...)
end)

local LegitTab = Menu:Tab("legit") do
    local LegitHE = LegitTab:Section("hitbox extender", 1)
    local LegitM = LegitTab:Section("weapon mods", 1)
    
    LegitHE:Toggle({
        Text = "enabled",
        Flag = "hitbox_extender",
        Callback = function(State)
            if not State then
                for Id, Hitboxes in next, Esp.Hitboxes do
                    for _, Hitbox in next, Hitboxes do
                        Hitbox.Parent = nil
                    end
                end
            end
        end
    })

    LegitHE:Slider({
        Text = "amount",
        Flag = "extender_amount",
        Max = 38,
        Value = 4,
        Float = 0.1
    })

    LegitHE:Dropdown({
        Text =" hotboxes",
        Flag = "extender_hitboxes",
        Combo = true,
        Values = PlayerRig,
        Value = {Head = true},
        Callback = function()
            for Id, Hitboxes in next, Esp.Hitboxes do
                for Name, Hitbox in next, Hitboxes do
                    Hitbox:Destroy()
                    Hitboxes[Name] = nil
                end
            end
        end
    })

    LegitHE:Toggle({
        Text = "visualize",
        Flag = "extender_visual",
        State = true
    }):Color({
        Flag = "extender_color",
        AlphaFlag = "extender_alpha",
        Alpha = 0.5
    })

    LegitHE:Toggle({
        Text = "rainbow",
        Flag = "extender_rainbow",
        State = true
    })

    LegitM:Toggle({
        Text = "air shots",
        Flag = "air_shots",
        State = false
    })

    LegitM:Toggle({
        Text = "no recoil",
        Flag = "no_recoil",
        State = true
    })

    LegitM:Toggle({
        Text = "no slow",
        Flag = "no_slow",
        State = false
    })
end

local VisualsTab = Menu:Tab("visuals") do
    local VisualsE = VisualsTab:Group("esp", 1)
    local VisualsW = VisualsTab:Group("world", 2)
    local VisualsC = VisualsTab:Section("crosshair", 2)

    local WorldN = VisualsW:Section("nodes")
    local WorldD = VisualsW:Section("dropped")
    local WorldC = VisualsW:Section("containers")

    for _, Team in next, {"enemy", "friendly", "sleeping"} do
        local Section = VisualsE:Section(Team)
    
        Section:Toggle({
            Text = "enabled",
            Flag = Team .. "_esp",
            State = Team ~= "sleeping"
        })
    
        Section:Toggle({
            Text = "box",
            Flag = Team .. "_boxes"
        }):Color({
            Color = Team == "enemy" and Color3.new(1, 0, 0) or Team == "friendly" and Color3.new(0, 1, 0) or Color3.new(0, 0, 1),
            Flag = Team .. "_box_color"
        })
    
        Section:Toggle({
            Text = "name",
            Flag = Team .. "_names",
            State = Team ~= "sleeping"
        }):Color({
            Flag = Team .. "_name_color"
        })

        local Health = Section:Toggle({
            Text = "health (predicted)",
            Flag = Team .. "_health",
            State = Team ~= "sleeping"
        }) do
            Health:Color({
                Color = Color3.fromRGB(255, 0, 0)
            })
    
            Health:Color({
                Color = Color3.fromRGB(0, 255, 0)
            })
        end
    
        Section:Toggle({
            Text = "weapon",
            Flag = Team .. "_weapon",
            State = Team ~= "sleeping"
        }):Color({
            Flag = Team .. "_weapon_color"
        })      

        Section:Toggle({
            Text = "distance",
            Flag = Team .. "_distance",
            State = Team ~= "sleeping"
        }):Color({
            Flag = Team .. "_distance_color"
        })

        --[[Section:Dropdown({
            Text = "flags",
            Flag = Team .. "_flags",
            Values = Team ~= "sleeping" and {"invisible", "armor"} or {"armor"},   -- {"invisible", "sleeping", "armor"},
            Value = Team ~= "sleeping" and {invisible = true, armor = true} or {armor = true},
            Combo = true
        })]]
    
        local Chams = Section:Toggle({
            Text = "chams",
            Flag = Team .. "_chams",
            State = Team ~= "sleeping"
        }) do
            Chams:Color({
                Color = Team == "enemy" and Color3.new(1, 0, 0) or Team == "friendly" and Color3.new(0, 1, 0) or Color3.new(0, 0, 1),
                Alpha = 0.5,
                AlphaFlag = Team .. "_cfil_alpha",
                Flag = Team .. "_cfil_color"
            })
    
            Chams:Color({
                Color = Team == "enemy" and Color3.new(1, 0, 0) or Team == "friendly" and Color3.new(0, 1, 0) or Color3.new(0, 0, 1),
                Alpha = 0.75,
                AlphaFlag = Team .. "_cout_alpha",
                Flag = Team .. "_cout_color"
            })
        end
    
        Section:Toggle({
            Text = "skeleton",
            Flag = Team .. "_skeleton"
        }):Color({
            Color = Team == "enemy" and Color3.new(1, 0, 0) or Team == "friendly" and Color3.new(0, 1, 0) or Color3.new(0, 0, 1),
            Flag = Team .. "_skeleton_color"
        })
    end

    VisualsC:Toggle({
        Text = "crosshair",
        Flag = "crosshair",
        State = true
    }):Color({
        Flag = "crosshair_color",
        Color = Color3.new(1, 0, 1)
    })

    VisualsC:Toggle({
        Text = "rainbow",
        Flag = "crosshair_rainbow",
        State = true
    })

    VisualsC:Toggle({
        Text = "spin",
        Flag = "crosshair_spin",
        State = true
    })

    VisualsC:Slider({
        Text = "speed",
        Flag = "crosshair_speed",
        Min = -360,
        Max = 360,
        Value = 65
    })

    VisualsC:Slider({
        Text = "radius",
        Flag = "crosshair_radius",
        Min = 0,
        Value = 0, -- 15
    })

    VisualsC:Slider({
        Text = "length",
        Flag = "crosshair_length",
        Min = 1,
        Value = 25
    })

    VisualsC:Slider({
        Text = "width",
        Flag = "crosshair_width",
        Min = 1,
        Max = 80,
        Value = 2
    })

    VisualsC:Toggle({
        Text = "dot",
        Flag = "crosshair_dot",
        State = false
    }):Color({
        Flag = "crosshair_dot_color",
        Color = Color3.new(1, 0, 1)
    })

    VisualsC:Slider({
        Text = "dot radius",
        Flag = "dot_radius",
        Min = 1,
        Max = 30,
        Value = 2
    })
end

local MiscTab = Menu:Tab("misc") do
    local MiscM = MiscTab:Section("movement", 1)
    -- local MiscC = MiscTab:Section("combat", 1)
    local MiscI = MiscTab:Section("interface", 1)
    local MiscE = MiscTab:Section("exploits", 2)
    local MiscO = MiscTab:Section("other", 2)

    --[[MiscM:Toggle({
        Text = "infinite jump",
        Flag = "infinite_jump"
    })]]

    --[[MiscM:Toggle({
        Text = "double jump",
        Flag = "double_jump"
    })]]

    Menu:Connect(RunService.RenderStepped, function(Delta)
        if not Menu.Flags.speed then return end
    
        local Right = Modules.Camera:GetCFrame().RightVector
        local Forward = Modules.Camera:GetCFrame().LookVector
        local Direction = Vector3.new()
        
        if InputService:IsKeyDown(Enum.KeyCode.W) then
            Direction += Forward
        end
    
        if InputService:IsKeyDown(Enum.KeyCode.A) then
            Direction -= Right
        end
    
        if InputService:IsKeyDown(Enum.KeyCode.S) then
            Direction -= Forward
        end
    
        if InputService:IsKeyDown(Enum.KeyCode.D) then
            Direction += Right
        end
    
        Direction = Direction.Unit
    
        if Direction.X == Direction.X then
            -- Send("Slide", true, Vector3.new(0/0, 0, 0/0));
            
            local Y = Modules.Client.character.PrimaryPart.Velocity.Y;
            Modules.Client.character.PrimaryPart.Velocity = Vector3.new(
                Direction.X * Menu.Flags.speed_factor, 
                Y, 
                Direction.Z * Menu.Flags.speed_factor
            )
        end
    end)


    --[[MiscM:Toggle({
        Text = "speed",
        Flag = "speed",
        Callback = function(State)
            if State then
                local v41 = Modules.Camera.GetY() + 3.1415;
                
                
                Send("Slide", true, Vector3.new(math.sin(v41), 0, math.cos(v41)));
            end
        end
    })

    MiscM:Slider({
        Text = "speed factor",
        Flag = "speed_factor",
        Value = 25,
        Max = 300
    })]]

    --[[MiscM:Bind({
        Text = "speed boost",
        Callback = function()
            local v41 = Modules.Camera.GetY() + 3.1415;
            local l__PrimaryPart__42 = Modules.Client.character.PrimaryPart;
			-- l__PrimaryPart__42.Velocity = l__PrimaryPart__42.Velocity + Vector3.new(0, 300, 0) -- Vector3.new(math.sin(v41), 0, math.cos(v41)) * 120;
			
            -- Send("Move", Vector3.new(0/0, 0/0, 0/0), 0, 0, nil, -1, -1)
            Send("Slide", true, Vector3.new(math.sin(v41), 0, math.cos(v41)));

            local CUM = l__PrimaryPart__42.Velocity;

            local BLA = 50

            l__PrimaryPart__42.Velocity = Vector3.new(math.clamp(CUM.X + BLA, 0, BLA), math.clamp(CUM.Y, 0, BLA), math.clamp(CUM.Z, 0, BLA))

            RunService.Heartbeat:Wait();

            Send("Slide", false)

        end
    })]]

    MiscM:Toggle({
        Text = "air slide",
        Flag = "air_slide"
    })
    

    MiscM:Bind({
        Text = "click teleport",
        Callback = function()
            if Traveling then 
                return Menu:Notify("too qucik nigger", 2, Color3.new(1, 0, 0))
            end
            
            -- local Root = Modules.Client.character.PrimaryPart
            local Origin = Modules.Client.character.PrimaryPart.Position
            local Destination = Mouse.Hit.p + Vector3.new(0, 5, 0)
            local Distance = (Origin - Destination).Magnitude

            -- Idk for qtips sake cast some rays???
            -- todo: boxcast??? perhaps p100??
            --[[local Hit, Position = workspace:FindPartOnRayWithIgnoreList(Ray.new(Origin, Destination.Unit * (Distance - 2)), {workspace.Ignore})

            if Hit then
                return Menu:Notify("something in the way cuh", 2, Color3.new(1, 0, 0))
            end]]

            --[[for Column = -1, 1 do
                local Porn = Origin + Vector3.new(0, Column * 2, 0)

                for Row = -1, 1 do
                    local Sexy = Porn -- + (Root.CFrame.RightVector * Row)

                    local Hit, Position = workspace:FindPartOnRayWithIgnoreList(Ray.new(Sexy, Destination.Unit * (Distance - 2)), {workspace.Ignore})

                    if Hit then
                        return Menu:Notify("something in the way cuh", 2, Color3.new(1, 0, 0))
                    end
                end
            end]]

            Traveling = true

            -- Send("Move", Vector3.new(0/0, 0/0, 0/0), 0, 0, nil, -1, -1)
            -- Send("Move", Destination, 0, 0, nil, -1, -1)
            Teleport(Destination)
            task.wait(GetLatency())

            Traveling = false
        end
    })

    MiscM:Box({
        Text = "fast travel",
        Placeholder = "D2, G5, E7 (B-G)...,",
        Callback = function(Chunk, FocusLost)
            if not FocusLost then return end

            local Origin = Modules.Client.character.PrimaryPart.Position
            local Destination = ChunkToWorld(Chunk)

            if Destination then
                FastTravel(Origin, Destination + Vector3.new(ChunkSize, 0, ChunkSize) / 2)
            else
                Menu:Notify("invalid chunk name??", 2, Color3.new(1, 0, 0))
            end
        end
    })

    MiscM:Text({
        Text = "can get kicked and there must be nothing above you",
        Wrap = true
    })

    --[[MiscI:Toggle({
        Text = "better ui",
        Flag = "better_ui",
        State = true
    })

    MiscI:Toggle({
        Text = "better map",
        Flag = "better_map",
        State = true
    })]]

    MiscE:Toggle({
        Text = "invisibility",
        Flag = "invisibility"
    }):Bind({
        Flag = "invisibility_bind",
        Mode = "Always"
    })

    MiscE:Toggle({
        Text = "freeze players",
        Flag = "freeze_players"
    }):Bind({
        Flag = "freeze_players_bind",
        Mode = "Toggle"
    })

    MiscE:Toggle({
        Text = "bring players",
        Flag = "bring_players"
    }):Bind({
        Flag = "bring_players_bind",
        Mode = "Toggle"
    })

    MiscE:Box({
        Text = "bring filter",
        Placeholder = "peak, snowy... etc",
        Callback = function(Value)
            local Names = {}
            local Count = 0

            for Name in Value:lower():gsub("[%s]+", ""):gmatch("[^,]+") do
                for _, Player in next, PlayerService:GetPlayers() do
                    if Player.Name:lower():find(Name) then
                        Names[Player.UserId] = true

                        Count += 1

                        break
                    end
                end
            end

            MoveFilter = Count > 0 and Names
        end
    })

    MiscE:Toggle({
        Text = "resolver (show invis)",
        Flag = "resolver",
        State = true
    })

    MiscE:Toggle({
        Text = "spoof magnitude",
        Flag = "spoof_magnitude",
        State = true
    })

    --[[MiscE:Toggle({
        Text = "test thing",
        Flag = "test_thing"
    })]]

    MiscE:Toggle({
        Text = "test shit",
        Flag = "test_shit"
    })

    MiscE:Toggle({
        Text = "disable interpolation",
        Flag = "disable_interpolation",
        State = false
    })

    MiscO:Toggle({
        Text = "invert hotbar scroll",
        Flag = "invert_hotbar_scroll",
        State = true
    })

    MiscO:Toggle({
        Text = "always snore",
        Flag = "always_snore",
        State = true
    })

    MiscE:Toggle({
        Text = "force on ground???",
        Flag = "on_ground"
    })

   MiscE:Toggle({
        Text = "test",
        Flag = "test_thing"
    })

    MiscE:Bind({
        Text = "clip",
        Callback = function()
            Modules.Client.character.PrimaryPart.CFrame += Camera.CFrame.LookVector * Menu.Flags.clip_distance
        end
    })

    MiscE:Slider({
        Text = "clip distance",
        Flag = "clip_distance",
        Min = -10,
        Max = 10,
        Value = 10
    })

    --[[MiscE:Bind({
        Text = "vclip",
        Callback = function()
            Modules.Client.character.PrimaryPart.CFrame += Vector3.new(0, Menu.Flags.vclip_distance, 0)
        end
    })

    MiscE:Slider({
        Text = "vclip distance",
        Flag = "vclip_distance",
        Min = -10,
        Max = 10,
        Value = -6
    })]]
end

local ConfigTab = Menu:Tab("config") do
    local ConfigM = ConfigTab:Section("menu", 1)
    local ConfigT = ConfigTab:Section("tips", 2)

    ConfigM:Toggle({
        Text = "indecators",
        State = true,
        Callback = function(State)
            Menu:Indicators(State)
        end
    })

    --[[ConfigM:Slider({
        Text = "rainbow delta",
        Flag = "rainbow_delta",
        Min = 1,
        Max = 24,
        Value = 8
    })]]

    ConfigM:Bind({
        Text = "panic bind",
        Callback = function()
            Menu:Unload()
        end
    })
    
    ConfigM:Bind({
        Text = "menu bind",
        Key = "RightShift",
        Callback = function()
            Menu.Window.Visible = not Menu.Window.Visible
        end
    })
    
    ConfigM:Button({
        Text = "unload",
        Callback = function()
            Menu:Unload()
        end
    })

    ConfigT:Text({
        Text = "you can right click some keybinds to change how they activate",
        Wrap = true
    })

    ConfigT:Text({
        Text = "you can also right click colorpickers to copy and paste",
        Wrap = true
    })
    
    ConfigT:Text({
        Text = "",
    })

    ConfigT:Text({
        Text = "also.. snowy did some cool ui shit so props to that nigga",
        Wrap = true
    })
end

Menu:Init("facebook.com")
Menu:Indicators(true)
-- Menu:Notify("you should suck peak's dick", 5, Color3.fromRGB(0, 255, 0))
