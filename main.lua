if not game:IsLoaded() then
    game.Loaded:Wait()
end;

shared.Config = {
   Lyrics = loadstring(game:HttpGet('https://raw.githubusercontent.com/Perthys/rickroll/main/rick_roll.lua'))();
   TimeoutTimePerLyricDivision = 20;
   SignName = "Text Sign";
   Rainbow = true;
   CurrentColor = nil;
}

local Config = shared.Config

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Backpack = LocalPlayer.Backpack;

local Character, Humanoid;

local function Init() -- signals are unreliable as hell for some reason
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid");
end;

Init()

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
    end
	
	return false
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

shared.Looped = false; wait(1) shared.Looped = true;

Config.CurrentColor = GetTickColor(); Reset()

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
