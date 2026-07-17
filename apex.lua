-- APEX CHEAT V19.4 | NINJA LEGENDS FIXED
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInput")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local RootPart = Char:WaitForChild("HumanoidRootPart")

-- ===== СОСТОЯНИЯ =====
local flyEnabled = false
local noclipEnabled = false
local infiniteJump = false
local autoClicker = false
local clickInterval = 0.5
local autoClickerConn = nil
local flySpeed = 50
local speedEnabled = false
local speedMultiplier = 5
local freezeEnabled = false
local baseWalkSpeed = Humanoid.WalkSpeed
local baseJumpPower = Humanoid.JumpPower
local menuOpen = true
local currentTabIndex = 1
local blueHue = 0
local waitingForKey = nil

-- COMBAT
local aimbotEnabled = false
local triggerbotEnabled = false

-- VISUALS
local espEnabled = false
local fullbrightEnabled = false
local chamsEnabled = false
local tracersEnabled = false

-- FUNNY FUNCTIONS
local spinEnabled = false
local spinSpeed = 1
local bobbingEnabled = false
local bobbingHeight = 2
local jitterEnabled = false
local jitterStrength = 0.5
local flingEnabled = false
local flingPower = 50
local invisibleEnabled = false

-- ===== GAMES STATES =====
-- Ninja Legends
local ninjaDuping = false
local ninjaDupingConn = nil
local ninjaDupedCount = 0

-- MM2
local mm2TeleportToGun = false
local mm2TeleportToMurderer = false
local mm2TeleportConn = nil
local mm2RoleESP = false
local mm2EspConn = nil

-- Muscle Legends
local muscleAutoWalk = false
local muscleWalkConn = nil
local muscleAutoClick = false
local muscleClickConn = nil
local musclePetDupe = false
local muscleDupeConn = nil

-- ===== БИНДЫ =====
local binds = {
    fly = {key = Enum.KeyCode.F, label = "Fly"},
    noclip = {key = Enum.KeyCode.N, label = "Noclip"},
    jump = {key = Enum.KeyCode.J, label = "Infinite Jump"},
    speed = {key = Enum.KeyCode.X, label = "Speed"},
    autoclicker = {key = Enum.KeyCode.C, label = "AutoClicker"},
    aimbot = {key = Enum.KeyCode.Z, label = "Aimbot"},
    triggerbot = {key = Enum.KeyCode.T, label = "Triggerbot"},
    esp = {key = Enum.KeyCode.E, label = "ESP"},
    fullbright = {key = Enum.KeyCode.B, label = "FullBright"},
    chams = {key = Enum.KeyCode.H, label = "Chams"},
    tracers = {key = Enum.KeyCode.R, label = "Tracers"},
    freeze = {key = Enum.KeyCode.G, label = "Freeze"},
    spin = {key = Enum.KeyCode.K, label = "Spin"},
    bobbing = {key = Enum.KeyCode.O, label = "Bobbing"},
    jitter = {key = Enum.KeyCode.P, label = "Jitter"},
    fling = {key = Enum.KeyCode.L, label = "Fling"},
    invisible = {key = Enum.KeyCode.I, label = "Invisible"}
}

local bindButtons = {}
local function updateBindButton(funcName)
    local btn = bindButtons[funcName]
    if btn then
        local keyName = binds[funcName].key and binds[funcName].key.Name or "None"
        btn.Text = keyName
    end
end

-- ===== НОКЛИП =====
local noclipConn = nil
local function applyNoclip()
    if not noclipEnabled or not Char then return end
    for _, part in pairs(Char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function toggleNoclip(state)
    noclipEnabled = state
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if not noclipEnabled then
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        return
    end
    noclipConn = RunService.Heartbeat:Connect(function()
        if not noclipEnabled or not Char then return end
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    applyNoclip()
end

-- ===== ФУНКЦИИ =====
local flyConn = nil
local flyBodyVel = nil
local flyBodyGyro = nil

local function toggleFly(state)
    flyEnabled = state
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if not flyEnabled then RootPart.Velocity = Vector3.new(0,0,0) return end
    
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyBodyVel.Velocity = Vector3.new(0,0,0)
    flyBodyVel.Parent = RootPart
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 1e5
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.CFrame = RootPart.CFrame
    flyBodyGyro.Parent = RootPart
    
    flyConn = RunService.Heartbeat:Connect(function()
        if not Char or not RootPart or not flyEnabled then return end
        local moveVec = Vector3.new()
        local forward = Camera.CFrame.LookVector * Vector3.new(1,0,1)
        local right = Camera.CFrame.RightVector * Vector3.new(1,0,1)
        local up = Vector3.new(0,1,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + up end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - up end
        
        if moveVec.Magnitude > 0 then moveVec = moveVec.Unit * flySpeed else moveVec = Vector3.new(0,0,0) end
        flyBodyVel.Velocity = moveVec
        flyBodyGyro.CFrame = Camera.CFrame
    end)
end

local jumpConn = nil
local function toggleJump(state)
    infiniteJump = state
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    if not infiniteJump then return end
    jumpConn = RunService.Heartbeat:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function toggleSpeed(state)
    speedEnabled = state
    Humanoid.WalkSpeed = speedEnabled and (baseWalkSpeed * speedMultiplier) or baseWalkSpeed
end

local function toggleAutoClicker(state)
    autoClicker = state
    if autoClickerConn then autoClickerConn:Disconnect() autoClickerConn = nil end
    if not autoClicker then return end
    autoClickerConn = RunService.Heartbeat:Connect(function()
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            VirtualInput:SendMouseButtonEvent(0,0,0,true,Enum.UserInputType.MouseButton1,true)
            task.wait(clickInterval)
            VirtualInput:SendMouseButtonEvent(0,0,0,false,Enum.UserInputType.MouseButton1,true)
            task.wait(0.05)
        end
    end)
end

-- ===== FREEZE =====
local freezeConn = nil
local freezeBodyPos = nil
local function toggleFreeze(state)
    freezeEnabled = state
    if freezeConn then freezeConn:Disconnect() freezeConn = nil end
    if freezeBodyPos then freezeBodyPos:Destroy() freezeBodyPos = nil end
    if not freezeEnabled then 
        RootPart.Velocity = Vector3.new(0,0,0)
        return 
    end
    freezeBodyPos = Instance.new("BodyPosition")
    freezeBodyPos.P = 1e6
    freezeBodyPos.D = 1e3
    freezeBodyPos.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    freezeBodyPos.Position = RootPart.Position
    freezeBodyPos.Parent = RootPart
    freezeConn = RunService.Heartbeat:Connect(function()
        if not freezeEnabled or not RootPart then return end
        freezeBodyPos.Position = RootPart.Position
        RootPart.Velocity = Vector3.new(0,0,0)
        RootPart.RotVelocity = Vector3.new(0,0,0)
    end)
end

-- ===== COMBAT =====
local aimbotConn = nil
local function toggleAimbot(state)
    aimbotEnabled = state
    if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
    if not aimbotEnabled then return end
    aimbotConn = RunService.Heartbeat:Connect(function()
        if not aimbotEnabled or not Char or not RootPart then return end
        local closestPlayer = nil
        local closestDist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local targetPart = v.Character.HumanoidRootPart
                if targetPart ~= RootPart then
                    local dist = (RootPart.Position - targetPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = v
                    end
                end
            end
        end
        if closestPlayer and closestPlayer.Character then
            local target = closestPlayer.Character.HumanoidRootPart
            if target and target ~= RootPart then
                local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.25)
            end
        end
    end)
end

local triggerConn = nil
local function toggleTriggerbot(state)
    triggerbotEnabled = state
    if triggerConn then triggerConn:Disconnect() triggerConn = nil end
    if not triggerbotEnabled then return end
    triggerConn = RunService.Heartbeat:Connect(function()
        if not triggerbotEnabled or not Char then return end
        local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local ray = Camera:ViewportPointToRay(screenCenter.X, screenCenter.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {Char}
        local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if hit and hit.Instance and hit.Instance.Parent then
            local targetParent = hit.Instance.Parent
            local humanoid = targetParent:FindFirstChild("Humanoid")
            if not humanoid then
                for _, child in pairs(targetParent:GetChildren()) do
                    if child:IsA("Humanoid") then humanoid = child break end
                end
            end
            if humanoid then
                local targetPlayer = Players:GetPlayerFromCharacter(targetParent)
                if targetPlayer and targetPlayer ~= Player then
                    VirtualInput:SendMouseButtonEvent(0,0,0,true,Enum.UserInputType.MouseButton1,true)
                    task.wait(0.05)
                    VirtualInput:SendMouseButtonEvent(0,0,0,false,Enum.UserInputType.MouseButton1,true)
                end
            end
        end
    end)
end

-- ===== VISUALS =====
local espConn = nil
local espHighlights = {}
local function toggleEsp(state)
    espEnabled = state
    if espConn then espConn:Disconnect() espConn = nil end
    if not espEnabled then
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        espHighlights = {}
        return
    end
    espConn = RunService.Heartbeat:Connect(function()
        if not espEnabled then return end
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character then
                for _, part in pairs(v.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local highlight = part:FindFirstChild("ESP_Highlight")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "ESP_Highlight"
                            highlight.FillColor = Color3.fromRGB(0, 150, 255)
                            highlight.OutlineColor = Color3.fromRGB(255,255,255)
                            highlight.FillTransparency = 0.3
                            highlight.Parent = part
                            table.insert(espHighlights, highlight)
                        end
                    end
                end
            end
        end
    end)
end

local function toggleFullbright(state)
    fullbrightEnabled = state
    local Lighting = game:GetService("Lighting")
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 8
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(0,0,0)
    end
end

local chamsConn = nil
local function toggleChams(state)
    chamsEnabled = state
    if chamsConn then chamsConn:Disconnect() chamsConn = nil end
    if not chamsEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character then
                for _, part in pairs(v.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Plastic
                        part.Transparency = 0
                    end
                end
            end
        end
        return
    end
    chamsConn = RunService.Heartbeat:Connect(function()
        if not chamsEnabled then return end
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character then
                for _, part in pairs(v.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.3
                    end
                end
            end
        end
    end)
end

local tracersConn = nil
local tracerLines = {}
local function toggleTracers(state)
    tracersEnabled = state
    if tracersConn then tracersConn:Disconnect() tracersConn = nil end
    if not tracersEnabled then
        for _, t in pairs(tracerLines) do
            if t and t.Parent then t:Destroy() end
        end
        tracerLines = {}
        return
    end
    tracersConn = RunService.Heartbeat:Connect(function()
        if not tracersEnabled or not Camera then return end
        for _, t in pairs(tracerLines) do
            if t and t.Parent then t:Destroy() end
        end
        tracerLines = {}
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = v.Character.HumanoidRootPart.Position
                local startPos = Camera.CFrame.Position
                local dist = (startPos - targetPos).Magnitude
                if dist < 500 then
                    local line = Instance.new("Part")
                    line.Size = Vector3.new(0.05, 0.05, dist)
                    line.CFrame = CFrame.lookAt(startPos, targetPos) * CFrame.new(0, 0, -dist/2)
                    line.BrickColor = BrickColor.new("Bright blue")
                    line.Material = Enum.Material.Neon
                    line.Anchored = true
                    line.CanCollide = false
                    line.Parent = workspace
                    table.insert(tracerLines, line)
                end
            end
        end
    end)
end

-- ===== FUNNY FUNCTIONS =====
local spinConn = nil
local function toggleSpin(state)
    spinEnabled = state
    if spinConn then spinConn:Disconnect() spinConn = nil end
    if not spinEnabled then return end
    spinConn = RunService.Heartbeat:Connect(function()
        if not spinEnabled or not RootPart then return end
        local currentCF = RootPart.CFrame
        local angle = spinSpeed * 0.1
        local newCF = currentCF * CFrame.Angles(0, angle, 0)
        RootPart.CFrame = newCF
    end)
end

local bobbingConn = nil
local bobbingTime = 0
local function toggleBobbing(state)
    bobbingEnabled = state
    if bobbingConn then bobbingConn:Disconnect() bobbingConn = nil end
    bobbingTime = 0
    if not bobbingEnabled then return end
    bobbingConn = RunService.Heartbeat:Connect(function()
        if not bobbingEnabled or not RootPart then return end
        bobbingTime = bobbingTime + 0.05
        local offset = math.sin(bobbingTime) * bobbingHeight * 0.5
        RootPart.CFrame = RootPart.CFrame + Vector3.new(0, offset, 0)
    end)
end

local jitterConn = nil
local function toggleJitter(state)
    jitterEnabled = state
    if jitterConn then jitterConn:Disconnect() jitterConn = nil end
    if not jitterEnabled then return end
    jitterConn = RunService.Heartbeat:Connect(function()
        if not jitterEnabled or not RootPart then return end
        local jitterVec = Vector3.new(
            (math.random() - 0.5) * jitterStrength * 2,
            (math.random() - 0.5) * jitterStrength * 2,
            (math.random() - 0.5) * jitterStrength * 2
        )
        RootPart.CFrame = RootPart.CFrame + jitterVec
    end)
end

local flingConn = nil
local function toggleFling(state)
    flingEnabled = state
    if flingConn then flingConn:Disconnect() flingConn = nil end
    if not flingEnabled then return end
    flingConn = RunService.Heartbeat:Connect(function()
        if not flingEnabled or not RootPart then return end
        local forward = Camera.CFrame.LookVector * Vector3.new(1,0,1)
        if forward.Magnitude == 0 then forward = Vector3.new(1,0,0) end
        RootPart.Velocity = forward.Unit * flingPower
        RootPart.Velocity = RootPart.Velocity + Vector3.new(0, 10, 0)
        task.wait(0.5)
        RootPart.Velocity = Vector3.new(0,0,0)
    end)
end

local function toggleInvisible(state)
    invisibleEnabled = state
    if not Char then return end
    for _, part in pairs(Char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = invisibleEnabled and 1 or 0
        end
    end
end

-- =====================================================
-- ===== NINJA LEGENDS FUNCTIONS =====
-- =====================================================

local function getNinjaPets()
    local pets = {}
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, child in pairs(backpack:GetChildren()) do
            if child:IsA("Tool") and string.find(child.Name, "Pet") then
                table.insert(pets, child)
            end
        end
    end
    return pets
end

local function performNinjaDup()
    if not ninjaDuping then return end
    local pets = getNinjaPets()
    if #pets == 0 then return end
    for _, pet in pairs(pets) do
        local cloned = pet:Clone()
        cloned.Name = pet.Name .. "_DUP_" .. tostring(os.time() + math.random(1,999))
        local parent = pet.Parent
        if parent then
            local exists = false
            for _, child in pairs(parent:GetChildren()) do
                if child.Name == cloned.Name then
                    exists = true
                    break
                end
            end
            if not exists then
                cloned.Parent = parent
                ninjaDupedCount = ninjaDupedCount + 1
            end
        end
    end
end

local function toggleNinjaDup(state)
    ninjaDuping = state
    if ninjaDupingConn then ninjaDupingConn:Disconnect() ninjaDupingConn = nil end
    if not ninjaDuping then return end
    ninjaDupedCount = 0
    ninjaDupingConn = RunService.Heartbeat:Connect(function()
        if not ninjaDuping then return end
        if tick() % 1.5 < 0.05 then
            performNinjaDup()
        end
    end)
end

-- TELEPORT ALL ISLANDS (ОДНО НАЖАТИЕ)
local function teleportAllIslands()
    pcall(function()
        local islands = {}
        local islandFolder = Workspace:FindFirstChild("islandUnlockParts")
        if islandFolder then
            for _, part in pairs(islandFolder:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(islands, part)
                end
            end
        else
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and (string.find(obj.Name, "Island") or string.find(obj.Name, "Zone")) then
                    local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Part") or obj:FindFirstChild("BasePart")
                    if part then
                        table.insert(islands, part)
                    end
                end
            end
        end
        
        -- Сортируем по Y координате (чтобы последний был самый высокий)
        table.sort(islands, function(a, b)
            return a.Position.Y < b.Position.Y
        end)
        
        for i, part in ipairs(islands) do
            if part and part.Position then
                RootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                task.wait(0.3)
            end
        end
        print("Teleported to " .. #islands .. " islands")
    end)
end

-- AUTO COLLECT ALL (ОДНО НАЖАТИЕ)
local function autoCollectAll()
    pcall(function()
        local collected = 0
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and (string.find(obj.Name, "Soul") or string.find(obj.Name, "Chi") or string.find(obj.Name, "Karma") or string.find(obj.Name, "Chest") or string.find(obj.Name, "Crate")) then
                RootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                task.wait(0.15)
                local detector = obj:FindFirstChild("ClickDetector")
                if detector then
                    detector:Fire()
                    collected = collected + 1
                    task.wait(0.1)
                end
            end
        end
        print("Collected " .. collected .. " items")
    end)
end

-- =====================================================
-- ===== MM2 FUNCTIONS =====
-- =====================================================

local function getMM2Gun()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") and (string.find(obj.Name, "Gun") or string.find(obj.Name, "Pistol") or string.find(obj.Name, "Revolver")) then
            return obj
        end
    end
    return nil
end

local function toggleMM2TeleportToGun(state)
    mm2TeleportToGun = state
    if mm2TeleportConn then mm2TeleportConn:Disconnect() mm2TeleportConn = nil end
    if not mm2TeleportToGun and not mm2TeleportToMurderer then return end
    mm2TeleportConn = RunService.Heartbeat:Connect(function()
        if mm2TeleportToGun then
            local gun = getMM2Gun()
            if gun then
                local part = gun:FindFirstChild("Handle") or gun
                if part then
                    RootPart.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
        if mm2TeleportToMurderer then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Player and v.Character then
                    local hasKnife = false
                    for _, child in pairs(v.Character:GetChildren()) do
                        if child:IsA("Tool") and string.find(child.Name, "Knife") then
                            hasKnife = true
                            break
                        end
                    end
                    if hasKnife then
                        local target = v.Character:FindFirstChild("HumanoidRootPart")
                        if target then
                            RootPart.CFrame = target.CFrame + Vector3.new(0, 2, 0)
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function toggleMM2TeleportToMurderer(state)
    mm2TeleportToMurderer = state
    if mm2TeleportConn then mm2TeleportConn:Disconnect() mm2TeleportConn = nil end
    if not mm2TeleportToGun and not mm2TeleportToMurderer then return end
    mm2TeleportConn = RunService.Heartbeat:Connect(function()
        if mm2TeleportToGun then
            local gun = getMM2Gun()
            if gun then
                local part = gun:FindFirstChild("Handle") or gun
                if part then
                    RootPart.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
        if mm2TeleportToMurderer then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Player and v.Character then
                    local hasKnife = false
                    for _, child in pairs(v.Character:GetChildren()) do
                        if child:IsA("Tool") and string.find(child.Name, "Knife") then
                            hasKnife = true
                            break
                        end
                    end
                    if hasKnife then
                        local target = v.Character:FindFirstChild("HumanoidRootPart")
                        if target then
                            RootPart.CFrame = target.CFrame + Vector3.new(0, 2, 0)
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function toggleMM2RoleESP(state)
    mm2RoleESP = state
    if mm2EspConn then mm2EspConn:Disconnect() mm2EspConn = nil end
    if not mm2RoleESP then
        for _, h in pairs(game.CoreGui:GetChildren()) do
            if h.Name == "MM2_RoleESP" then h:Destroy() end
        end
        return 
    end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "MM2_RoleESP"
    espFolder.Parent = game.CoreGui
    
    local function trackPlayer(player)
        if player == Player then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_ESP"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = espFolder
        
        coroutine.wrap(function()
            while player and player.Parent do
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        highlight.Adornee = char
                        local hasKnife = false
                        local hasGun = false
                        
                        for _, child in pairs(char:GetChildren()) do
                            if child:IsA("Tool") then
                                if string.find(child.Name, "Knife") then hasKnife = true end
                                if string.find(child.Name, "Gun") or string.find(child.Name, "Pistol") or string.find(child.Name, "Revolver") then hasGun = true end
                            end
                        end
                        
                        if hasKnife then
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        elseif hasGun then
                            highlight.FillColor = Color3.fromRGB(0, 0, 255)
                        else
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        end
                        highlight.Enabled = true
                    else
                        highlight.Enabled = false
                    end
                end)
                task.wait(1)
            end
            highlight:Destroy()
        end)()
    end
    
    for _, v in pairs(Players:GetPlayers()) do
        trackPlayer(v)
    end
    Players.PlayerAdded:Connect(trackPlayer)
end

-- =====================================================
-- ===== MUSCLE LEGENDS FUNCTIONS =====
-- =====================================================

local function toggleMuscleAutoWalk(state)
    muscleAutoWalk = state
    if muscleWalkConn then muscleWalkConn:Disconnect() muscleWalkConn = nil end
    if not muscleAutoWalk then return end
    muscleWalkConn = RunService.Heartbeat:Connect(function()
        if muscleAutoWalk then
            local moveVec = Camera.CFrame.LookVector * Vector3.new(1,0,1)
            if moveVec.Magnitude > 0 then
                RootPart.Velocity = moveVec.Unit * 16
            else
                RootPart.Velocity = Vector3.new(16, 0, 0)
            end
        end
    end)
end

local function toggleMuscleAutoClick(state)
    muscleAutoClick = state
    if muscleClickConn then muscleClickConn:Disconnect() muscleClickConn = nil end
    if not muscleAutoClick then return end
    muscleClickConn = RunService.Heartbeat:Connect(function()
        if muscleAutoClick then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ClickDetector") then
                        local parent = obj.Parent
                        if parent and parent:IsA("BasePart") then
                            RootPart.CFrame = parent.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                            obj:Fire()
                            task.wait(0.3)
                        end
                    end
                end
            end)
        end
    end)
end

local function toggleMusclePetDupe(state)
    musclePetDupe = state
    if muscleDupeConn then muscleDupeConn:Disconnect() muscleDupeConn = nil end
    if not musclePetDupe then return end
    muscleDupeConn = RunService.Heartbeat:Connect(function()
        if not musclePetDupe then return end
        pcall(function()
            local pets = {}
            local backpack = Player:FindFirstChild("Backpack")
            if backpack then
                for _, child in pairs(backpack:GetChildren()) do
                    if child:IsA("Tool") and (string.find(child.Name, "Pet") or string.find(child.Name, "Egg")) then
                        table.insert(pets, child)
                    end
                end
            end
            for _, pet in pairs(pets) do
                local cloned = pet:Clone()
                cloned.Name = pet.Name .. "_DUP_" .. tostring(os.time() + math.random(1000,9999))
                local parent = pet.Parent
                if parent then
                    cloned.Parent = parent
                end
            end
        end)
    end)
end

-- ===== UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ApexCheat"
screenGui.Parent = Player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 820, 0, 560)
mainFrame.Position = UDim2.new(0.5, -410, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 3.5
mainStroke.Transparency = 0.15
mainStroke.Color = Color3.fromRGB(0, 150, 255)
mainStroke.Parent = mainFrame

local bgLayer = Instance.new("Frame")
bgLayer.Size = UDim2.new(1, 0, 1, 0)
bgLayer.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
bgLayer.BackgroundTransparency = 0.95
bgLayer.BorderSizePixel = 0
bgLayer.Parent = mainFrame

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 16)
bgCorner.Parent = bgLayer

local function pulseAnimation()
    blueHue = (blueHue + 0.005) % 1
    local r, g, b = Color3.fromHSV(0.58 + math.sin(blueHue * math.pi) * 0.05, 0.9, 0.8)
    mainStroke.Color = Color3.fromRGB(r*255, g*255, b*255)
end

-- ===== ВЕРХНЯЯ ПАНЕЛЬ =====
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(8, 10, 24)
topBar.BackgroundTransparency = 0.3
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "APEX CHEAT V19.4"
titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(0.3, 0, 1, 0)
creditLabel.Position = UDim2.new(0.45, 0, 0, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "by Apex + SWILL"
creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextXAlignment = Enum.TextXAlignment.Left
creditLabel.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 50, 1, 0)
closeBtn.Position = UDim2.new(1, -55, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar

closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    mainFrame.Visible = false
end)

-- ===== ОСНОВНАЯ ОБЛАСТЬ =====
local mainBody = Instance.new("Frame")
mainBody.Size = UDim2.new(1, 0, 1, -50)
mainBody.Position = UDim2.new(0, 0, 0, 50)
mainBody.BackgroundTransparency = 1
mainBody.Parent = mainFrame

-- === ВКЛАДКИ (СЛЕВА) ===
local tabSidebar = Instance.new("Frame")
tabSidebar.Size = UDim2.new(0, 155, 1, 0)
tabSidebar.BackgroundTransparency = 1
tabSidebar.Parent = mainBody

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 8)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabSidebar

local tabData = {
    {name = "Visuals"},
    {name = "Movement"},
    {name = "Combat"},
    {name = "Other"},
    {name = "Funny"},
    {name = "Games"},
    {name = "Binds"}
}

local tabButtons = {}
local tabContainers = {}

for i, data in ipairs(tabData) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 80, 160) or Color3.fromRGB(10, 10, 25)
    btn.BackgroundTransparency = 0.4
    btn.Text = data.name
    btn.TextColor3 = (i == 1) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(160, 160, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = tabSidebar
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTabIndex = i
        for idx, b in pairs(tabButtons) do
            local isActive = (idx == i)
            b.BackgroundColor3 = isActive and Color3.fromRGB(0, 80, 160) or Color3.fromRGB(10, 10, 25)
            b.TextColor3 = isActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(160, 160, 200)
        end
        for idx, container in pairs(tabContainers) do
            container.Visible = (idx == i)
        end
    end)
    
    table.insert(tabButtons, btn)
end

-- === КОНТЕНТ (СПРАВА) ===
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -175, 1, -15)
contentArea.Position = UDim2.new(0, 165, 0, 10)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainBody

for i = 1, #tabData do
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 5
    container.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    container.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.Visible = (i == 1)
    container.Parent = contentArea
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    tabContainers[i] = container
end

-- ===== UI ЭЛЕМЕНТЫ =====
local function createToggleCard(parent, labelText, default, onChange)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 42)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(30, 40, 80)
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210, 215, 240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = card
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Position = UDim2.new(0.78, 0, 0.14, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = card
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
        btn.Text = state and "ON" or "OFF"
        onChange(state)
    end)
    
    return btn
end

local function createSliderCard(parent, labelText, minVal, maxVal, default, onChange)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 42)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(30, 40, 80)
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. " " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(210, 215, 240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = card
    
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0.25, 0, 0.7, 0)
    slider.Position = UDim2.new(0.72, 0, 0.15, 0)
    slider.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.new(1,1,1)
    slider.TextScaled = true
    slider.Font = Enum.Font.Gotham
    slider.ClearTextOnFocus = false
    slider.BorderSizePixel = 0
    slider.Parent = card
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = slider
    
    slider.FocusLost:Connect(function()
        local num = tonumber(slider.Text)
        if num then
            num = math.clamp(num, minVal, maxVal)
            slider.Text = tostring(num)
            onChange(num)
            lbl.Text = labelText .. " " .. tostring(num)
        else
            slider.Text = tostring(default)
        end
    end)
end

local function createBindCard(parent, funcName, labelText)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(30, 40, 80)
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210, 215, 240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = card
    
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 80, 0, 30)
    bindBtn.Position = UDim2.new(0.78, 0, 0.17, 0)
    bindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    local keyName = binds[funcName].key and binds[funcName].key.Name or "None"
    bindBtn.Text = keyName
    bindBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    bindBtn.TextScaled = true
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.BorderSizePixel = 0
    bindBtn.Parent = card
    bindBtn.AutoButtonColor = false
    
    local bindCorner = Instance.new("UICorner")
    bindCorner.CornerRadius = UDim.new(0, 6)
    bindCorner.Parent = bindBtn
    
    bindButtons[funcName] = bindBtn
    
    bindBtn.MouseButton1Click:Connect(function()
        waitingForKey = funcName
        bindBtn.Text = "..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    end)
    
    return bindBtn
end

-- ===== ЗАПОЛНЕНИЕ ВКЛАДОК =====
local vContainer = tabContainers[1]
local espBtn = createToggleCard(vContainer, "ESP", false, toggleEsp)
local fbBtn = createToggleCard(vContainer, "FullBright", false, toggleFullbright)
local chamsBtn = createToggleCard(vContainer, "Chams", false, toggleChams)
local tracersBtn = createToggleCard(vContainer, "Tracers", false, toggleTracers)

local mContainer = tabContainers[2]
local flyBtn = createToggleCard(mContainer, "Fly", false, toggleFly)
local noclipBtn = createToggleCard(mContainer, "Noclip", false, toggleNoclip)
local jumpBtn = createToggleCard(mContainer, "Infinite Jump", false, toggleJump)
local speedBtn = createToggleCard(mContainer, "Speed", false, toggleSpeed)
local freezeBtn = createToggleCard(mContainer, "Freeze", false, toggleFreeze)
createSliderCard(mContainer, "Speed Multiplier", 1, 15, 5, function(v) speedMultiplier = v; if speedEnabled then toggleSpeed(true) end end)
createSliderCard(mContainer, "Fly Speed", 10, 200, 50, function(v) flySpeed = v end)

local cContainer = tabContainers[3]
local aimBtn = createToggleCard(cContainer, "Aimbot", false, toggleAimbot)
local trigBtn = createToggleCard(cContainer, "Triggerbot", false, toggleTriggerbot)

local oContainer = tabContainers[4]
local clickBtn = createToggleCard(oContainer, "AutoClicker", false, toggleAutoClicker)
createSliderCard(oContainer, "Click Interval (s)", 0.1, 5, 0.5, function(v) 
    clickInterval = v 
    if autoClicker then 
        toggleAutoClicker(false)
        toggleAutoClicker(true)
    end 
end)

local fContainer = tabContainers[5]
local spinBtn = createToggleCard(fContainer, "Spin", false, toggleSpin)
createSliderCard(fContainer, "Spin Speed", 0.1, 10, 1, function(v) spinSpeed = v end)
local bobbingBtn = createToggleCard(fContainer, "Bobbing", false, toggleBobbing)
createSliderCard(fContainer, "Bobbing Height", 0.5, 5, 2, function(v) bobbingHeight = v end)
local jitterBtn = createToggleCard(fContainer, "Jitter", false, toggleJitter)
createSliderCard(fContainer, "Jitter Strength", 0.1, 2, 0.5, function(v) jitterStrength = v end)
local flingBtn = createToggleCard(fContainer, "Fling", false, toggleFling)
createSliderCard(fContainer, "Fling Power", 10, 150, 50, function(v) flingPower = v end)
local invisibleBtn = createToggleCard(fContainer, "Invisible", false, toggleInvisible)

-- ===== GAMES TAB =====
local gContainer = tabContainers[6]

local gamesTitle = Instance.new("TextLabel")
gamesTitle.Size = UDim2.new(1, 0, 0, 30)
gamesTitle.BackgroundTransparency = 1
gamesTitle.Text = "=== GAME MODULES ==="
gamesTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
gamesTitle.TextScaled = true
gamesTitle.Font = Enum.Font.GothamBold
gamesTitle.Parent = gContainer

-- Под-вкладки
local subTabPanel = Instance.new("Frame")
subTabPanel.Size = UDim2.new(1, 0, 0, 40)
subTabPanel.BackgroundTransparency = 1
subTabPanel.Parent = gContainer

local subTabLayout = Instance.new("UIListLayout")
subTabLayout.FillDirection = Enum.FillDirection.Horizontal
subTabLayout.Padding = UDim.new(0, 8)
subTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
subTabLayout.Parent = subTabPanel

local subTabData = {
    {name = "Ninja Legends", index = 1},
    {name = "MM2", index = 2},
    {name = "Muscle Legends", index = 3}
}

local subTabButtons = {}
local subTabContainers = {}

local subContentArea = Instance.new("Frame")
subContentArea.Size = UDim2.new(1, 0, 1, -50)
subContentArea.Position = UDim2.new(0, 0, 0, 45)
subContentArea.BackgroundTransparency = 1
subContentArea.Parent = gContainer

for i, data in ipairs(subTabData) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 1, 0)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 80, 160) or Color3.fromRGB(20, 20, 40)
    btn.BackgroundTransparency = 0.3
    btn.Text = data.name
    btn.TextColor3 = (i == 1) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(180, 180, 220)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = subTabPanel
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    table.insert(subTabButtons, btn)
    
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 5
    container.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    container.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.Visible = (i == 1)
    container.Parent = subContentArea
    
    local subLayout = Instance.new("UIListLayout")
    subLayout.Padding = UDim.new(0, 6)
    subLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subLayout.Parent = container
    
    subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, subLayout.AbsoluteContentSize.Y + 10)
    end)
    
    subTabContainers[i] = container
    
    btn.MouseButton1Click:Connect(function()
        for idx, b in pairs(subTabButtons) do
            local isActive = (idx == i)
            b.BackgroundColor3 = isActive and Color3.fromRGB(0, 80, 160) or Color3.fromRGB(20, 20, 40)
            b.TextColor3 = isActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(180, 180, 220)
        end
        for idx, cont in pairs(subTabContainers) do
            cont.Visible = (idx == i)
        end
    end)
end

-- ===== NINJA LEGENDS =====
local ninjaContainer = subTabContainers[1]

-- ===== СОСТОЯНИЯ =====
local eggHackActive = false

-- ===== ФУНКЦИЯ ДЛЯ ВЗЛОМА ЯИЦ =====
local function openEggWithHack()
    pcall(function()
        -- 1. Пытаемся найти баланс Чи и временно увеличить
        local chiValue = nil
        local chiObject = nil
        
        -- Ищем Чи в разных местах
        local playerStats = Player:FindFirstChild("leaderstats")
        if playerStats then
            for _, child in pairs(playerStats:GetChildren()) do
                if child:IsA("NumberValue") and (string.find(child.Name, "Chi") or string.find(child.Name, "chi") or string.find(child.Name, "Energy")) then
                    chiObject = child
                    chiValue = child.Value
                    break
                end
            end
        end
        
        if not chiObject then
            -- Ищем в других местах
            for _, obj in pairs(Player:GetChildren()) do
                if obj:IsA("NumberValue") and (string.find(obj.Name, "Chi") or string.find(obj.Name, "chi") or string.find(obj.Name, "Energy") or string.find(obj.Name, "Balance")) then
                    chiObject = obj
                    chiValue = obj.Value
                    break
                end
            end
        end
        
        -- 2. Если нашли Чи - временно ставим 999999999
        if chiObject then
            chiObject.Value = 999999999
            task.wait(0.1)
        end
        
        -- 3. Ищем кнопку открытия яйца и кликаем
        local playerGui = Player:FindFirstChild("PlayerGui")
        if playerGui then
            for _, child in pairs(playerGui:GetDescendants()) do
                if child:IsA("TextButton") and (string.find(child.Name, "Egg") or string.find(child.Name, "Open") or string.find(child.Name, "Hatch") or string.find(child.Text, "Open") or string.find(child.Text, "Hatch")) then
                    if child.Visible then
                        child:Fire()
                        print("[Egg Hack] Opened egg via button: " .. child.Name)
                        task.wait(0.1)
                    end
                end
                -- Ищем ImageButton тоже
                if child:IsA("ImageButton") and (string.find(child.Name, "Egg") or string.find(child.Name, "Open") or string.find(child.Name, "Buy")) then
                    if child.Visible then
                        child:Fire()
                        print("[Egg Hack] Opened egg via ImageButton: " .. child.Name)
                        task.wait(0.1)
                    end
                end
            end
        end
        
        -- 4. Пытаемся через RemoteEvent
        local remote = ReplicatedStorage:FindFirstChild("OpenEgg") or 
                      ReplicatedStorage:FindFirstChild("HatchEgg") or
                      ReplicatedStorage:FindFirstChild("BuyEgg") or
                      ReplicatedStorage:FindFirstChild("PurchaseEgg") or
                      ReplicatedStorage:FindFirstChild("EggOpen")
        if remote then
            remote:FireServer()
            print("[Egg Hack] Fired RemoteEvent: " .. remote.Name)
            task.wait(0.1)
        end
        
        -- 5. Ищем ClickDetector на яйцах в Workspace
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and (string.find(obj.Name, "Egg") or string.find(obj.Name, "Chest")) then
                local click = obj:FindFirstChild("ClickDetector")
                if click then
                    click:Fire()
                    print("[Egg Hack] Clicked egg in workspace: " .. obj.Name)
                    task.wait(0.1)
                end
            end
        end
        
        -- 6. Возвращаем Чи обратно (если нашли)
        if chiObject and chiValue then
            task.wait(0.2)
            chiObject.Value = chiValue
        end
    end)
end

-- 1. DUPLICATE PETS
local dupCard = Instance.new("Frame")
dupCard.Size = UDim2.new(1, 0, 0, 42)
dupCard.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
dupCard.BackgroundTransparency = 0.3
dupCard.BorderSizePixel = 0
dupCard.Parent = ninjaContainer

local dupCardCorner = Instance.new("UICorner")
dupCardCorner.CornerRadius = UDim.new(0, 8)
dupCardCorner.Parent = dupCard

local dupCardStroke = Instance.new("UIStroke")
dupCardStroke.Color = Color3.fromRGB(30, 40, 80)
dupCardStroke.Thickness = 1.5
dupCardStroke.Transparency = 0.5
dupCardStroke.Parent = dupCard

local dupLabel = Instance.new("TextLabel")
dupLabel.Size = UDim2.new(0.65, 0, 1, 0)
dupLabel.Position = UDim2.new(0, 16, 0, 0)
dupLabel.BackgroundTransparency = 1
dupLabel.Text = "⚠️ DUPLICATE PETS"
dupLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
dupLabel.TextXAlignment = Enum.TextXAlignment.Left
dupLabel.TextScaled = true
dupLabel.Font = Enum.Font.Gotham
dupLabel.Parent = dupCard

local dupBtn = Instance.new("TextButton")
dupBtn.Size = UDim2.new(0, 70, 0, 30)
dupBtn.Position = UDim2.new(0.78, 0, 0.14, 0)
dupBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
dupBtn.Text = "OFF"
dupBtn.TextColor3 = Color3.new(1,1,1)
dupBtn.TextScaled = true
dupBtn.Font = Enum.Font.GothamBold
dupBtn.BorderSizePixel = 0
dupBtn.Parent = dupCard
dupBtn.AutoButtonColor = false

local dupBtnCorner = Instance.new("UICorner")
dupBtnCorner.CornerRadius = UDim.new(0, 6)
dupBtnCorner.Parent = dupBtn

dupBtn.MouseButton1Click:Connect(function()
    ninjaDuping = not ninjaDuping
    toggleNinjaDup(ninjaDuping)
    dupBtn.Text = ninjaDuping and "ON" or "OFF"
    dupBtn.BackgroundColor3 = ninjaDuping and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
end)

-- 2. Teleport All Islands
local islandBtn = Instance.new("TextButton")
islandBtn.Size = UDim2.new(1, 0, 0, 42)
islandBtn.Position = UDim2.new(0, 0, 0, 50)
islandBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
islandBtn.Text = "🏝️ TELEPORT ALL ISLANDS"
islandBtn.TextColor3 = Color3.new(1,1,1)
islandBtn.TextScaled = true
islandBtn.Font = Enum.Font.GothamBold
islandBtn.BorderSizePixel = 0
islandBtn.Parent = ninjaContainer
islandBtn.AutoButtonColor = false
local islandBtnCorner = Instance.new("UICorner")
islandBtnCorner.CornerRadius = UDim.new(0, 8)
islandBtnCorner.Parent = islandBtn

islandBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local islands = {}
        local islandFolder = Workspace:FindFirstChild("islandUnlockParts")
        if islandFolder then
            for _, part in pairs(islandFolder:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(islands, part)
                end
            end
        else
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and (string.find(obj.Name, "Island") or string.find(obj.Name, "Zone")) then
                    local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Part") or obj:FindFirstChild("BasePart")
                    if part then
                        table.insert(islands, part)
                    end
                end
            end
        end
        
        table.sort(islands, function(a, b)
            return a.Position.Y < b.Position.Y
        end)
        
        for i, part in ipairs(islands) do
            if part and part.Position then
                RootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                task.wait(0.3)
            end
        end
    end)
    islandBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    task.wait(0.5)
    islandBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
end)

-- 3. Auto Collect All
local collectBtn = Instance.new("TextButton")
collectBtn.Size = UDim2.new(1, 0, 0, 42)
collectBtn.Position = UDim2.new(0, 0, 0, 100)
collectBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
collectBtn.Text = "📦 AUTO COLLECT ALL"
collectBtn.TextColor3 = Color3.new(1,1,1)
collectBtn.TextScaled = true
collectBtn.Font = Enum.Font.GothamBold
collectBtn.BorderSizePixel = 0
collectBtn.Parent = ninjaContainer
collectBtn.AutoButtonColor = false
local collectBtnCorner = Instance.new("UICorner")
collectBtnCorner.CornerRadius = UDim.new(0, 8)
collectBtnCorner.Parent = collectBtn

collectBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and (string.find(obj.Name, "Soul") or string.find(obj.Name, "Chi") or string.find(obj.Name, "Karma") or string.find(obj.Name, "Chest") or string.find(obj.Name, "Crate")) then
                RootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                task.wait(0.15)
                local detector = obj:FindFirstChild("ClickDetector")
                if detector then
                    detector:Fire()
                    task.wait(0.1)
                end
            end
        end
    end)
    collectBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    task.wait(0.5)
    collectBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
end)

-- 4. 🥚 EGG HACK (включается/выключается)
local eggCard = Instance.new("Frame")
eggCard.Size = UDim2.new(1, 0, 0, 42)
eggCard.Position = UDim2.new(0, 0, 0, 150)
eggCard.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
eggCard.BackgroundTransparency = 0.3
eggCard.BorderSizePixel = 0
eggCard.Parent = ninjaContainer

local eggCardCorner = Instance.new("UICorner")
eggCardCorner.CornerRadius = UDim.new(0, 8)
eggCardCorner.Parent = eggCard

local eggCardStroke = Instance.new("UIStroke")
eggCardStroke.Color = Color3.fromRGB(30, 40, 80)
eggCardStroke.Thickness = 1.5
eggCardStroke.Transparency = 0.5
eggCardStroke.Parent = eggCard

local eggLabel = Instance.new("TextLabel")
eggLabel.Size = UDim2.new(0.65, 0, 1, 0)
eggLabel.Position = UDim2.new(0, 16, 0, 0)
eggLabel.BackgroundTransparency = 1
eggLabel.Text = "🥚 EGG HACK (Press E)"
eggLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
eggLabel.TextXAlignment = Enum.TextXAlignment.Left
eggLabel.TextScaled = true
eggLabel.Font = Enum.Font.Gotham
eggLabel.Parent = eggCard

local eggBtn = Instance.new("TextButton")
eggBtn.Size = UDim2.new(0, 70, 0, 30)
eggBtn.Position = UDim2.new(0.78, 0, 0.14, 0)
eggBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
eggBtn.Text = "OFF"
eggBtn.TextColor3 = Color3.new(1,1,1)
eggBtn.TextScaled = true
eggBtn.Font = Enum.Font.GothamBold
eggBtn.BorderSizePixel = 0
eggBtn.Parent = eggCard
eggBtn.AutoButtonColor = false

local eggBtnCorner = Instance.new("UICorner")
eggBtnCorner.CornerRadius = UDim.new(0, 6)
eggBtnCorner.Parent = eggBtn

eggBtn.MouseButton1Click:Connect(function()
    eggHackActive = not eggHackActive
    eggBtn.Text = eggHackActive and "ON" or "OFF"
    eggBtn.BackgroundColor3 = eggHackActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
    print("Egg Hack: " .. (eggHackActive and "ACTIVE" or "DISABLED"))
end)

-- ===== MM2 =====
local mm2Container = subTabContainers[2]

local mm2GunBtn = createToggleCard(mm2Container, "TP to Gun", false, function(state)
    toggleMM2TeleportToGun(state)
end)

local mm2MurdererBtn = createToggleCard(mm2Container, "TP to Murderer", false, function(state)
    toggleMM2TeleportToMurderer(state)
end)

local mm2EspBtn = createToggleCard(mm2Container, "Role ESP", false, function(state)
    toggleMM2RoleESP(state)
end)

-- ===== MUSCLE LEGENDS =====
local muscleContainer = subTabContainers[3]

local walkBtn = createToggleCard(muscleContainer, "Auto Walk (Treadmill)", false, function(state)
    toggleMuscleAutoWalk(state)
end)

local clickBtn = createToggleCard(muscleContainer, "Auto Click Machines", false, function(state)
    toggleMuscleAutoClick(state)
end)

local dupeBtn = createToggleCard(muscleContainer, "⚠️ DUPE PETS (RISK)", false, function(state)
    toggleMusclePetDupe(state)
end)

-- ===== BINDS TAB =====
local bContainer = tabContainers[7]
createBindCard(bContainer, "fly", "Fly")
createBindCard(bContainer, "noclip", "Noclip")
createBindCard(bContainer, "jump", "Infinite Jump")
createBindCard(bContainer, "speed", "Speed")
createBindCard(bContainer, "autoclicker", "AutoClicker")
createBindCard(bContainer, "aimbot", "Aimbot")
createBindCard(bContainer, "triggerbot", "Triggerbot")
createBindCard(bContainer, "esp", "ESP")
createBindCard(bContainer, "fullbright", "FullBright")
createBindCard(bContainer, "chams", "Chams")
createBindCard(bContainer, "tracers", "Tracers")
createBindCard(bContainer, "freeze", "Freeze")
createBindCard(bContainer, "spin", "Spin")
createBindCard(bContainer, "bobbing", "Bobbing")
createBindCard(bContainer, "jitter", "Jitter")
createBindCard(bContainer, "fling", "Fling")
createBindCard(bContainer, "invisible", "Invisible")

-- ===== ОБРАБОТЧИК БИНДОВ =====
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if waitingForKey then
        if input.KeyCode == Enum.KeyCode.Backspace then
            binds[waitingForKey].key = nil
            local btn = bindButtons[waitingForKey]
            if btn then
                btn.Text = "None"
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            waitingForKey = nil
        elseif input.KeyCode ~= Enum.KeyCode.Unknown then
            binds[waitingForKey].key = input.KeyCode
            updateBindButton(waitingForKey)
            local btn = bindButtons[waitingForKey]
            if btn then
                btn.Text = input.KeyCode.Name
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
            end
            waitingForKey = nil
        end
        return
    end
    
    if input.KeyCode == Enum.KeyCode.Backspace then
        menuOpen = not menuOpen
        mainFrame.Visible = menuOpen
        return
    end
    
    for funcName, bind in pairs(binds) do
        if bind.key and input.KeyCode == bind.key then
            if funcName == "fly" then
                local newState = not flyEnabled
                toggleFly(newState)
                flyBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                flyBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "noclip" then
                local newState = not noclipEnabled
                toggleNoclip(newState)
                noclipBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                noclipBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "jump" then
                local newState = not infiniteJump
                toggleJump(newState)
                jumpBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                jumpBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "speed" then
                local newState = not speedEnabled
                toggleSpeed(newState)
                speedBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                speedBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "autoclicker" then
                local newState = not autoClicker
                toggleAutoClicker(newState)
                clickBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                clickBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "aimbot" then
                local newState = not aimbotEnabled
                toggleAimbot(newState)
                aimBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                aimBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "triggerbot" then
                local newState = not triggerbotEnabled
                toggleTriggerbot(newState)
                trigBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                trigBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "esp" then
                local newState = not espEnabled
                toggleEsp(newState)
                espBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                espBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "fullbright" then
                local newState = not fullbrightEnabled
                toggleFullbright(newState)
                fbBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                fbBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "chams" then
                local newState = not chamsEnabled
                toggleChams(newState)
                chamsBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                chamsBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "tracers" then
                local newState = not tracersEnabled
                toggleTracers(newState)
                tracersBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                tracersBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "freeze" then
                local newState = not freezeEnabled
                toggleFreeze(newState)
                freezeBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                freezeBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "spin" then
                local newState = not spinEnabled
                toggleSpin(newState)
                spinBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                spinBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "bobbing" then
                local newState = not bobbingEnabled
                toggleBobbing(newState)
                bobbingBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                bobbingBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "jitter" then
                local newState = not jitterEnabled
                toggleJitter(newState)
                jitterBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                jitterBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "fling" then
                local newState = not flingEnabled
                toggleFling(newState)
                flingBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                flingBtn.Text = newState and "ON" or "OFF"
            elseif funcName == "invisible" then
                local newState = not invisibleEnabled
                toggleInvisible(newState)
                invisibleBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 70)
                invisibleBtn.Text = newState and "ON" or "OFF"
            end
        end
    end
end)

-- ===== КОЛЕСО МЫШИ =====
UserInputService.InputChanged:Connect(function(input, gp)
    if gp or not flyEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        flySpeed = math.clamp(flySpeed + input.Position.Z * 5, 10, 200)
    end
end)

-- ===== АНИМАЦИЯ =====
RunService.Heartbeat:Connect(function()
    pulseAnimation()
end)

-- ===== ПЕРЕРОЖДЕНИЕ =====
Player.CharacterAdded:Connect(function(newChar)
    Char = newChar
    Humanoid = Char:WaitForChild("Humanoid")
    RootPart = Char:WaitForChild("HumanoidRootPart")
    baseWalkSpeed = Humanoid.WalkSpeed
    baseJumpPower = Humanoid.JumpPower
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if freezeConn then freezeConn:Disconnect() freezeConn = nil end
    if freezeBodyPos then freezeBodyPos:Destroy() freezeBodyPos = nil end
    if flyEnabled then toggleFly(true) end
    if noclipEnabled then 
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        toggleNoclip(true)
    end
    if infiniteJump then toggleJump(true) end
    if speedEnabled then toggleSpeed(true) end
    if freezeEnabled then toggleFreeze(true) end
    if invisibleEnabled then toggleInvisible(true) end
end)

print("APEX CHEAT V19.4 LOADED | NINJA LEGENDS FIXED | CREDITS: Apex + SWILL")
