if not game:IsLoaded() then
    game.Loaded:Wait()
end;

shared.Config = {
   Lyrics = loadstring(game:HttpGet('https://raw.githubusercontent.com/Perthys/rickroll/main/rick_roll.lua'))();
   TimeoutTimePerLyricDivision = 20;
   SignName = "Text Sign";
   Rainbow = true;
   CurrentColor = nil;
   CacheDistance = 30;
   CacheUpdateDelay = 2;
   Cache = {};
   WalkToPeople = true;
}

local Config = shared.Config

local Players = game:GetService("Players")
local Sort = loadstring(game:HttpGet('https://raw.githubusercontent.com/Perthys/BetterSortingAlgorithim/main/main.lua'))()

local LocalPlayer = Players.LocalPlayer

local Backpack = LocalPlayer.Backpack;

local Character, Humanoid;

local function Init() -- signals are unreliable as hell for some reason
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid"); do
	    Humanoid.AutoRotate = false;
	end
	
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");
end;

Init()

local SortByMag = Sort.new()
    :Add("Mag", 1, "Higher")

local function GetMagnitudeByParts(Part1, Part2)
    return (Part2.Position - Part1.Position).Magnitude;
end;

local function GetMagnitude(Position1, Position2)
    return (Position1 - Position2).Magnitude;
end;

local function GetSign()
    Init()
    local Sign = Character:FindFirstChild(Config.SignName)

    if Sign then
        return Sign
    end
    
    return false -- not needed just wanted to structure it
end;

local function GetRemote(Sign)
    if Sign then
        local Remote = Sign:FindFirstChild("Interact")
        
        if Remote then
            return Remote 
        end
        
        return false
    end
end

local function SetText(Text)
    local Sign = GetSign()
    local Text = Text or ""
    local Remote = GetRemote(Sign);
    
    if Remote then
        return Remote:FireServer("SetText", Text)
    end
end

local function SetColor(Color1, Color2)
    local Sign = GetSign()
    local Remote = GetRemote(Sign);

    if Remote then
        return Remote:FireServer("SetGradient", ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color1),
            ColorSequenceKeypoint.new(1, Color2)
        }), 0)
    end
end

local function EquipSign()
	Init()

	local Sign = Backpack:FindFirstChild(Config.SignName)

	if Sign then
		Sign.Parent = Character;
	end
end

local function GetTickColor()
    return Color3.fromHSV(tick() % 10 / 10, 1, 1)
end

local function Reset()
    SetText()
    SetColor(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
end

local function Rainbowify()
    if shared.Config.Rainbow then
        SetColor(CurrentColor, GetTickColor())
        CurrentColor = GetTickColor();
    end
end

local function Rainbowify()
    if shared.Config.Rainbow then
        SetColor(Config.CurrentColor, GetTickColor())
        Config.CurrentColor = GetTickColor();
    end
end

local function CreatePartAtCFrame(CFrame, Shape)
    local Part = Instance.new("Part") do
        Part.CFrame = CFrame
        Part.Parent = workspace;
        Part.Name = "TestPart"
        Part.Anchored = true
        Part.CanCollide = false
        Part.Shape = Shape or Enum.PartType.Ball
        Part.Material = Enum.Material.Neon
        Part.Color = Color3.fromHSV(tick() % 10 / 10, 1, 1)

        Part.Size = Vector3.new(0.5, 0.5, 0.5)
    end

    return Part
end

local function GetInformationForLine(Position1, Position2)
    local Distance = (Position1 - Position2).Magnitude
    
    return CFrame.new(Position1,Position2) * CFrame.new(0,0, -Distance/2)
end

local function LookAtPart(Part1, Part) 
    Part1.CFrame = CFrame.lookAt(Part1.Position, Part.Position, Vector3.new(0,1,0))
end

local function MakeLine(Position1, Position2, Thickness)
    local Thickness = Thickness or 0.1
    
    local Distance;
    
    local Part = CreatePartAtCFrame(CFrame.new(), Enum.PartType.Block); do
        Distance = (Position1-Position2).Magnitude do
            Part.Parent = workspace;
            Part.CFrame = CFrame.new(Position1,Position2) * CFrame.new(0,0,-Distance/2)
            Part.Size = Vector3.new(Thickness,Thickness,Distance)
        end
    end
    
    return Part, CFrame.new(Position1,Position2) * CFrame.new(0,0,-Distance/2), Vector3.new(Thickness,Thickness,Distance)
end

local function MaintainLine(Line, Part1, Part2, Thickness, Time)
    task.spawn(function()
        local Run = true;
        
        task.delay(Time, function()
            Run = false;
        end)
        
        while Run do
            Line.CFrame = GetInformationForLine(Part1.Position, Part2.Position)
            Line.Color = Color3.fromHSV(tick() % 10 / 10, 1, 1)
            Line.Size = Vector3.new(Thickness, Thickness, GetMagnitudeByParts(Part1, Part2))
            
            wait(0.5)
        end
        
        Line:Destroy()
    end)
end

local function CheckIfAccessiblePlayer(Player)
    local Character = Player.Character
    
    if Character then
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart");
        local Humanoid = Character:FindFirstChild("Humanoid")
        
        if HumanoidRootPart and Humanoid then
            return Player, Character, HumanoidRootPart, Humanoid
        end
    end
    
    return false
end

local function GetAllPlayersAndDistance()
    local ReturnedArray = {}
    
    for Index, Player in pairs(Players:GetPlayers()) do
        Init()
        if Player ~= LocalPlayer then
            local Player, P_Character, P_Root, P_Humanoid = CheckIfAccessiblePlayer(Player)
            
            if Player then
                local Mag = GetMagnitudeByParts(HumanoidRootPart, P_Root)
                
                if Mag <= Config.CacheDistance then
                    table.insert(ReturnedArray, {
                        Player = Player;
                        Mag = Mag;
                        Character = P_Character;
                        HumanoidRootPart = P_Root;
                        Humanoid = P_Humanoid
                    })
                
                    print(Player.Name)
                    local Line = MakeLine(HumanoidRootPart.Position, P_Root.Position, 0.1)
                    
                    MaintainLine(Line, HumanoidRootPart, P_Root, 0.1, Config.CacheUpdateDelay);
                end
            end
        end
    end
    
    return SortByMag:Sort(ReturnedArray)
end

shared.Looped = false; wait(1) shared.Looped = true;

Config.CurrentColor = GetTickColor(); Reset()


local LastTarget = nil

task.spawn(function()
    if Config.WalkToPeople then
        while shared.Looped do
            Init()
            Config.Cache = GetAllPlayersAndDistance();
            
            local Target = Config.Cache[1];
            
            if Target then
                if Target ~= LastTarget then
                    LastTarget = Target
                    task.spawn(function()
                        local Run = true;
                        task.delay(Config.CacheUpdateDelay, function()
                            Run = false;
                        end)
                        
                        while Run do
                            Humanoid:MoveTo(Target.HumanoidRootPart.CFrame * CFrame.new(0,0,-5).p)
                            LookAtPart(HumanoidRootPart, Target.HumanoidRootPart)
                            
                            Humanoid.MoveToFinished:Wait()
                        end
                    end)
                elseif Target == LastTarget then
                    Target = Config.Cache[2];
                    
                    if not Target then
                    Target = Config.Cache[1]
                    LastTarget = Target
                    
                        task.spawn(function()
                            local Run = true;
                            task.delay(Config.CacheUpdateDelay, function()
                                Run = false;
                            end)
                            
                            while Run do
                                Humanoid:MoveTo(Target.HumanoidRootPart.CFrame * CFrame.new(0,0,5).p)
                                LookAtPart(HumanoidRootPart, Target.HumanoidRootPart)
                                
                                Humanoid.MoveToFinished:Wait()
                            end
                        end)
                    end
                end
            end
            
            wait(Config.CacheUpdateDelay);
        end
    end
end)

while shared.Looped do
    for Index, Text in pairs(Config.Lyrics) do
        if not shared.Looped then
            Reset()
            break
        end
        
        Rainbowify()
        EquipSign()

        SetText(Text)
        
        wait(#Text / Config.TimeoutTimePerLyricDivision)
    end
end
