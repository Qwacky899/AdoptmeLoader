--[[
    ADOPT ME UTILITY - SOURCE CODE
    Version: 1.0 (Scalable Architecture)
    
    Ehsjew
]]

-- 1. SYSTEM INITIALIZATION
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- UI LIBRARY LOADING
-- We use pcall to ensure it doesn't crash the whole script if HTTP fails
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("UI Failed to Load")
    return
end

-- WINDOW CONFIGURATION
local Window = Rayfield:CreateWindow({
    Name = "Adopt Me: Auto Manager",
    LoadingTitle = "System Loading...",
    LoadingSubtitle = "Obfuscated Build",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AdoptMeManager",
        FileName = "ManagerConfig"
    },
    KeySystem = false,
})

-- TABS
local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local DebugTab = Window:CreateTab("Debug / Sniffer", 4483362458)

-- VARIABLES
local farming = false
local showerLocation = nil
local detectedPet = nil

-- SECTION: REMOTE SNIFFER (The "Spy")
-- This listens for you to equip a pet, then grabs the ID safely.
local LogSection = DebugTab:CreateSection("Network Logs")
local LogLabel = DebugTab:CreateLabel("Status: Idle")

local function updateLog(text)
    LogLabel:Set(text)
    print("[SYSTEM]: " .. text)
end

MainTab:CreateButton({
    Name = "🔄 Scan Currently Equipped Pet",
    Callback = function()
        -- Safe Scan Method (Reads Workspace, not Database)
        local found = false
        if workspace:FindFirstChild("Pets") then
            for _, pet in pairs(workspace.Pets:GetChildren()) do
                local owner = pet:FindFirstChild("Owner") or pet:FindFirstChild("Player")
                if owner and (owner.Value == LocalPlayer or owner.Value == LocalPlayer.Name) then
                    detectedPet = pet
                    updateLog("CAPTURED: " .. pet.Name)
                    Rayfield:Notify({Title = "Pet Found", Content = "Target: " .. pet.Name, Duration = 3})
                    found = true
                    break
                end
            end
        end
        
        if not found then
            Rayfield:Notify({Title = "Error", Content = "Please equip a pet first!", Duration = 3})
        end
    end,
})

-- SECTION: SHOWER FARM
local FarmSection = MainTab:CreateSection("Shower Logic")

MainTab:CreateButton({
    Name = "📍 Set Current Spot as Shower",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            showerLocation = LocalPlayer.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Location Saved", Content = "Farm will use this spot.", Duration = 2})
        end
    end,
})

local FarmToggle = MainTab:CreateToggle({
    Name = "Enable Shower Farm",
    CurrentValue = false,
    Flag = "ShowerToggle",
    Callback = function(Value)
        farming = Value
        if Value then
            if not showerLocation then
                Rayfield:Notify({Title = "Warning", Content = "Set location first!", Duration = 3})
            end
            task.spawn(function()
                while farming do
                    pcall(function()
                        -- 1. Teleport
                        if showerLocation and LocalPlayer.Character then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = showerLocation
                        end
                        
                        -- 2. Anti-AFK
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                        
                        -- 3. Re-Scan if pet missing
                        if detectedPet and detectedPet.Parent ~= workspace.Pets then
                           -- Pet despawned logic here
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

-- SECTION: MISC
local MiscTab = Window:CreateTab("Misc", 4483362458)
MiscTab:CreateButton({
    Name = "☠️ Reset Character",
    Callback = function()
        if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
    end,
})

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "System ready. Check 'Auto Farm' tab.",
    Duration = 5,
    Image = 4483362458,
})
