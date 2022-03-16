if not game:IsLoaded() then
    game.Loaded:Wait()
end;

shared.Config = {
   Lyrics = loadstring(game:HttpGet('https://raw.githubusercontent.com/Perthys/rickroll/main/rick_roll.lua'))();
   TimeoutTimePerLyricDivision = 10;
   SignName = "Text Sign";
   Rainbow = true
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

local function SetText(Text)
    local Sign = GetSign()
    local Text = Text or ""

    if Sign then
        local Remote = Sign:FindFirstChild("Interact")
        if Remote then
            Remote:FireServer("SetText", Text)
        end
    end
end

local function SetColor(Color1, Color2)
    local Sign = GetSign()

    if Sign then
        local Remote = Sign:FindFirstChild("Interact")
        if Remote then
            Remote:FireServer("SetGradient", ColorSequence.new({
            	ColorSequenceKeypoint.new(0, Color1),
            	ColorSequenceKeypoint.new(1, Color2)
            }), 0)
        end
    end
end

local function EquipSign()
	Init()

	local Sign = Backpack:FindFirstChild(Config.SignName)

	if Sign then
		Humanoid:EquipTool(Sign);
	end
end

local function GetTickColor()
    return Color3.fromHSV(tick() % 10 / 10, 1, 1)
end

local function Reset()
    SetText()
    SetColor(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
end

shared.Looped = false; wait(); shared.Looped = true;

local CurrentColor = GetTickColor(); Reset()

while shared.Looped do
	EquipSign()
    for i = 1,#Config.Lyrics do
        local Text = Config.Lyrics[i]

        SetText(Text)
        
        if shared.Config.Rainbow then
            SetColor(CurrentColor, GetTickColor())
            CurrentColor = GetTickColor();
        end
        
        wait(#Text / Config.TimeoutTimePerLyricDivision)
        
        if not shared.Looped then
            Reset()
          break
        end
    end
end
