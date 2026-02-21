-- ========================================
-- AMPED FIVEM MENU FRAMEWORK EXAMPLE
-- ========================================
-- This file demonstrates ALL available features of the FiveM Menu Framework
-- Uses DUI (Direct UI) for optimal performance and integration
-- Includes: Playerlist, Theme Switcher, All Menu Types, Notifications, and more!
local dui = nil
local duiTexture = nil
local duiTxd = nil
local activeMenu = {}
local activeIndex = 1
local originalMenu = {}

local keyMap = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["F11"] = 288, ["F12"] = 289,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["0"] = 157, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["I"] = 303, ["O"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["J"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["/"] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178, ["INSERT"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

-- Menu state tracking
local menuInitialized = false
local keybindSetup = false
local menuOpenKey = 11 -- Default to Page Down

-- DUI texture names
local txdName = "ReplixMenuTxd"
local txtName = "ReplixMenuTex"


-- Available themes
local availableThemes = {
    "purple", "blue", "orange", "pink"
}

-- Current theme index
local currentThemeIndex = 1

-- Special function for input that records all key presses
local function startInputRecording(question, placeholder, maxLength, inputType, callback)
    if not dui then return end
    
    _G.inputRecordingActive = true
    _G.inputBuffer = ""
    _G.inputMaxLength = maxLength or 100
    _G.inputCallback = callback -- Store callback for when input is submitted
    
    SendDuiMessage(dui, json.encode({
        action = 'openTextInput',
        question = question or 'Enter text:',
        placeholder = placeholder or 'Type here...',
        maxLength = _G.inputMaxLength,
        inputType = inputType or 'general'
    }))
    
    print("Lua: Input recording started")
end

-- Generic input prompt function for any menu item
local function promptInput(question, placeholder, maxLength, inputType, callback)
    startInputRecording(question, placeholder, maxLength, inputType, callback)
end

-- Function to stop input recording and re-enable controls
local function stopInputRecording()
    _G.inputRecordingActive = false
    print("Lua: Input recording stopped")
end

-- Keybind setup function
local function setupKeybind()
    if not keybindSetup and dui then
        keybindSetup = true
        _G.keybindSetupActive = true
        
        -- Close the menu first
        SendDuiMessage(dui, json.encode({
            action = 'setMenuVisible',
            visible = false
        }))
        _G.clientMenuShowing = false
        
        -- Then open key selection
        SendDuiMessage(dui, json.encode({
            action = 'openKeySelection',
            title = 'Menu Keybind Setup',
            instruction = 'Press any key to set as the menu open key',
            hint = 'ESC to use default (Page Down)'
        }))
        print("Lua: Keybind setup activated")
    else
        print("Lua: Keybind setup already active or DUI not available")
    end
end

-- FiveM Client-Side Menu Framework

-- Vehicle Spawn Function
function spawnVehicle(modelName)
    local model = GetHashKey(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
    
    -- Apply spawn settings
    if _G.spawnInVehicle then
        SetPedIntoVehicle(playerPed, vehicle, -1)
    end
    
    if _G.maxOutOnSpawn then
        maxOutVehicle(vehicle)
    end
    
    if _G.easyHandlingOnSpawn then
        applyEasyHandling(vehicle)
    end
    
    if _G.godModeOnSpawn then
        SetEntityInvincible(vehicle, true)
        SetVehicleCanBeVisiblyDamaged(vehicle, false)
        SetVehicleCanBreak(vehicle, false)
    end
    
    SetModelAsNoLongerNeeded(model)
    
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
        message = "Spawned: <span class=\"notification-key\">" .. modelName .. "</span>",
                                    type = 'success'
                                }))
end

-- Max Out Vehicle Function
function maxOutVehicle(vehicle)
    SetVehicleModKit(vehicle, 0)
    SetVehicleMod(vehicle, 11, GetNumVehicleMods(vehicle, 11) - 1, false) -- Engine
    SetVehicleMod(vehicle, 12, GetNumVehicleMods(vehicle, 12) - 1, false) -- Brakes
    SetVehicleMod(vehicle, 13, GetNumVehicleMods(vehicle, 13) - 1, false) -- Transmission
    SetVehicleMod(vehicle, 15, GetNumVehicleMods(vehicle, 15) - 1, false) -- Suspension
    SetVehicleMod(vehicle, 16, GetNumVehicleMods(vehicle, 16) - 1, false) -- Armor
    ToggleVehicleMod(vehicle, 18, true) -- Turbo
    SetVehicleMod(vehicle, 23, GetNumVehicleMods(vehicle, 23) - 1, false) -- Front Wheels
    SetVehicleMod(vehicle, 24, GetNumVehicleMods(vehicle, 24) - 1, false) -- Back Wheels
end

-- Easy Handling Function
function applyEasyHandling(vehicle)
    SetVehicleModKit(vehicle, 0)
    SetVehicleMod(vehicle, 15, GetNumVehicleMods(vehicle, 15) - 1, false) -- Max Suspension
    SetVehicleMod(vehicle, 12, GetNumVehicleMods(vehicle, 12) - 1, false) -- Max Brakes
    
    -- Set handling values for better control
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fMass", 1000.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff", 10.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDownforceModifier", 0.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fCentreOfMassOffset", 0.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInertiaMultiplier", 1.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", 0.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveGears", 6.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", 0.5)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", 1.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift", 2.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleDownShift", 2.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", 200.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", 1.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeBiasFront", 0.5)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", 1.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSteeringLock", 35.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", 2.5)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 2.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveLateral", 22.5)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionSpringDeltaMax", 0.15)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 1.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fCamberStiffnesss", 0.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionBiasFront", 0.5)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", 1.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionForce", 2.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionDamping", 1.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionUpperLimit", 0.1)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionLowerLimit", -0.15)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionRaise", 0.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionBiasFront", 0.5)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarForce", 0.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarBiasFront", 0.5)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightFront", 0.0)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightRear", 0.0)
end

-- Helper function to create dynamic vehicle mod sliders
function createVehicleModSlider(label, icon, modType)
    return {
        label = label,
        type = 'slider',
        icon = icon,
        min = -1,
        max = 10,
        value = -1,
        step = 1,
        onConfirm = function(val)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= 0 then
                SetVehicleModKit(vehicle, 0)
                local maxMods = GetNumVehicleMods(vehicle, modType) - 1
                
                -- Clamp the value to valid range
                if val > maxMods then 
                    val = maxMods
                elseif val < -1 then
                    val = -1
                end
                
                -- Apply the mod
                SetVehicleMod(vehicle, modType, val, false)
                
                -- Get current mod for display
                local currentMod = GetVehicleMod(vehicle, modType)
                local modName = currentMod == -1 and "Stock" or "Style " .. (currentMod + 1)
                
                SendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = label .. ": <span class=\"notification-key\">" .. modName .. "</span> (" .. (maxMods + 1) .. " options)",
                    type = 'success'
                }))
            else
                SendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "You must be in a vehicle!",
                    type = 'error'
                }))
            end
        end
    }
end

-- Alternative: Create vehicle mod sliders with proper max values from the start
function createSmartVehicleModSlider(label, icon, modType)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local maxMods = 10 -- Default fallback
    
    if vehicle ~= 0 then
        SetVehicleModKit(vehicle, 0)
        maxMods = GetNumVehicleMods(vehicle, modType) - 1
    end
    
    return {
        label = label,
        type = 'slider',
        icon = icon,
        min = -1,
        max = maxMods,
        value = -1,
        step = 1,
        onConfirm = function(val)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= 0 then
                SetVehicleModKit(vehicle, 0)
                local currentMaxMods = GetNumVehicleMods(vehicle, modType) - 1
                
                -- Clamp the value to valid range
                if val > currentMaxMods then 
                    val = currentMaxMods
                elseif val < -1 then
                    val = -1
                end
                
                -- Apply the mod
                SetVehicleMod(vehicle, modType, val, false)
                
                -- Get current mod for display
                local currentMod = GetVehicleMod(vehicle, modType)
                local modName = currentMod == -1 and "Stock" or "Style " .. (currentMod + 1)
                
                SendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = label .. ": <span class=\"notification-key\">" .. modName .. "</span> (" .. (currentMaxMods + 1) .. " options)",
                    type = 'success'
                }))
            else
                SendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "You must be in a vehicle!",
                    type = 'error'
                }))
            end
        end
    }
end

-- Weapon name lookup function
local function getWeaponName(weaponHash)
    local weaponNames = {
        [GetHashKey("WEAPON_RAILGUN")] = "Railgun",
        [GetHashKey("WEAPON_ASSAULTSHOTGUN")] = "Assault Shotgun",
        [GetHashKey("WEAPON_SMG")] = "SMG",
        [GetHashKey("WEAPON_FIREWORK")] = "Firework Launcher",
        [GetHashKey("WEAPON_MOLOTOV")] = "Molotov Cocktail",
        [GetHashKey("WEAPON_APPISTOL")] = "AP Pistol",
        [GetHashKey("WEAPON_STUNGUN")] = "Stun Gun",
        [GetHashKey("WEAPON_ASSAULTRIFLE")] = "Assault Rifle",
        [GetHashKey("WEAPON_ASSAULTRIFLE_MK2")] = "Assault Rifle MK2",
        [GetHashKey("WEAPON_ASSAULTSMG")] = "Assault SMG",
        [GetHashKey("WEAPON_AUTOSHOTGUN")] = "Auto Shotgun",
        [GetHashKey("WEAPON_BULLPUPRIFLE")] = "Bullpup Rifle",
        [GetHashKey("WEAPON_BULLPUPRIFLE_MK2")] = "Bullpup Rifle MK2",
        [GetHashKey("WEAPON_BULLPUPSHOTGUN")] = "Bullpup Shotgun",
        [GetHashKey("WEAPON_BZGAS")] = "BZ Gas",
        [GetHashKey("WEAPON_CARBINERIFLE")] = "Carbine Rifle",
        [GetHashKey("WEAPON_CARBINERIFLE_MK2")] = "Carbine Rifle MK2",
        [GetHashKey("WEAPON_COMBATMG")] = "Combat MG",
        [GetHashKey("WEAPON_COMBATMG_MK2")] = "Combat MG MK2",
        [GetHashKey("WEAPON_COMBATPDW")] = "Combat PDW",
        [GetHashKey("WEAPON_COMBATPISTOL")] = "Combat Pistol",
        [GetHashKey("WEAPON_COMPACTLAUNCHER")] = "Compact Launcher",
        [GetHashKey("WEAPON_COMPACTRIFLE")] = "Compact Rifle",
        [GetHashKey("WEAPON_DBSHOTGUN")] = "Double Barrel Shotgun",
        [GetHashKey("WEAPON_DOUBLEACTION")] = "Double Action Revolver",
        [GetHashKey("WEAPON_FIREEXTINGUISHER")] = "Fire Extinguisher",
        [GetHashKey("WEAPON_FLARE")] = "Flare",
        [GetHashKey("WEAPON_FLAREGUN")] = "Flare Gun",
        [GetHashKey("WEAPON_GRENADE")] = "Grenade",
        [GetHashKey("WEAPON_GUSENBERG")] = "Gusenberg Sweeper",
        [GetHashKey("WEAPON_HEAVYPISTOL")] = "Heavy Pistol",
        [GetHashKey("WEAPON_HEAVYSHOTGUN")] = "Heavy Shotgun",
        [GetHashKey("WEAPON_HEAVYSNIPER")] = "Heavy Sniper",
        [GetHashKey("WEAPON_HEAVYSNIPER_MK2")] = "Heavy Sniper MK2",
        [GetHashKey("WEAPON_HOMINGLAUNCHER")] = "Homing Launcher",
        [GetHashKey("WEAPON_MACHINEPISTOL")] = "Machine Pistol",
        [GetHashKey("WEAPON_MARKSMANPISTOL")] = "Marksman Pistol",
        [GetHashKey("WEAPON_MARKSMANRIFLE")] = "Marksman Rifle",
        [GetHashKey("WEAPON_MARKSMANRIFLE_MK2")] = "Marksman Rifle MK2",
        [GetHashKey("WEAPON_MG")] = "MG",
        [GetHashKey("WEAPON_MICROSMG")] = "Micro SMG",
        [GetHashKey("WEAPON_MINIGUN")] = "Minigun",
        [GetHashKey("WEAPON_MINISMG")] = "Mini SMG",
        [GetHashKey("WEAPON_MUSKET")] = "Musket",
        [GetHashKey("WEAPON_NAVYREVOLVER")] = "Navy Revolver",
        [GetHashKey("WEAPON_PIPEBOMB")] = "Pipe Bomb",
        [GetHashKey("WEAPON_PISTOL")] = "Pistol",
        [GetHashKey("WEAPON_PISTOL50")] = "Pistol .50",
        [GetHashKey("WEAPON_PISTOL_MK2")] = "Pistol MK2",
        [GetHashKey("WEAPON_POOLCUE")] = "Pool Cue",
        [GetHashKey("WEAPON_PROXMINE")] = "Proximity Mine",
        [GetHashKey("WEAPON_PUMPSHOTGUN")] = "Pump Shotgun",
        [GetHashKey("WEAPON_PUMPSHOTGUN_MK2")] = "Pump Shotgun MK2",
        [GetHashKey("WEAPON_RAYCARBINE")] = "Ray Carbine",
        [GetHashKey("WEAPON_RAYMINIGUN")] = "Ray Minigun",
        [GetHashKey("WEAPON_RAYPISTOL")] = "Ray Pistol",
        [GetHashKey("WEAPON_REVOLVER")] = "Revolver",
        [GetHashKey("WEAPON_REVOLVER_MK2")] = "Revolver MK2",
        [GetHashKey("WEAPON_SAWNOFFSHOTGUN")] = "Sawed-Off Shotgun",
        [GetHashKey("WEAPON_RPG")] = "RPG",
        [GetHashKey("WEAPON_SMG_MK2")] = "SMG MK2",
        [GetHashKey("WEAPON_SMOKEGRENADE")] = "Smoke Grenade",
        [GetHashKey("WEAPON_SNIPERRIFLE")] = "Sniper Rifle",
        [GetHashKey("WEAPON_SNOWBALL")] = "Snowball",
        [GetHashKey("WEAPON_SNSPISTOL")] = "SNS Pistol",
        [GetHashKey("WEAPON_SNSPISTOL_MK2")] = "SNS Pistol MK2",
        [GetHashKey("WEAPON_SPECIALCARBINE")] = "Special Carbine",
        [GetHashKey("WEAPON_SPECIALCARBINE_MK2")] = "Special Carbine MK2",
        [GetHashKey("WEAPON_STICKYBOMB")] = "Sticky Bomb",
        [GetHashKey("WEAPON_VINTAGEPISTOL")] = "Vintage Pistol"
    }
    
    return weaponNames[weaponHash] or "Unknown Weapon"
end

-- Get Players function (from replix_main.lua)
function GetPlayers()
    local players = {}

    for i = 0, 999 do
        if IsPedAPlayer(GetPlayerPed(i)) then
            table.insert(players, i)
        end
    end

    -- check if player is double
    for i = 1, #players do
        for j = 1, #players do
            if i ~= j then
                if GetPlayerServerId(players[i]) == GetPlayerServerId(players[j]) then
                    table.remove(players, j)
                end
            end
        end
    end

    return players
end

-- Network control function (from replix_main.lua)
local function RequestNetworkControl(Request)
    local hasControl = false
    while hasControl == false do
        hasControl = NetworkRequestControlOfEntity(Request)
        if hasControl == true or hasControl == 1 then
            break
        end
        if
            NetworkHasControlOfEntity(Request) == true and hasControl == true or
                NetworkHasControlOfEntity(Request) == true and hasControl == 1
         then
            return true
        else
            return false
        end
    end
end

-- Make ped hostile function (from replix_main.lua)
local function makePedHostile(target, ped, swat, clone)
    if swat == 1 or swat == true then
        RequestNetworkControl(ped)
        TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
        SetPedCanSwitchWeapon(ped, true)
    else
        if clone == 1 or clone == true then
            local Hash = GetEntityModel(ped)
            if DoesEntityExist(ped) then
                DeletePed(ped)
                RequestModel(Hash)
                local coords = GetEntityCoords(GetPlayerPed(target), true)
                if HasModelLoaded(Hash) then
                    local newPed = CreatePed(21, Hash, coords.x, coords.y, coords.z, 0, 1, 0)
                    if GetEntityHealth(newPed) == GetEntityMaxHealth(newPed) then
                        SetModelAsNoLongerNeeded(Hash)
                        RequestNetworkControl(newPed)
                        TaskCombatPed(newPed, GetPlayerPed(target), 0, 16)
                        SetPedCanSwitchWeapon(ped, true)
                    end
                end
            end
        else
            local TargetHandle = GetPlayerPed(target)
            RequestNetworkControl(ped)
            TaskCombatPed(ped, TargetHandle, 0, 16)
        end
    end
end

-- Player Info Functions (improved from replix_main.lua)
function getPlayerRealTimeData(localId)
    if not localId then return nil end
    
    local playerPed = GetPlayerPed(localId)
    if not playerPed or playerPed == 0 then return nil end
    
    -- Get current weapon
    local currentWeapon = "None"
    local weaponHash = GetSelectedPedWeapon(playerPed)
    if weaponHash ~= GetHashKey("WEAPON_UNARMED") then
        currentWeapon = getWeaponName(weaponHash)
    end
    
    -- Get vehicle info
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleName = "NONE"
    local speed = "0"
    local isInVehicle = false
    if vehicle ~= 0 then
        isInVehicle = true
        vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        local speedMs = GetEntitySpeed(vehicle)
        speed = math.floor(speedMs * 3.6) .. " km/h" -- Convert m/s to km/h
    end
    
    -- Get distance from local player
    local playerCoords = GetEntityCoords(playerPed)
    local localPlayerCoords = GetEntityCoords(PlayerPedId())
    local distance = math.floor(GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, localPlayerCoords.x, localPlayerCoords.y, localPlayerCoords.z, true))
    
    -- Get player ping safely
    local playerPing = 0
    if GetPlayerPing then
        playerPing = GetPlayerPing(localId)
    else
        playerPing = math.random(30, 150) -- Fallback to random ping
    end
    
    -- Check if player is alive
    local isAlive = GetEntityHealth(playerPed) > 0
    
    return {
        health = GetEntityHealth(playerPed),
        armor = GetPedArmour(playerPed),
        weapon = currentWeapon,
        isInVehicle = isInVehicle,
        vehicleName = vehicleName,
        speed = speed,
        distance = distance .. ".0",
        isAlive = isAlive,
        ping = playerPing
    }
end

-- Function to get real player data (from replix_main.lua)
local function getRealPlayerData()
    local players = {}
    local playerList = GetPlayers()
    
    for i = 1, #playerList do
        local currPlayer = playerList[i]
        local playerPed = GetPlayerPed(currPlayer)
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Get player ping safely
        local playerPing = 0
        if GetPlayerPing then
            playerPing = GetPlayerPing(currPlayer)
        else
            playerPing = math.random(30, 150) -- Fallback to random ping
        end
        
        -- Get additional player data
        local playerCoords = GetEntityCoords(playerPed)
        local localPlayerCoords = GetEntityCoords(PlayerPedId())
        local distance = math.floor(GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, localPlayerCoords.x, localPlayerCoords.y, localPlayerCoords.z, true))
        
        -- Get current weapon
        local currentWeapon = "None"
        local weaponHash = GetSelectedPedWeapon(playerPed)
        if weaponHash ~= GetHashKey("WEAPON_UNARMED") then
            currentWeapon = getWeaponName(weaponHash)
        end
        
        -- Get vehicle info
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleName = "None"
        local speed = "0 km/h"
        local isInVehicle = false
        if vehicle ~= 0 then
            isInVehicle = true
            vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            local speedMs = GetEntitySpeed(vehicle)
            speed = math.floor(speedMs * 3.6) -- Convert m/s to km/h
        end
        
        -- Check if player is alive
        local isAlive = GetEntityHealth(playerPed) > 0
        
        table.insert(players, {
            id = GetPlayerServerId(currPlayer),
            name = GetPlayerName(currPlayer),
            localId = currPlayer, -- Local player ID
            ping = playerPing,
            health = GetEntityHealth(playerPed),
            armor = GetPedArmour(playerPed),
            weapon = currentWeapon,
            isInVehicle = isInVehicle,
            vehicleName = vehicleName,
            speed = speed .. " km/h",
            distance = distance .. ".0",
            isAlive = isAlive,
        })
    end
    
    return players
end

-- Function to create individual player submenu (from replix_main.lua)
local function createPlayerSubmenu(playerData)
    return {
        {
            label = "Spectate Player",
            type = 'checkbox',
            icon = 'fas fa-eye',
            onConfirm = function(setToggle)
                if setToggle then
                    TriggerEvent('txcl:spectate:start', playerData.id, GetEntityCoords(GetPlayerPed(playerData.localId)))
                else
                    TriggerEvent('txcl:spectate:stop')
                end
            end
        },
        {
            label = "Teleport to Player",
                        type = 'button',
            icon = 'fas fa-map-marker-alt',
                        onConfirm = function() 
                            if dui then
                    SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(playerData.localId)))
                    SetEntityHeading(PlayerPedId(), GetEntityHeading(GetPlayerPed(playerData.localId)))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                        message = "Teleporting to " .. playerData.name,
                        type = 'info'
                                }))
                            end
                        end 
                    },
                    { 
            label = "Kill Player",
                        type = 'button',
            icon = 'fas fa-skull',
                        onConfirm = function() 
                            if dui then
                    local playerPed = GetPlayerPed(playerData.localId)
                    if playerPed and playerPed ~= 0 then
                        SetEntityHealth(playerPed, 0)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                            message = "Killed " .. playerData.name,
                                    type = 'success'
                                }))
                    end
                            end
                        end 
                    },
                    { 
            label = "Heal Player",
                        type = 'button',
            icon = 'fas fa-heart',
                        onConfirm = function() 
                            if dui then
                    local playerPed = GetPlayerPed(playerData.localId)
                    if playerPed and playerPed ~= 0 then
                        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
                        SetPedArmour(playerPed, 100)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                            message = "Healed " .. playerData.name,
                                    type = 'success'
                                }))
                            end
                        end 
                        end
                    },
                    {
            label = "Give Weapon",
            type = 'scroll',
            icon = 'fas fa-gun',
            options = {
                {label = 'Pistol', value = 'weapon_pistol'},
                {label = 'Assault Rifle', value = 'weapon_assaultrifle'},
                {label = 'SMG', value = 'weapon_smg'},
                {label = 'Shotgun', value = 'weapon_shotgun'},
                {label = 'Sniper Rifle', value = 'weapon_sniperrifle'},
                {label = 'RPG', value = 'weapon_rpg'},
                {label = 'Minigun', value = 'weapon_minigun'}
            },
            selected = 1,
            onConfirm = function(option)
                if dui then
                    local playerPed = GetPlayerPed(playerData.localId)
                    if playerPed and playerPed ~= 0 then
                        local weaponHash = GetHashKey(option.value)
                        GiveWeaponToPed(playerPed, weaponHash, 250, false, true)
                        SendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Gave " .. option.label .. " to " .. playerData.name,
                            type = 'success'
                        }))
                    end
                end
                        end
                    },
                    {
            label = "Remove All Weapons",
            type = 'button',
            icon = 'fas fa-trash',
                        onConfirm = function()
                if dui then
                    local playerPed = GetPlayerPed(playerData.localId)
                    if playerPed and playerPed ~= 0 then
                        RemoveAllPedWeapons(playerPed, true)
                        SendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Removed weapons from " .. playerData.name,
                            type = 'success'
                        }))
                    end
                end
                        end
                    },
                    {
            label = "Bring Player",
                        type = 'button',
            icon = 'fas fa-hand-paper',
                        onConfirm = function()
                                if dui then
                    local playerPed = GetPlayerPed(playerData.localId)
                    if playerPed and playerPed ~= 0 then
                        local coords = GetEntityCoords(PlayerPedId())
                        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                            message = "Brought " .. playerData.name,
                                        type = 'success'
                                    }))
                                end
                end
                        end
                    },
                    {
            label = "Crash Exploit 1",
            type = "button",
            icon = "fas fa-wifi-slash",
                        onConfirm = function()
                local currPlayer = playerData.localId
                for i = 0, 32 do
                    local coords = GetEntityCoords(GetPlayerPed(currPlayer))
                    RequestModel(GetHashKey('ig_wade'))
                    Citizen.Wait(50)
                    if HasModelLoaded(GetHashKey('ig_wade')) then
                        local ped = CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                        if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(currPlayer)) then
                            RequestNetworkControl(ped)
                            GiveWeaponToPed(ped, GetHashKey('WEAPON_RPG'), 9999, 1, 1)
                            SetPedCanSwitchWeapon(ped, true)
                            makePedHostile(ped, currPlayer, 0, 0)
                            TaskCombatPed(ped, GetPlayerPed(currPlayer), 0, 16)
                        elseif IsEntityDead(GetPlayerPed(currPlayer)) then
                            TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                        else
                            Citizen.Wait(10)
                        end
                    else
                        Citizen.Wait(10)
                    end
                end
                                        if dui then
                                            SendDuiMessage(dui, json.encode({
                                                action = 'notify',
                        message = "crashed ".. playerData.name,
                                                type = 'success'
                                            }))
                                        end
            end
        },
        {
            label = "Crash Exploit 2",
            type = "button",
            icon = "fas fa-wifi-slash",
            onConfirm = function() 
                local currPlayer = playerData.localId
                for i = 0, 32 do
                    local coords = GetEntityCoords(GetPlayerPed(currPlayer))
                    RequestModel(GetHashKey('mp_m_freemode_01'))
                    Citizen.Wait(50)
                    if HasModelLoaded(GetHashKey('mp_m_freemode_01')) then
                        local ped = CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(currPlayer)) then
                            RequestNetworkControl(ped)
                            GiveWeaponToPed(ped, GetHashKey('WEAPON_RPG'), 9999, 1, 1)
                            SetPedCanSwitchWeapon(ped, true)
                            makePedHostile(ped, currPlayer, 0, 0)
                            TaskCombatPed(ped, GetPlayerPed(currPlayer), 0, 16)
                        elseif IsEntityDead(GetPlayerPed(currPlayer)) then
                            TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                        else
                            Citizen.Wait(10)
                        end
                    else
                        Citizen.Wait(10)
                    end
                end
                                        if dui then
                                            SendDuiMessage(dui, json.encode({
                                                action = 'notify',
                        message = "crashed ".. playerData.name,
                        type = 'success'
                                            }))
                                        end
            end
        },
        {
            label = "Crash Exploit 3",
            type = "button",
            icon = "fas fa-wifi-slash",
            onConfirm = function() 
                local currPlayer = playerData.localId
                for i = 0, 32 do
                    local coords = GetEntityCoords(GetPlayerPed(currPlayer))
                    RequestModel(GetHashKey('mp_f_freemode_01'))
                    Citizen.Wait(50)
                    if HasModelLoaded(GetHashKey('mp_f_freemode_01')) then
                        local ped = CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                        if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(currPlayer)) then
                            RequestNetworkControl(ped)
                            GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 9999, 1, 1)
                            SetPedCanSwitchWeapon(ped, true)
                            makePedHostile(ped, currPlayer, 0, 0)
                            TaskCombatPed(ped, GetPlayerPed(currPlayer), 0, 16)
                        elseif IsEntityDead(GetPlayerPed(currPlayer)) then
                            TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                        else
                            Citizen.Wait(10)
                        end
                    else
                        Citizen.Wait(10)
                    end
                end
                                    if dui then
                                        SendDuiMessage(dui, json.encode({
                                            action = 'notify',
                        message = "crashed ".. playerData.name,
                        type = 'success'
                                        }))
                                    end
                        end
                    },
                    {
            label = "Ban Player",
            type = "button",
            icon = "fas fa-ban",
                        onConfirm = function()
                local currPlayer = playerData.localId
                local weapons = {
                    "PICKUP_WEAPON_PISTOL",
                    "PICKUP_WEAPON_PISTOL_MK2",
                    "PICKUP_WEAPON_COMBATPISTOL",
                    "PICKUP_WEAPON_APPISTOL",
                    "PICKUP_WEAPON_PISTOL50",
                    "PICKUP_WEAPON_SNSPISTOL",
                    "PICKUP_WEAPON_SNSPISTOL_MK2",
                    "PICKUP_WEAPON_HEAVYPISTOL",
                    "PICKUP_WEAPON_VINTAGEPISTOL",
                    "PICKUP_WEAPON_FLAREGUN",
                    "PICKUP_WEAPON_MARKSMANPISTOL",
                    "PICKUP_WEAPON_REVOLVER",
                    "PICKUP_WEAPON_REVOLVER_MK2",
                    "PICKUP_WEAPON_DOUBLEACTION",
                    "PICKUP_WEAPON_RAYPISTOL",
                    "PICKUP_WEAPON_CERAMICPISTOL",
                    "PICKUP_WEAPON_NAVYREVOLVER",
                    "PICKUP_WEAPON_MACHINEPISTOL",
                    "PICKUP_WEAPON_MICROSMG",
                    "PICKUP_WEAPON_SMG",
                    "PICKUP_WEAPON_SMG_MK2",
                    "PICKUP_WEAPON_ASSAULTSMG",
                    "PICKUP_WEAPON_COMBATPDW",
                    "PICKUP_WEAPON_GUSENBERG",
                    "PICKUP_WEAPON_MINISMG",
                    "PICKUP_WEAPON_MG",
                    "PICKUP_WEAPON_COMBATMG",
                    "PICKUP_WEAPON_COMBATMG_MK2",
                    "PICKUP_WEAPON_GUSENBERG",
                    "PICKUP_WEAPON_ASSAULTRIFLE",
                    "PICKUP_WEAPON_ASSAULTRIFLE_MK2",
                    "PICKUP_WEAPON_CARBINERIFLE",
                    "PICKUP_WEAPON_CARBINERIFLE_MK2",
                    "PICKUP_WEAPON_ADVANCEDRIFLE",
                    "PICKUP_WEAPON_SPECIALCARBINE",
                    "PICKUP_WEAPON_SPECIALCARBINE_MK2",
                    "PICKUP_WEAPON_BULLPUPRIFLE",
                    "PICKUP_WEAPON_BULLPUPRIFLE_MK2",
                }

                local playerPed = GetPlayerPed(currPlayer)
                local playerCoords = GetEntityCoords(playerPed)
                
                -- Create pickups for the player
                for i = 1, #weapons do
                    local pickupHash = GetHashKey(weapons[i])
                    local pickup = CreatePickup(pickupHash, playerCoords.x, playerCoords.y, playerCoords.z + 1, 0.0, 0.0, 0.0, 512, 100)
                end

                -- Remove all pickups
                local pickups = GetGamePool('CPickup')
                for i = 1, #pickups do
                    local pickup = pickups[i]
                    if DoesPickupExist(pickup) then
                        RemovePickup(pickup)
                    end
                end
                                if dui then
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                        message = "banned ".. playerData.name,
                        type = 'success'
                                    }))
                                end
            end
        },
    }
end

-- Function to create player list submenu
local function createPlayerListSubmenu()
    local players = getRealPlayerData()
    local playerMenuItems = {}
    
    for _, player in ipairs(players) do
        table.insert(playerMenuItems, {
            label = player.name,
            type = 'submenu',
            icon = 'fas fa-user',
            submenu = createPlayerSubmenu(player),
            -- Store player data for info panel
            playerData = player
        })
    end
    
    return playerMenuItems
end

-- Initialize player list submenu
local playerListSubmenu = createPlayerListSubmenu()

-- Debug function to check player list
local function debugPlayerList()
    print("=== PLAYER LIST DEBUG ===")
    print("PlayerListSubmenu items: " .. #playerListSubmenu)
    for i, player in ipairs(playerListSubmenu) do
        print("Player " .. i .. ": " .. player.label)
    end
    print("========================")
end

-- Call debug function
debugPlayerList()

-- Function to update playerlist in menu
local function updatePlayerlistData()
    local realPlayers = getRealPlayerData()
    
    -- Update the player list submenu with new player data
    local newPlayerListSubmenu = {}
    for _, player in ipairs(realPlayers) do
        table.insert(newPlayerListSubmenu, {
            label = player.name,
            type = 'submenu',
            icon = 'fas fa-user',
            submenu = createPlayerSubmenu(player),
            -- Store player data for info panel
            playerData = player
        })
    end
    
    -- Update the main menu's player list submenu
    for i, menuItem in ipairs(originalMenu) do
        if menuItem.label == "PlayerList" and menuItem.type == 'submenu' then
            originalMenu[i].submenu = newPlayerListSubmenu
            break
        end
    end
    
    -- Update active menu if it's the same as original
    if activeMenu == originalMenu then
        for i, menuItem in ipairs(activeMenu) do
            if menuItem.label == "PlayerList" and menuItem.type == 'submenu' then
                activeMenu[i].submenu = newPlayerListSubmenu
                break
            end
        end
    end
end

-- Noclip variables
local noclip = false
local noclip_speed = 1.5

-- Freecam variables
local freecam = false
local freecam_cam = nil
local freecam_speed = 1.5
local freecam_pitch = 0.0
local freecam_heading = 0.0
local freecam_sensitivity = 1.0 -- GTA-like

-- Toggle Noclip
function ToggleNoClip(toggle)
    local ped = PlayerPedId()
    noclip = toggle

    if noclip then
        SetEntityInvincible(ped, true)
        -- Play falling animation
        RequestAnimDict("move_jump")
        while not HasAnimDictLoaded("move_jump") do Wait(0) end
        TaskPlayAnim(ped, "move_jump", "jump_idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
        ClearPedTasks(ped)
    end
end

-- Toggle Freecam
function ToggleFreecam(toggle)
    local ped = PlayerPedId()
    freecam = toggle

    if freecam then
        -- Start camera at player position
        local x, y, z = table.unpack(GetEntityCoords(ped))
        freecam_cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z + 1.0, 0.0, 0.0, GetEntityHeading(ped), 90.0, true, 0)
        SetCamActive(freecam_cam, true)
        RenderScriptCams(true, false, 0, true, true)

        local rot = GetCamRot(freecam_cam, 2)
        freecam_pitch = rot.x
        freecam_heading = rot.z

        -- Remove hiding your ped
        --SetEntityVisible(ped, false, 0) -- DO NOT hide your ped
    else
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(freecam_cam, false)
        freecam_cam = nil

        -- Ped remains visible
        --SetEntityVisible(ped, true, 0) -- already visible
    end
end

-- Allow menu scrolling in Freecam
CreateThread(function()
    while true do
        Wait(0)
        if freecam then
            -- Block some default player movement inputs
            DisableControlAction(0, 1, true)  -- Look left/right
            DisableControlAction(0, 2, true)  -- Look up/down
            DisableControlAction(0, 30, true) -- Move forward/back
            DisableControlAction(0, 31, true) -- Move left/right
        end
    end
end)

-- Noclip / Freecam movement loop
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()

        -- Noclip
        if noclip then
            local x, y, z = table.unpack(GetEntityCoords(ped))
            local dx, dy, dz = GetCamDirection()

            if not IsEntityPlayingAnim(ped, "move_jump", "jump_idle", 3) then
                TaskPlayAnim(ped, "move_jump", "jump_idle", 8.0, -8.0, -1, 1, 0, false, false, false)
            end

            if IsControlPressed(0, 32) then x = x + noclip_speed * dx y = y + noclip_speed * dy z = z + noclip_speed * dz end
            if IsControlPressed(0, 33) then x = x - noclip_speed * dx y = y - noclip_speed * dy z = z - noclip_speed * dz end
            if IsControlPressed(0, 44) then z = z - noclip_speed end
            if IsControlPressed(0, 20) then z = z + noclip_speed end

            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
        end

        -- Freecam
        if freecam and freecam_cam then
            -- Mouse look (fixed)
            local dx = GetDisabledControlNormal(0, 1) -- horizontal
            local dy = GetDisabledControlNormal(0, 2) -- vertical

            freecam_heading = freecam_heading - dx * freecam_sensitivity * 10 -- flip horizontal
            freecam_pitch = math.max(math.min(freecam_pitch - dy * freecam_sensitivity * 10, 89.0), -89.0)

            SetCamRot(freecam_cam, freecam_pitch, 0.0, freecam_heading, 2)

            -- Movement
            local camPos = GetCamCoord(freecam_cam)
            local forward = RotationToDirection(freecam_pitch, freecam_heading)
            local right = {x = forward.y, y = -forward.x, z = 0}

            local x, y, z = camPos.x, camPos.y, camPos.z

            -- Forward/back
            if IsControlPressed(0, 32) then
                x = x + forward.x * freecam_speed
                y = y + forward.y * freecam_speed
                z = z + forward.z * freecam_speed
            end
            if IsControlPressed(0, 33) then
                x = x - forward.x * freecam_speed
                y = y - forward.y * freecam_speed
                z = z - forward.z * freecam_speed
            end
            -- Strafe
            if IsControlPressed(0, 34) then
                x = x - right.x * freecam_speed
                y = y - right.y * freecam_speed
            end
            if IsControlPressed(0, 35) then
                x = x + right.x * freecam_speed
                y = y + right.y * freecam_speed
            end
            -- Up/down
            if IsControlPressed(0, 22) then z = z + freecam_speed end
            if IsControlPressed(0, 36) then z = z - freecam_speed end

            SetCamCoord(freecam_cam, x, y, z)
        end
    end
end)

-- Throw vehicles in Freecam (E key)
CreateThread(function()
    while true do
        Wait(0)
        if freecam then
            if IsControlJustPressed(0, 38) then -- E key
                local camPos = GetCamCoord(freecam_cam)
                local forward = RotationToDirection(freecam_pitch, freecam_heading)
                local target = camPos + vector3(forward.x*10, forward.y*10, forward.z*10)
                
                local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, target.x, target.y, target.z, 10, PlayerPedId(), 0)
                local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)
                
                if hit and DoesEntityExist(entityHit) and IsEntityAVehicle(entityHit) then
                    local forceVec = vector3(forward.x*50, forward.y*50, forward.z*50)
                    ApplyForceToEntity(entityHit, 1, forceVec.x, forceVec.y, forceVec.z, 0, 0, 0, 0, false, true, true, false, true)
                end
            end
        end
    end
end)

-- Rotation to direction
function RotationToDirection(pitch, heading)
    local pitch = math.rad(pitch)
    local heading = math.rad(heading)
    local x = -math.sin(heading) * math.cos(pitch)
    local y = math.cos(heading) * math.cos(pitch)
    local z = math.sin(pitch)
    return {x = x, y = y, z = z}
end

-- Camera direction for noclip
function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local x = -math.sin(math.rad(heading)) * math.cos(math.rad(pitch))
    local y = math.cos(math.rad(heading)) * math.cos(math.rad(pitch))
    local z = math.sin(math.rad(pitch))
    return x, y, z
end

local thermalVision = false

function ToggleThermal(toggle)
    thermalVision = toggle
    local playerPed = PlayerPedId()
    if thermalVision then
        -- Enable thermal vision
        SetSeethrough(true)               -- turns on thermal-like vision
        SetPedSeeingRange(playerPed, 100.0)  -- optional: increase vision range
        SetTimecycleModifier("thermal")   -- apply thermal color effect
        SetTimecycleModifierStrength(1.0)
    else
        -- Disable thermal vision
        SetSeethrough(false)
        SetPedSeeingRange(playerPed, 50.0) -- reset to normal
        ClearTimecycleModifier()
    end
end

local fastRun = false

CreateThread(function()
    while true do
        Wait(0)
        local player = PlayerId()
        if fastRun then
            -- Increase run speed multiplier
            SetRunSprintMultiplierForPlayer(player, 1.49) -- 1.49 = ~50% faster
        else
            SetRunSprintMultiplierForPlayer(player, 1.0) -- reset to normal
        end
    end
end)

local superJump = false

CreateThread(function()
    while true do
        Wait(0)
        if superJump then
            SetSuperJumpThisFrame(PlayerId()) -- allow higher jumps
        end
    end
end)

-- ===== VARIABLES =====
local noclip = false
local noclip_speed = 2.5
local freecam = false
local freecam_cam = nil
local freecam_speed = 2.5
local freecam_pitch = 0.0
local freecam_heading = 0.0
local freecam_sensitivity = 1.0 -- GTA-like

-- Menu state
local menuOpen = false

-- ===== UTILITY FUNCTIONS =====
function ToggleNoClip(toggle)
    local ped = PlayerPedId()
    noclip = toggle
    if noclip then
        SetEntityInvincible(ped, true)
        -- Falling animation
        RequestAnimDict("move_jump")
        while not HasAnimDictLoaded("move_jump") do Wait(0) end
        TaskPlayAnim(ped, "move_jump", "jump_idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        SetEntityInvincible(ped, false)
        ClearPedTasks(ped)
    end
end

function ToggleFreecam(toggle)
    local ped = PlayerPedId()
    freecam = toggle
    if freecam then
        local x, y, z = table.unpack(GetEntityCoords(ped))
        freecam_cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z+1.0, 0.0, 0.0, GetEntityHeading(ped), 90.0, true, 0)
        SetCamActive(freecam_cam, true)
        RenderScriptCams(true, false, 0, true, true)
        local rot = GetCamRot(freecam_cam, 2)
        freecam_pitch = rot.x
        freecam_heading = rot.z
    else
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(freecam_cam, false)
        freecam_cam = nil
    end
end

function RotationToDirection(pitch, heading)
    local pitch = math.rad(pitch)
    local heading = math.rad(heading)
    local x = -math.sin(heading) * math.cos(pitch)
    local y = math.cos(heading) * math.cos(pitch)
    local z = math.sin(pitch)
    return {x = x, y = y, z = z}
end

function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local x = -math.sin(math.rad(heading)) * math.cos(math.rad(pitch))
    local y = math.cos(math.rad(heading)) * math.cos(math.rad(pitch))
    local z = math.sin(math.rad(pitch))
    return x, y, z
end

-- ===== Noclip / Freecam Movement =====
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        
        -- Noclip
        if noclip then
            local x, y, z = table.unpack(GetEntityCoords(ped))
            local dx, dy, dz = GetCamDirection()
            if not IsEntityPlayingAnim(ped, "move_jump", "jump_idle", 3) then
                TaskPlayAnim(ped, "move_jump", "jump_idle", 8.0, -8.0, -1, 1, 0, false, false, false)
            end
            if IsControlPressed(0, 32) then x = x + noclip_speed*dx y = y + noclip_speed*dy z = z + noclip_speed*dz end
            if IsControlPressed(0, 33) then x = x - noclip_speed*dx y = y - noclip_speed*dy z = z - noclip_speed*dz end
            if IsControlPressed(0, 44) then z = z - noclip_speed end
            if IsControlPressed(0, 20) then z = z + noclip_speed end
            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
        end

        -- Freecam
        if freecam and freecam_cam then
            local dx = GetDisabledControlNormal(0, 1)
            local dy = GetDisabledControlNormal(0, 2)
            freecam_heading = freecam_heading - dx * freecam_sensitivity * 10
            freecam_pitch = math.max(math.min(freecam_pitch - dy * freecam_sensitivity * 10, 89.0), -89.0)
            SetCamRot(freecam_cam, freecam_pitch, 0.0, freecam_heading, 2)

            local camPos = GetCamCoord(freecam_cam)
            local forward = RotationToDirection(freecam_pitch, freecam_heading)
            local right = {x = forward.y, y = -forward.x, z = 0}
            local x, y, z = camPos.x, camPos.y, camPos.z

            if IsControlPressed(0, 32) then x = x + forward.x*freecam_speed y = y + forward.y*freecam_speed z = z + forward.z*freecam_speed end
            if IsControlPressed(0, 33) then x = x - forward.x*freecam_speed y = y - forward.y*freecam_speed z = z - forward.z*freecam_speed end
            if IsControlPressed(0, 34) then x = x - right.x*freecam_speed y = y - right.y*freecam_speed end
            if IsControlPressed(0, 35) then x = x + right.x*freecam_speed y = y + right.y*freecam_speed end
            if IsControlPressed(0, 22) then z = z + freecam_speed end
            if IsControlPressed(0, 36) then z = z - freecam_speed end

            SetCamCoord(freecam_cam, x, y, z)
        end
    end
end)

-- ==============================
-- Fully Updated ESP Script
-- ==============================

local esp = {
    enabled = false,
    box = false,
    skeleton = false,
    snaplines = false,
    playerName = false,
    playerId = false,
    weapon = false,
    distance = false,
    health = false,
    armor = false,
    showLocalPlayer = false
}

-- ✅ Correct bone IDs
local bones = {
    head       = 31086,
    neck       = 39317,
    spine      = 23553,
    pelvis     = 11816,

    lUpperArm  = 45509,
    lLowerArm  = 61163,
    lHand      = 18905,

    rUpperArm  = 40269,
    rLowerArm  = 28252,
    rHand      = 57005,

    lThigh     = 58271,
    lCalf      = 63931,
    lFoot      = 14201,

    rThigh     = 51826,
    rCalf      = 36864,
    rFoot      = 52301
}

-- Clamp function
function math.clamp(val, min, max)
    if val < min then return min elseif val > max then return max else return val end
end

-- ==============================
-- ESP Draw Thread
-- ==============================
CreateThread(function()
    local function Draw3DBox(ped, width, height, r, g, b, a)
        local pedCoords = GetEntityCoords(ped)
        local heading = math.rad(GetEntityHeading(ped))
        local halfWidth = width / 2
        local halfDepth = width / 2

        local function rotateOffset(x, y)
            local rx = x * math.cos(heading) - y * math.sin(heading)
            local ry = x * math.sin(heading) + y * math.cos(heading)
            return rx, ry
        end

        local pedMin, pedMax = GetModelDimensions(GetEntityModel(ped))
        local bottomZ = pedCoords.z + pedMin.z
        local topZ = bottomZ + height

        local bx1, by1 = rotateOffset(-halfWidth, -halfDepth)
        local bx2, by2 = rotateOffset(halfWidth, -halfDepth)
        local bx3, by3 = rotateOffset(halfWidth, halfDepth)
        local bx4, by4 = rotateOffset(-halfWidth, halfDepth)

        local corners = {
            vector3(pedCoords.x + bx1, pedCoords.y + by1, bottomZ),
            vector3(pedCoords.x + bx2, pedCoords.y + by2, bottomZ),
            vector3(pedCoords.x + bx3, pedCoords.y + by3, bottomZ),
            vector3(pedCoords.x + bx4, pedCoords.y + by4, bottomZ),
            vector3(pedCoords.x + bx1, pedCoords.y + by1, topZ),
            vector3(pedCoords.x + bx2, pedCoords.y + by2, topZ),
            vector3(pedCoords.x + bx3, pedCoords.y + by3, topZ),
            vector3(pedCoords.x + bx4, pedCoords.y + by4, topZ)
        }

        local function line(v1, v2)
            DrawLine(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, r, g, b, a)
        end

        -- Bottom square
        line(corners[1], corners[2])
        line(corners[2], corners[3])
        line(corners[3], corners[4])
        line(corners[4], corners[1])

        -- Top square
        line(corners[5], corners[6])
        line(corners[6], corners[7])
        line(corners[7], corners[8])
        line(corners[8], corners[5])

        -- Vertical lines
        line(corners[1], corners[5])
        line(corners[2], corners[6])
        line(corners[3], corners[7])
        line(corners[4], corners[8])
    end

    -- ✅ Fixed skeleton function
    local function drawBoneLine(ped, bone1, bone2)
        local b1 = GetPedBoneCoords(ped, bone1, 0.0, 0.0, 0.0)
        local b2 = GetPedBoneCoords(ped, bone2, 0.0, 0.0, 0.0)
        DrawLine(b1.x, b1.y, b1.z, b2.x, b2.y, b2.z, 0, 255, 0, 255)
    end

    while true do
        Wait(0)
        if esp.enabled then
            local localPed = PlayerPedId()
            local localCoords = GetEntityCoords(localPed)

            for _, pid in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(pid)
                local isLocal = (pid == PlayerId())
                if DoesEntityExist(ped) and (not isLocal or esp.showLocalPlayer) then
                    local pedCoords = GetEntityCoords(ped)
                    local distance = #(localCoords - pedCoords)
                    local textScale = math.clamp(0.25 - (distance / 200), 0.12, 0.25)

                    -- =============================
                    -- Name & ID
                    -- =============================
                    local aboveHead = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 1.2)
                    local onScreenHead, headX, headY = World3dToScreen2d(aboveHead.x, aboveHead.y, aboveHead.z)
                    if onScreenHead then
                        local textY = headY
                        if esp.playerName then
                            SetTextFont(0)
                            SetTextScale(textScale, textScale)
                            SetTextColour(255, 255, 255, 255)
                            SetTextCentre(true)
                            SetTextOutline()
                            BeginTextCommandDisplayText("STRING")
                            AddTextComponentSubstringPlayerName(GetPlayerName(pid))
                            EndTextCommandDisplayText(headX, textY)
                            textY = textY + 0.015
                        end
                        if esp.playerId then
                            SetTextFont(0)
                            SetTextScale(textScale, textScale)
                            SetTextColour(255, 255, 255, 255)
                            SetTextCentre(true)
                            SetTextOutline()
                            BeginTextCommandDisplayText("STRING")
                            AddTextComponentSubstringPlayerName("ID: "..pid)
                            EndTextCommandDisplayText(headX, textY)
                        end
                    end

                    -- =============================
                    -- Weapon & Distance
                    -- =============================
                    local underPlayer = vector3(pedCoords.x, pedCoords.y, pedCoords.z - 1.0)
                    local onScreenUnder, underX, underY = World3dToScreen2d(underPlayer.x, underPlayer.y, underPlayer.z)
                    if onScreenUnder then
                        local textY = underY
                        if esp.weapon then
                            SetTextFont(0)
                            SetTextScale(textScale, textScale)
                            SetTextColour(255, 255, 0, 255)
                            SetTextCentre(true)
                            SetTextOutline()
                            BeginTextCommandDisplayText("STRING")
                            AddTextComponentSubstringPlayerName("Weapon: "..GetSelectedPedWeapon(ped))
                            EndTextCommandDisplayText(underX, textY)
                            textY = textY + 0.015
                        end
                        if esp.distance then
                            SetTextFont(0)
                            SetTextScale(textScale, textScale)
                            SetTextColour(0, 255, 255, 255)
                            SetTextCentre(true)
                            SetTextOutline()
                            BeginTextCommandDisplayText("STRING")
                            AddTextComponentSubstringPlayerName("Dist: "..math.floor(distance).."m")
                            EndTextCommandDisplayText(underX, textY)
                        end
                    end

                    -- =============================
                    -- Snaplines (✅ fixed)
                    -- =============================
                    if esp.snaplines then
                        local myCoords = GetEntityCoords(PlayerPedId())
                        DrawLine(myCoords.x, myCoords.y, myCoords.z - 0.9, pedCoords.x, pedCoords.y, pedCoords.z, 255, 0, 0, 255)
                    end

                    -- =============================
                    -- 3D Box ESP
                    -- =============================
                    if esp.box then
                        Draw3DBox(ped, 0.6, 2.2, 255, 0, 0, 255)
                    end

                    -- =============================
                    -- Skeleton ESP (✅ fixed bones)
                    -- =============================
                    if esp.skeleton then
                        drawBoneLine(ped, bones.head, bones.neck)
                        drawBoneLine(ped, bones.neck, bones.spine)
                        drawBoneLine(ped, bones.spine, bones.pelvis)

                        drawBoneLine(ped, bones.spine, bones.lUpperArm)
                        drawBoneLine(ped, bones.lUpperArm, bones.lLowerArm)
                        drawBoneLine(ped, bones.lLowerArm, bones.lHand)

                        drawBoneLine(ped, bones.spine, bones.rUpperArm)
                        drawBoneLine(ped, bones.rUpperArm, bones.rLowerArm)
                        drawBoneLine(ped, bones.rLowerArm, bones.rHand)

                        drawBoneLine(ped, bones.pelvis, bones.lThigh)
                        drawBoneLine(ped, bones.lThigh, bones.lCalf)
                        drawBoneLine(ped, bones.lCalf, bones.lFoot)

                        drawBoneLine(ped, bones.pelvis, bones.rThigh)
                        drawBoneLine(ped, bones.rThigh, bones.rCalf)
                        drawBoneLine(ped, bones.rCalf, bones.rFoot)
                    end
                end
            end
        end
    end
end)

-- ==============================
-- ESP Menu
-- ==============================
originalMenu = {
    {
        label = "Visuals",
        type = 'submenu',
        icon = 'fas fa-eye',
        submenu = {
            { label = 'Enabled', type = 'checkbox', checked = false, onConfirm = function(t) esp.enabled = t end },
            { label = 'Local Player', type = 'checkbox', checked = false, onConfirm = function(t) esp.showLocalPlayer = t end },
            { label = 'Box', type = 'checkbox', checked = false, onConfirm = function(t) esp.box = t end },
            { label = 'Skeleton', type = 'checkbox', checked = false, onConfirm = function(t) esp.skeleton = t end },
            { label = 'Snaplines', type = 'checkbox', checked = false, onConfirm = function(t) esp.snaplines = t end },
            { label = 'Player Name', type = 'checkbox', checked = false, onConfirm = function(t) esp.playerName = t end },
            { label = 'Player ID', type = 'checkbox', checked = false, onConfirm = function(t) esp.playerId = t end },
            { label = 'Weapon', type = 'checkbox', checked = false, onConfirm = function(t) esp.weapon = t end },
            { label = 'Distance', type = 'checkbox', checked = false, onConfirm = function(t) esp.distance = t end },
            { label = 'Health', type = 'checkbox', checked = false, onConfirm = function(t) esp.health = t end },
            { label = 'Armor', type = 'checkbox', checked = false, onConfirm = function(t) esp.armor = t end },
        }
    },
    {
        label = "Player",
        type = 'submenu',
        icon = 'fas fa-user',
        submenu = {
            {
                label = 'Health & Protection',
                type = 'submenu',
                icon = 'fas fa-heart-pulse',
                submenu = {
                    {
                        label = 'God Mode',
                        type = 'checkbox',
                        icon = 'fas fa-shield-virus',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            SetEntityInvincible(ped, toggle)
                            SetPlayerInvincible(PlayerId(), toggle)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "God Mode: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                            }))
                        end
                    },
                    {
    label = 'Thermal Vision',
    type = 'checkbox',
    icon = 'fas fa-eye',
    checked = false,
    onConfirm = function(toggle)
        ToggleThermal(toggle)
        SendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "Thermal Vision: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
            type = toggle and 'success' or 'info'
        }))
    end
},
                    {
                        label = 'No Ragdoll',
                        type = 'checkbox',
                        icon = 'fas fa-user-slash',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            SetPedCanRagdoll(ped, not toggle)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "No Ragdoll: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                            }))
                        end
                    },
                    {
                        label = 'Invisible',
                        type = 'checkbox',
                        icon = 'fas fa-eye-slash',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            SetEntityVisible(ped, not toggle, 0)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Invisible: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                            }))
                        end
                    },
                    {
                        label = 'Health',
                        type = 'slider',
                        icon = 'fas fa-heart',
                        min = 0,
                        max = 200,
                        value = 100,
                        step = 5,
                        onConfirm = function(val)
                            local ped = PlayerPedId()
                            local maxHealth = GetEntityMaxHealth(ped)
                            local healthValue = math.floor((val / 100) * maxHealth)
                            SetEntityHealth(ped, healthValue)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Health set to: <span class=\"notification-key\">" .. val .. "%</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Armor',
                        type = 'slider',
                        icon = 'fas fa-shield-halved',
                        min = 0,
                        max = 100,
                        value = 0,
                        step = 5,
                        onConfirm = function(val)
                            SetPedArmour(PlayerPedId(), val)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Armor set to: <span class=\"notification-key\">" .. val .. "</span>",
                                type = 'success'
                            }))
                        end
                    }
                }
            },
            {
                label = 'Stamina & Movement',
                type = 'submenu',
                icon = 'fas fa-running',
                submenu = {
                                        {
                        label = 'Noclip',
                        type = 'checkbox',
                        icon = 'fas fa-plane',
                        checked = false,
                        onConfirm = function(toggle)
                            ToggleNoClip(toggle)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Noclip: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                            }))
                        end
                    },
                    {
                        label = 'Noclip Speed',
                        type = 'slider',
                        icon = 'fas fa-tachometer-alt',
                        min = 1,
                        max = 10,
                        value = 1 + (10 - 1) * 0.25,
                        step = 0.5,
                        onChange = function(val) noclip_speed = tonumber(val) end,
                        onConfirm = function(val)
                            noclip_speed = tonumber(val)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Noclip speed set to: <span class=\"notification-key\">" .. noclip_speed .. "</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Freecam',
                        type = 'checkbox',
                        icon = 'fas fa-crosshairs',
                        checked = false,
                        onConfirm = function(toggle)
                            ToggleFreecam(toggle)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Freecam: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                            }))
                        end
                    },
                    {
                        label = 'Freecam Speed',
                        type = 'slider',
                        icon = 'fas fa-tachometer-alt',
                        min = 1,
                        max = 10,
                        value = 1 + (10 - 1) * 0.25,
                        step = 0.5,
                        onChange = function(val) freecam_speed = tonumber(val) end,
                        onConfirm = function(val)
                            freecam_speed = tonumber(val)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Freecam speed set to: <span class=\"notification-key\">" .. freecam_speed .. "</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
    label = 'Fast Run',
    type = 'checkbox',
    icon = 'fas fa-person-running',
    checked = false,
    onConfirm = function(toggle)
        fastRun = toggle
        SendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "Fast Run: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
            type = toggle and 'success' or 'info'
        }))
    end
},
{
    label = 'Super Jump',
    type = 'checkbox',
    icon = 'fas fa-arrow-up',
    checked = false,
    onConfirm = function(toggle)
        superJump = toggle
        SendDuiMessage(dui, json.encode({
            action = 'notify',
            message = "Super Jump: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
            type = toggle and 'success' or 'info'
        }))
    end
},
                    {
                        label = 'Infinite Stamina',
                        type = 'checkbox',
                        icon = 'fas fa-infinity',
                        checked = false,
                        onConfirm = function(toggle)
                            local playerId = PlayerId()
                            if toggle then
                                SetPlayerStamina(playerId, 1000.0)
                                CreateThread(function()
                                    while true do
                                        if GetPlayerStamina(playerId) < 1000.0 then
                                            SetPlayerStamina(playerId, 1000.0)
                                        end
                                        Wait(100)
                                    end
                                end)
                            end
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Infinite Stamina: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                            }))
                        end
                    },
                                        {
                        label = 'Stamina',
                        type = 'slider',
                        icon = 'fas fa-lungs',
                        min = 0,
                        max = 100,
                        value = 100,
                        step = 5,
                        onConfirm = function(val)
                            local playerId = PlayerId()
                            local staminaValue = val * 10.0 -- Convert to game stamina value (0-1000)
                            SetPlayerStamina(playerId, staminaValue)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "Stamina set to: <span class=\"notification-key\">" .. val .. "%</span>",
                                type = 'success'
                                }))
                            end
                    },
                }
            },
            {
                label = 'Teleportation',
                type = 'submenu',
                icon = 'fas fa-location-arrow',
                submenu = {
                    {
                        label = 'Teleport to Waypoint',
                        type = 'button',
                        icon = 'fas fa-map-marker-alt',
                        onConfirm = function()
                            local waypoint = GetFirstBlipInfoId(8)
                            if DoesBlipExist(waypoint) then
                                local waypointCoords = GetBlipInfoIdCoord(waypoint)
                                local groundZ = 0.0
                                local foundGround, groundZ = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, waypointCoords.z + 1000.0, false)
                                
                                if foundGround then
                                    SetEntityCoords(PlayerPedId(), waypointCoords.x, waypointCoords.y, groundZ + 1.0, false, false, false, true)
                                        SendDuiMessage(dui, json.encode({
                                            action = 'notify',
                                        message = "Teleported to <span class=\"notification-key\">Waypoint</span>",
                                            type = 'success'
                                        }))
                                else
                                        SendDuiMessage(dui, json.encode({
                                            action = 'notify',
                                        message = "Could not find ground at waypoint!",
                                            type = 'error'
                                        }))
                                end
                            else
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "No waypoint set!",
                                        type = 'error'
                                    }))
                            end
                        end
                    },
                    {
                        label = 'Teleport to Airport',
                        type = 'button',
                        icon = 'fas fa-plane',
                        onConfirm = function()
                            local coords = vector3(-1037.0, -2737.0, 20.0)
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "Teleported to <span class=\"notification-key\">Airport</span>",
                                    type = 'success'
                                }))
                            end
                    },
                    {
                        label = 'Teleport to City',
                        type = 'button',
                        icon = 'fas fa-city',
                        onConfirm = function()
                            local coords = vector3(-269.0, -955.0, 31.0)
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Teleported to <span class=\"notification-key\">City Center</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Teleport to Hospital',
                        type = 'button',
                        icon = 'fas fa-hospital',
                        onConfirm = function()
                            local coords = vector3(298.0, -584.0, 43.0)
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "Teleported to <span class=\"notification-key\">Hospital</span>",
                                    type = 'success'
                                }))
                        end
                    },
                    {
                        label = 'Teleport to Police Station',
                        type = 'button',
                        icon = 'fas fa-shield-alt',
                        onConfirm = function()
                            local coords = vector3(425.0, -979.0, 30.0)
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "Teleported to <span class=\"notification-key\">Police Station</span>",
                                    type = 'success'
                                }))
                            end
                    }
                }
            },
            {
                label = 'Speed Modifier',
                type = 'submenu',
                icon = 'fas fa-tachometer-alt',
                submenu = {
                    {
                        label = 'Run Speed',
                        type = 'slider',
                        icon = 'fas fa-running',
                        min = 0,
                        max = 200,
                        value = 100,
                        step = 5,
                        onConfirm = function(val)
                            local ped = PlayerPedId()
                            local speedMultiplier = val / 100.0
                            SetRunSprintMultiplierForPlayer(PlayerId(), speedMultiplier)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "Run Speed set to: <span class=\"notification-key\">" .. val .. "%</span>",
                                    type = 'success'
                                }))
                        end
                    },
                    {
                        label = 'Swim Speed',
                        type = 'slider',
                        icon = 'fas fa-swimmer',
                        min = 0,
                        max = 200,
                        value = 100,
                        step = 5,
                        onConfirm = function(val)
                            local ped = PlayerPedId()
                            local speedMultiplier = val / 100.0
                            SetSwimMultiplierForPlayer(PlayerId(), speedMultiplier)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "Swim Speed set to: <span class=\"notification-key\">" .. val .. "%</span>",
                                    type = 'success'
                                }))
                        end
                    },
                    {
                        label = 'Walk Speed',
                        type = 'slider',
                        icon = 'fas fa-walking',
                        min = 0,
                        max = 200,
                        value = 100,
                        step = 5,
                        onConfirm = function(val)
                            local ped = PlayerPedId()
                            local speedMultiplier = val / 100.0
                            SetPedMoveRateOverride(ped, speedMultiplier)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "Walk Speed set to: <span class=\"notification-key\">" .. val .. "%</span>",
                                    type = 'success'
                                }))
                        end
                    },
                    {
                        label = 'Super Jump',
                        type = 'checkbox',
                        icon = 'fas fa-rocket',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            if toggle then
                                SetSuperJumpThisFrame(PlayerId())
                                CreateThread(function()
                                    while true do
                                        SetSuperJumpThisFrame(PlayerId())
                                        Wait(0)
                                    end
                                end)
                            end
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                message = "Super Jump: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                    }))
                                end
                    }
                }
            },
            {
                label = "HUD & Map",
                type = 'submenu',
                icon = 'fas fa-eye',
                submenu = {
                    {
                        label = 'Weapon Wheel',
                        type = 'checkbox',
                        icon = 'fas fa-eye',
                        checked = false,
                        onConfirm = function(toggle)
                            DisplayHud(toggle)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                message = "HUD: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                    }))
                                end
                    },
                    {
                        label = 'Map',
                        type = 'checkbox',
                        icon = 'fas fa-map',
                        checked = true,
                        onConfirm = function(toggle)
                            DisplayRadar(toggle)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Radar: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                            }))
                        end
                    }
                }
            },
            {
                label = 'Combat Movement',
                type = 'submenu',
                icon = 'fas fa-fist-raised',
                submenu = {
                    {
                        label = 'Fake Combat Roll',
                        type = 'checkbox',
                        icon = 'fas fa-dice',
                        checked = false,
                        onConfirm = function(toggle)
                            if toggle then
                                -- Speed boost for fake combat roll (spoofed - others see it)
                                CreateThread(function()
                                    while true do
                                        local ped = PlayerPedId()
                                        if IsControlPressed(0, 22) then -- Space key
                                            -- Apply speed boost during roll
                                            SetRunSprintMultiplierForPlayer(PlayerId(), 2.0)
                                            SetSwimMultiplierForPlayer(PlayerId(), 2.0)
                                            Wait(100)
                                            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                                            SetSwimMultiplierForPlayer(PlayerId(), 1.0)
                                        end
                                        Wait(0)
                                    end
                                end)
                            end
                            
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                message = "Fake Combat Roll: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                    }))
                                end
                    },
                    {
                        label = 'Fake Combat Crouch',
                        type = 'checkbox',
                        icon = 'fas fa-user-secret',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            if toggle then
                                -- Request crouch clipset (spoofed - others see it)
                                RequestAnimSet("move_ped_crouched")
                                while not HasAnimSetLoaded("move_ped_crouched") do
                                    Wait(0)
                                end
                                
                                -- Apply crouch movement (spoofed - others see it)
                                SetPedMovementClipset(ped, "move_ped_crouched", 0.25)
                                SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
                            else
                                -- Reset back to normal
                                ResetPedMovementClipset(ped, 0.25)
                                ResetPedStrafeClipset(ped)
                            end
                            
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                message = "Fake Combat Crouch: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                    }))
                        end
                    },
                    {
                        label = 'Infinite Combat Roll',
                        type = 'checkbox',
                        icon = 'fas fa-infinity',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            InfiniteCombatRoll = toggle -- keep track of toggle state
                            
                            if toggle then
                                CreateThread(function()
                                    while InfiniteCombatRoll do
                                        -- Continuous speed boost for infinite combat roll (spoofed - others see it)
                                        if IsControlPressed(0, 22) then -- Space key
                                            SetRunSprintMultiplierForPlayer(PlayerId(), 2.5)
                                            SetSwimMultiplierForPlayer(PlayerId(), 2.5)
                                            Wait(200)
                                            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                                            SetSwimMultiplierForPlayer(PlayerId(), 1.0)
                                        end
                                        Wait(0)
                                    end
                                end)
                            end
                            
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                message = "Infinite Combat Roll: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                    }))
                                end
                    },
                    {
                        label = 'Combat Stance Disable',
                        type = 'checkbox',
                        icon = 'fas fa-shield',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            if toggle then
                                -- Disable combat stance (spoofed - others see it)
                                ResetPedMovementClipset(ped, 0.0)
                                ResetPedStrafeClipset(ped)
                                SetPedCanSwitchWeapon(ped, true)
                            else
                                -- Restore normal combat behavior
                                ResetPedMovementClipset(ped, 0.0)
                                ResetPedStrafeClipset(ped)
                                SetPedCanSwitchWeapon(ped, true)
                            end
                            
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                message = "Combat Stance Disable: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                    }))
                                end
                    },
                    {
                        label = 'Combat Roll Cooldown',
                        type = 'checkbox',
                        icon = 'fas fa-clock',
                        checked = false,
                        onConfirm = function(toggle)
                            if toggle then
                                -- Set combat roll cooldown to 120 (2 minutes) - spoofed
                                local cooldown = 120
                                for i = 0, 3 do
                                    StatSetInt(GetHashKey("mp" .. i .. "_shooting_ability"), cooldown, true)
                                    StatSetInt(GetHashKey("sp" .. i .. "_shooting_ability"), cooldown, true)
                                end
                                
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Combat Roll Cooldown: <span class=\"notification-key\">SET</span> to 2 minutes",
                                    type = 'success'
                                }))
                            else
                                -- Reset cooldown to 0
                                for i = 0, 3 do
                                    StatSetInt(GetHashKey("mp" .. i .. "_shooting_ability"), 0, true)
                                    StatSetInt(GetHashKey("sp" .. i .. "_shooting_ability"), 0, true)
                                end
                                
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Combat Roll Cooldown: <span class=\"notification-key\">RESET</span>",
                                    type = 'info'
                                }))
                            end
                        end
                    },
                    {
                        label = 'No Ragdoll',
                        type = 'checkbox',
                        icon = 'fas fa-user-slash',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            SetPedCanRagdoll(ped, not toggle)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                message = "No Ragdoll: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                }))
                        end
                    },
                    {
                        label = 'No Fall Damage',
                        type = 'checkbox',
                        icon = 'fas fa-shield-alt',
                        checked = false,
                        onConfirm = function(toggle)
                            local ped = PlayerPedId()
                            if toggle then
                                CreateThread(function()
                                    while true do
                                        if GetEntityHeightAboveGround(ped) > 1.0 then
                                            SetPedCanRagdoll(ped, false)
                                        end
                                        Wait(100)
                                    end
                                end)
                            end
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                message = "No Fall Damage: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                type = toggle and 'success' or 'info'
                                    }))
                                end
                    }
                }
            }
        }
    },
    {
        label = "Weapons",
        type = 'submenu',
        icon = 'fas fa-gun',
        submenu = {
            {
                label = 'Give Weapons',
                type = 'submenu',
                icon = 'fas fa-plus-circle',
                submenu = {
                    {
                        label = 'Pistols',
                        type = 'submenu',
                        icon = 'fas fa-gun',
                        submenu = {
                            {
                                label = 'Pistol',
                                type = 'button',
                                icon = 'fas fa-gun',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Pistol</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'Combat Pistol',
                                type = 'button',
                                icon = 'fas fa-gun',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_COMBATPISTOL'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Combat Pistol</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'AP Pistol',
                                type = 'button',
                                icon = 'fas fa-gun',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_APPISTOL'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">AP Pistol</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'Heavy Pistol',
                                type = 'button',
                                icon = 'fas fa-gun',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_HEAVYPISTOL'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Heavy Pistol</span>",
                                        type = 'success'
                                    }))
                                end
                            }
                        }
                    },
                    {
                        label = 'Rifles',
                        type = 'submenu',
                        icon = 'fas fa-crosshairs',
                        submenu = {
                            {
                                label = 'Assault Rifle',
                                type = 'button',
                                icon = 'fas fa-crosshairs',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_ASSAULTRIFLE'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Assault Rifle</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'Carbine Rifle',
                                type = 'button',
                                icon = 'fas fa-crosshairs',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_CARBINERIFLE'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Carbine Rifle</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'Special Carbine',
                                type = 'button',
                                icon = 'fas fa-crosshairs',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_SPECIALCARBINE'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Special Carbine</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'Bullpup Rifle',
                                type = 'button',
                                icon = 'fas fa-crosshairs',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_BULLPUPRIFLE'), 250, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Bullpup Rifle</span>",
                                        type = 'success'
                                    }))
                                end
                            }
                        }
                    },
                    {
                        label = 'Heavy Weapons',
                        type = 'submenu',
                        icon = 'fas fa-bomb',
                        submenu = {
                            {
                                label = 'RPG',
                                type = 'button',
                                icon = 'fas fa-rocket',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_RPG'), 10, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">RPG</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'Minigun',
                                type = 'button',
                                icon = 'fas fa-bomb',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_MINIGUN'), 1000, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Minigun</span>",
                                        type = 'success'
                                    }))
                                end
                            },
                            {
                                label = 'Grenade Launcher',
                                type = 'button',
                                icon = 'fas fa-bomb',
                                onConfirm = function()
                                    local ped = PlayerPedId()
                                    GiveWeaponToPed(ped, GetHashKey('WEAPON_GRENADELAUNCHER'), 25, false, true)
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Gave <span class=\"notification-key\">Grenade Launcher</span>",
                                        type = 'success'
                                    }))
                                end
                            }
                        }
                    }
                }
            },
            {
                label = 'Remove All Weapons',
                type = 'button',
                icon = 'fas fa-trash',
                onConfirm = function()
                    local ped = PlayerPedId()
                    RemoveAllPedWeapons(ped, true)
                    SendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Removed <span class=\"notification-key\">ALL WEAPONS</span>",
                        type = 'success'
                    }))
                end
            },
            {
                label = 'Infinite Ammo',
                type = 'checkbox',
                icon = 'fas fa-infinity',
                checked = false,
                onConfirm = function(toggle)
                    if toggle then
                        CreateThread(function()
                            while true do
                                local ped = PlayerPedId()
                                local weapon = GetSelectedPedWeapon(ped)
                                if weapon ~= GetHashKey('WEAPON_UNARMED') then
                                    SetPedAmmo(ped, weapon, 999)
                                end
                                Wait(100)
                            end
                        end)
                    end
                    SendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Infinite Ammo: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                        type = toggle and 'success' or 'info'
                    }))
                end
            },
            {
                label = 'No Reload',
                type = 'checkbox',
                icon = 'fas fa-sync-alt',
                checked = false,
                onConfirm = function(toggle)
                    local ped = PlayerPedId()
                    if toggle then
                        SetPedInfiniteAmmo(ped, true)
                        SetPedInfiniteAmmoClip(ped, true)
                    else
                        SetPedInfiniteAmmo(ped, false)
                        SetPedInfiniteAmmoClip(ped, false)
                    end
                    SendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "No Reload: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                        type = toggle and 'success' or 'info'
                    }))
                end
            }
        }
    },
    {
        label = "World",
        type = 'submenu',
        icon = 'fas fa-globe',
        submenu = {
            {
                label = 'Weather',
                type = 'submenu',
                icon = 'fas fa-cloud-sun',
                submenu = {
                    {
                        label = 'Clear',
                        type = 'button',
                        icon = 'fas fa-sun',
                        onConfirm = function()
                            SetWeatherTypeNow('CLEAR')
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Weather set to <span class=\"notification-key\">CLEAR</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Rain',
                        type = 'button',
                        icon = 'fas fa-cloud-rain',
                        onConfirm = function()
                            SetWeatherTypeNow('RAIN')
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Weather set to <span class=\"notification-key\">RAIN</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Thunder',
                        type = 'button',
                        icon = 'fas fa-bolt',
                        onConfirm = function()
                            SetWeatherTypeNow('THUNDER')
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Weather set to <span class=\"notification-key\">THUNDER</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Fog',
                        type = 'button',
                        icon = 'fas fa-smog',
                        onConfirm = function()
                            SetWeatherTypeNow('FOGGY')
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Weather set to <span class=\"notification-key\">FOG</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Snow',
                        type = 'button',
                        icon = 'fas fa-snowflake',
                        onConfirm = function()
                            SetWeatherTypeNow('SNOW')
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Weather set to <span class=\"notification-key\">SNOW</span>",
                                type = 'success'
                            }))
                        end
                    }
                }
            },
            {
                label = 'Time',
                type = 'submenu',
                icon = 'fas fa-clock',
                submenu = {
                    {
                        label = 'Dawn (6 AM)',
                        type = 'button',
                        icon = 'fas fa-sun',
                        onConfirm = function()
                            NetworkOverrideClockTime(6, 0, 0)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Time set to <span class=\"notification-key\">6:00 AM</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Morning (9 AM)',
                        type = 'button',
                        icon = 'fas fa-sun',
                        onConfirm = function()
                            NetworkOverrideClockTime(9, 0, 0)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Time set to <span class=\"notification-key\">9:00 AM</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Noon (12 PM)',
                        type = 'button',
                        icon = 'fas fa-sun',
                        onConfirm = function()
                            NetworkOverrideClockTime(12, 0, 0)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Time set to <span class=\"notification-key\">12:00 PM</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Evening (6 PM)',
                        type = 'button',
                        icon = 'fas fa-moon',
                        onConfirm = function()
                            NetworkOverrideClockTime(18, 0, 0)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Time set to <span class=\"notification-key\">6:00 PM</span>",
                                type = 'success'
                            }))
                        end
                    },
                    {
                        label = 'Night (12 AM)',
                        type = 'button',
                        icon = 'fas fa-moon',
                        onConfirm = function()
                            NetworkOverrideClockTime(0, 0, 0)
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Time set to <span class=\"notification-key\">12:00 AM</span>",
                                type = 'success'
                            }))
                        end
                    }
                }
            },
            {
                label = 'Gravity',
                type = 'slider',
                icon = 'fas fa-feather',
                min = 0,
                max = 200,
                value = 100,
                step = 10,
                onConfirm = function(val)
                    local gravity = val / 100.0
                    SetGravityLevel(gravity)
                    SendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Gravity set to <span class=\"notification-key\">" .. val .. "%</span>",
                        type = 'success'
                    }))
                end
            },
            {
                label = 'Time Scale',
                type = 'slider',
                icon = 'fas fa-tachometer-alt',
                min = 0,
                max = 200,
                value = 100,
                step = 10,
                onConfirm = function(val)
                    local timeScale = val / 100.0
                    SetTimeScale(timeScale)
                    SendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Time Scale set to <span class=\"notification-key\">" .. val .. "%</span>",
                        type = 'success'
                    }))
                end
            }
        }
    },
    {
        label = "Online Players",
        type = 'submenu',
        icon = 'fas fa-users',
        submenu = createPlayerListSubmenu()
    },
    {
        label = "Vehicles",
        type = 'submenu',
        icon = 'fas fa-car',
        submenu = {
            {
                label = 'Spawner',
                type = 'submenu',
                icon = 'fas fa-plus-circle',
                submenu = {
                    {
                        label = 'Spawn Settings',
                        type = 'submenu',
                        icon = 'fas fa-cog',
                        submenu = {
                            {
                                label = 'Spawn in Vehicle',
                                type = 'checkbox',
                                icon = 'fas fa-car',
                                checked = true,
                                onConfirm = function(toggle)
                                    _G.spawnInVehicle = toggle
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Spawn in Vehicle: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                        type = toggle and 'success' or 'info'
                                    }))
                                end
                            },
                            {
                                label = 'Max Out on Spawn',
                                type = 'checkbox',
                                icon = 'fas fa-tachometer-alt',
                                checked = false,
                                onConfirm = function(toggle)
                                    _G.maxOutOnSpawn = toggle
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Max Out on Spawn: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                        type = toggle and 'success' or 'info'
                                    }))
                        end
                    },
                    {
                                label = 'Easy Handling on Spawn',
                        type = 'checkbox',
                                icon = 'fas fa-car-crash',
                        checked = false,
                        onConfirm = function(toggle)
                                    _G.easyHandlingOnSpawn = toggle
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "Easy Handling on Spawn: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                        type = toggle and 'success' or 'info'
                                    }))
                                end
                            },
                            {
                                label = 'God Mode on Spawn',
                                type = 'checkbox',
                                icon = 'fas fa-shield-alt',
                                checked = false,
                                onConfirm = function(toggle)
                                    _G.godModeOnSpawn = toggle
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "God Mode on Spawn: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                        type = toggle and 'success' or 'info'
                                    }))
                                end
                            }
                        }
                    },
                    {
                        label = 'Supercars',
                        type = 'submenu',
                        icon = 'fas fa-bolt',
                        submenu = {
                            {
                                label = 'Adder',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('adder')
                                end
                            },
                            {
                                label = 'Zentorno',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('zentorno')
                                end
                            },
                            {
                                label = 'T20',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('t20')
                                end
                            },
                            {
                                label = 'Osiris',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('osiris')
                                end
                            },
                            {
                                label = 'Entity XF',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('entityxf')
                                end
                            },
                            {
                                label = 'Cheetah',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('cheetah')
                                end
                            },
                            {
                                label = 'Vacca',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('vacca')
                                end
                            },
                            {
                                label = 'Voltic',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('voltic')
                                end
                            },
                            {
                                label = 'Infernus',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('infernus')
                                end
                            },
                            {
                                label = 'Banshee',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('banshee')
                        end
                    }
                }
            },
            {
                        label = 'Sports Cars',
                type = 'submenu',
                        icon = 'fas fa-car-side',
                        submenu = {
                            {
                                label = 'Elegy RH8',
                                type = 'button',
                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('elegy2')
                                end
                            },
                            {
                                label = 'Sultan',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('sultan')
                                end
                            },
                            {
                                label = 'Futo',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('futo')
                                end
                            },
                            {
                                label = 'Comet',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('comet2')
                                end
                            },
                            {
                                label = 'Carbonizzare',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('carbonizzare')
                                end
                            },
                            {
                                label = 'Blista',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('blista')
                                end
                            },
                            {
                                label = 'Penumbra',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('penumbra')
                                end
                            },
                            {
                                label = 'Fusilade',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('fusilade')
                                end
                            },
                            {
                                label = 'Feltzer',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('feltzer2')
                                end
                            },
                            {
                                label = 'Surano',
                                type = 'button',
                                icon = 'fas fa-car',
                                onConfirm = function()
                                    spawnVehicle('surano')
                                end
                            }
                        }
                    },
                    {
                        label = 'Military',
                        type = 'submenu',
                        icon = 'fas fa-shield-alt',
                        submenu = {
                            {
                                label = 'Insurgent',
                                type = 'button',
                                icon = 'fas fa-truck-monster',
                                onConfirm = function()
                                    spawnVehicle('insurgent')
                                end
                            },
                            {
                                label = 'Kuruma (Armored)',
                                type = 'button',
                                icon = 'fas fa-shield',
                                onConfirm = function()
                                    spawnVehicle('kuruma')
                                end
                            },
                            {
                                label = 'Rhino Tank',
                                type = 'button',
                                icon = 'fas fa-truck-monster',
                                onConfirm = function()
                                    spawnVehicle('rhino')
                                end
                            },
                            {
                                label = 'Lazer',
                                type = 'button',
                                icon = 'fas fa-plane',
                                onConfirm = function()
                                    spawnVehicle('lazer')
                                end
                            },
                            {
                                label = 'Hydra',
                                type = 'button',
                                icon = 'fas fa-plane',
                                onConfirm = function()
                                    spawnVehicle('hydra')
                                end
                            },
                            {
                                label = 'Savage',
                                type = 'button',
                                icon = 'fas fa-helicopter',
                                onConfirm = function()
                                    spawnVehicle('savage')
                                end
                            },
                            {
                                label = 'Buzzard',
                                type = 'button',
                                icon = 'fas fa-helicopter',
                                onConfirm = function()
                                    spawnVehicle('buzzard2')
                                end
                            },
                            {
                                label = 'Valkyrie',
                                type = 'button',
                                icon = 'fas fa-helicopter',
                                onConfirm = function()
                                    spawnVehicle('valkyrie')
                                end
                            },
                            {
                                label = 'Technical',
                                type = 'button',
                                icon = 'fas fa-truck',
                                onConfirm = function()
                                    spawnVehicle('technical')
                                end
                            },
                            {
                                label = 'Barracks',
                                type = 'button',
                                icon = 'fas fa-truck',
                                onConfirm = function()
                                    spawnVehicle('barracks')
                                end
                            }
                        }
                    },
                    {
                        label = 'Motorcycles',
                        type = 'submenu',
                        icon = 'fas fa-motorcycle',
                        submenu = {
                            {
                                label = 'Bati 801',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('bati')
                                end
                            },
                            {
                                label = 'Akuma',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('akuma')
                                end
                            },
                            {
                                label = 'Double T',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('double')
                                end
                            },
                            {
                                label = 'PCJ-600',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('pcj')
                                end
                            },
                            {
                                label = 'Sanchez',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('sanchez')
                                end
                            },
                            {
                                label = 'Vader',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('vader')
                                end
                            },
                            {
                                label = 'Nemesis',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('nemesis')
                                end
                            },
                            {
                                label = 'Faggio',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('faggio')
                                end
                            },
                            {
                                label = 'Enduro',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('enduro')
                                end
                            },
                            {
                                label = 'Carbon RS',
                                type = 'button',
                                icon = 'fas fa-motorcycle',
                                onConfirm = function()
                                    spawnVehicle('carbonrs')
                                end
                            }
                        }
                    }
                }
            },
            {
                label = 'Modifiers',
                type = 'submenu',
                icon = 'fas fa-wrench',
                submenu = {
                    {
                        label = 'Quick Actions',
                        type = 'submenu',
                        icon = 'fas fa-bolt',
                submenu = {
                    {
                        label = 'Repair Vehicle',
                        type = 'button',
                                icon = 'fas fa-tools',
                        onConfirm = function()
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                SetVehicleFixed(vehicle)
                                SetVehicleDeformationFixed(vehicle)
                                SetVehicleUndriveable(vehicle, false)
                                        SetVehicleEngineOn(vehicle, true, true)
                                        
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                            message = "Vehicle <span class=\"notification-key\">REPAIRED</span>",
                                        type = 'success'
                                    }))
                            else
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "You must be in a vehicle!",
                                        type = 'error'
                                    }))
                            end
                        end
                    },
                    {
                                label = 'Max Performance',
                        type = 'button',
                                icon = 'fas fa-tachometer-alt',
                        onConfirm = function()
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                        maxOutVehicle(vehicle)
                                        
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                            message = "Vehicle <span class=\"notification-key\">MAXED OUT</span>",
                                        type = 'success'
                                    }))
                            else
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "You must be in a vehicle!",
                                        type = 'error'
                                    }))
                            end
                        end
                    },
                    {
                                label = 'Easy Handling',
                        type = 'button',
                                icon = 'fas fa-car-crash',
                        onConfirm = function()
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                        applyEasyHandling(vehicle)
                                        
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                            message = "Easy Handling <span class=\"notification-key\">APPLIED</span>",
                                        type = 'success'
                                    }))
                            else
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "You must be in a vehicle!",
                                        type = 'error'
                                    }))
                            end
                        end
                    },
                    {
                                label = 'Delete Vehicle',
                        type = 'button',
                                icon = 'fas fa-trash',
                        onConfirm = function()
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                        DeleteEntity(vehicle)
                                        
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                            message = "Vehicle <span class=\"notification-key\">DELETED</span>",
                                        type = 'success'
                                    }))
                            else
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                        message = "You must be in a vehicle!",
                                        type = 'error'
                                    }))
                            end
                        end
                    }
                }
            },
            {
                        label = 'Performance Mods',
                type = 'submenu',
                        icon = 'fas fa-tachometer-alt',
                submenu = {
                    {
                                label = 'Engine',
                                type = 'slider',
                                icon = 'fas fa-cog',
                                min = -1,
                                max = 3,
                                value = -1,
                                step = 1,
                                onConfirm = function(val)
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if vehicle ~= 0 then
                                        SetVehicleModKit(vehicle, 0)
                                        SetVehicleMod(vehicle, 11, val, false)
                                        
                                        local modName = val == -1 and "Stock" or "Level " .. (val + 1)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                            message = "Engine: <span class=\"notification-key\">" .. modName .. "</span>",
                                    type = 'success'
                                }))
                                    else
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                            message = "You must be in a vehicle!",
                                            type = 'error'
                                }))
                            end
                        end
                    },
                    {
                                label = 'Brakes',
                                type = 'slider',
                                icon = 'fas fa-stop-circle',
                                min = -1,
                                max = 3,
                                value = -1,
                                step = 1,
                                onConfirm = function(val)
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if vehicle ~= 0 then
                                        SetVehicleModKit(vehicle, 0)
                                        SetVehicleMod(vehicle, 12, val, false)
                                        
                                        local modName = val == -1 and "Stock" or "Level " .. (val + 1)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                            message = "Brakes: <span class=\"notification-key\">" .. modName .. "</span>",
                                    type = 'success'
                                }))
                                    else
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                            message = "You must be in a vehicle!",
                                            type = 'error'
                                }))
                            end
                        end
                    },
                    {
                                label = 'Transmission',
                                type = 'slider',
                                icon = 'fas fa-exchange-alt',
                                min = -1,
                                max = 2,
                                value = -1,
                                step = 1,
                                onConfirm = function(val)
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if vehicle ~= 0 then
                                        SetVehicleModKit(vehicle, 0)
                                        SetVehicleMod(vehicle, 13, val, false)
                                        
                                        local modName = val == -1 and "Stock" or "Level " .. (val + 1)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                            message = "Transmission: <span class=\"notification-key\">" .. modName .. "</span>",
                                    type = 'success'
                                }))
                                    else
                                        SendDuiMessage(dui, json.encode({
                                            action = 'notify',
                                            message = "You must be in a vehicle!",
                                            type = 'error'
                                }))
                            end
                        end
                            },
                            {
                                label = 'Suspension',
                                type = 'slider',
                                icon = 'fas fa-compress-arrows-alt',
                                min = -1,
                                max = 3,
                                value = -1,
                                step = 1,
                                onConfirm = function(val)
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if vehicle ~= 0 then
                                        SetVehicleModKit(vehicle, 0)
                                        SetVehicleMod(vehicle, 15, val, false)
                                        
                                        local modName = val == -1 and "Stock" or "Level " .. (val + 1)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                            message = "Suspension: <span class=\"notification-key\">" .. modName .. "</span>",
                                    type = 'success'
                                }))
                                    else
                                        SendDuiMessage(dui, json.encode({
                                            action = 'notify',
                                            message = "You must be in a vehicle!",
                                            type = 'error'
                                }))
                            end
                        end
                    },
                    {
                                label = 'Armor',
                                type = 'slider',
                                icon = 'fas fa-shield-alt',
                                min = -1,
                                max = 4,
                                value = -1,
                                step = 1,
                                onConfirm = function(val)
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if vehicle ~= 0 then
                                        SetVehicleModKit(vehicle, 0)
                                        SetVehicleMod(vehicle, 16, val, false)
                                        
                                        local modName = val == -1 and "Stock" or "Level " .. (val + 1)
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                            message = "Armor: <span class=\"notification-key\">" .. modName .. "</span>",
                                    type = 'success'
                                }))
                                    else
                                        SendDuiMessage(dui, json.encode({
                                            action = 'notify',
                                            message = "You must be in a vehicle!",
                                            type = 'error'
                                }))
                            end
                        end
                    },
                    {
                                label = 'Turbo',
                        type = 'checkbox',
                                icon = 'fas fa-wind',
                        checked = false,
                        onConfirm = function(toggle)
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if vehicle ~= 0 then
                                        SetVehicleModKit(vehicle, 0)
                                        ToggleVehicleMod(vehicle, 18, toggle)
                                        
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                            message = "Turbo: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                            type = toggle and 'success' or 'info'
                                    }))
                            else
                                    SendDuiMessage(dui, json.encode({
                                        action = 'notify',
                                            message = "You must be in a vehicle!",
                                            type = 'error'
                                    }))
                                end
                            end
                            }
                        }
                    },
                    {
                        label = 'Visual Mods',
                        type = 'submenu',
                        icon = 'fas fa-paint-brush',
                        submenu = {
                    createSmartVehicleModSlider('Spoiler', 'fas fa-car', 0),
                    createSmartVehicleModSlider('Front Bumper', 'fas fa-car', 1),
                    createSmartVehicleModSlider('Rear Bumper', 'fas fa-car', 2),
                    createSmartVehicleModSlider('Side Skirt', 'fas fa-car', 3),
                    createSmartVehicleModSlider('Exhaust', 'fas fa-car', 4),
                    createSmartVehicleModSlider('Roll Cage', 'fas fa-car', 5),
                    createSmartVehicleModSlider('Grille', 'fas fa-car', 6),
                    createSmartVehicleModSlider('Hood', 'fas fa-car', 7),
                    createSmartVehicleModSlider('Fender', 'fas fa-car', 8),
                    createSmartVehicleModSlider('Right Fender', 'fas fa-car', 9),
                    createSmartVehicleModSlider('Roof', 'fas fa-car', 10),
                    createSmartVehicleModSlider('Horns', 'fas fa-car', 14)
                        }
                    }
        }
    },
    {
                label = 'Utilities',
        type = 'submenu',
                icon = 'fas fa-tools',
        submenu = {
            {
                        label = 'Speed Boost',
                        type = 'slider',
                        icon = 'fas fa-rocket',
                        min = 0,
                        max = 500,
                        value = 100,
                        step = 10,
                        onConfirm = function(val)
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                local speedMultiplier = val / 100.0
                                SetVehicleEnginePowerMultiplier(vehicle, speedMultiplier)
                                SetVehicleEngineTorqueMultiplier(vehicle, speedMultiplier)
                                
                            SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Speed Boost: <span class=\"notification-key\">" .. val .. "%</span>",
                                    type = 'success'
                                }))
                            else
                            SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "You must be in a vehicle!",
                                    type = 'error'
                                }))
                    end
                end
            },
            {
                        label = 'Gravity',
                        type = 'slider',
                        icon = 'fas fa-feather',
                        min = 0,
                        max = 200,
                        value = 100,
                        step = 10,
                        onConfirm = function(val)
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                local gravityMultiplier = val / 100.0
                                SetVehicleGravity(vehicle, gravityMultiplier)
                                
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Gravity: <span class=\"notification-key\">" .. val .. "%</span>",
                                    type = 'success'
                                }))
                            else
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "You must be in a vehicle!",
                                    type = 'error'
                                }))
                            end
                        end
                    },
                    {
                        label = 'Invisible Vehicle',
                        type = 'checkbox',
                        icon = 'fas fa-eye-slash',
                        checked = false,
                        onConfirm = function(toggle)
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                SetEntityVisible(vehicle, not toggle, 0)
                                
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Invisible Vehicle: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                    type = toggle and 'success' or 'info'
                                }))
                            else
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "You must be in a vehicle!",
                                    type = 'error'
                                }))
                            end
                        end
                    },
                    {
                        label = 'God Mode Vehicle',
                        type = 'checkbox',
                        icon = 'fas fa-shield-alt',
                        checked = false,
                        onConfirm = function(toggle)
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                SetEntityInvincible(vehicle, toggle)
                                SetVehicleCanBeVisiblyDamaged(vehicle, not toggle)
                                SetVehicleCanBreak(vehicle, not toggle)
                                
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "God Mode Vehicle: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                    type = toggle and 'success' or 'info'
                                }))
                            else
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "You must be in a vehicle!",
                                    type = 'error'
                                }))
                            end
                        end
                    },
                    {
                        label = 'No Collision',
                        type = 'checkbox',
                        icon = 'fas fa-ghost',
                        checked = false,
                        onConfirm = function(toggle)
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                SetEntityCollision(vehicle, not toggle, not toggle)
                                
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "No Collision: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                    type = toggle and 'success' or 'info'
                                }))
                            else
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "You must be in a vehicle!",
                                    type = 'error'
                                }))
                            end
                        end
                    },
                    {
                        label = 'Freeze Vehicle',
                        type = 'checkbox',
                        icon = 'fas fa-pause',
                        checked = false,
                        onConfirm = function(toggle)
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                FreezeEntityPosition(vehicle, toggle)
                                
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Freeze Vehicle: <span class=\"notification-key\">" .. (toggle and "ON" or "OFF") .. "</span>",
                                    type = toggle and 'success' or 'info'
                                }))
                            else
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "You must be in a vehicle!",
                                    type = 'error'
                                }))
                            end
                        end
                    }
                }
            }
        }
    },
    {
        -- settings menu
        label = "Settings",
        type = 'submenu',
        icon = 'fas fa-cog',
        submenu = {
            --  {
            --     label = "Themes",
            --     type = 'scroll',
            --     icon = 'fas fa-palette',
            --     selected = -1, -- <- was 1, made 0 for zero-based widgets
            --     options = {
            --       { label = "Default", value = "blue", banner = "https://downloads.replix.xyz/replixblue.png" },
            --       { label = "Purple",  value = "purple", banner = "https://downloads.replix.xyz/REPLIX_BANNER.gif" },
            --       { label = "Pink",    value = "pink", banner = "https://downloads.replix.xyz/replixpink.gif" },
            --       { label = "Orange",  value = "orange", banner = "https://downloads.replix.xyz/replixorange.gif" },
            --       { label = "Dark",    value = "dark", banner = "https://downloads.replix.xyz/REPLIX_BANNER.png" },
            --       { label = "Green",   value = "green", banner = "https://downloads.replix.xyz/REPLIX_BANNER.png" },
            --       { label = "Red",     value = "red", banner = "https://downloads.replix.xyz/REPLIX_BANNER.png" },
            --     },
            --     onConfirm = function(selectedOption)
            --         if selectedOption and selectedOption.value then
            --             print("Selected theme:", selectedOption.value)
            --             print("Banner URL:", selectedOption.banner)
            --             SendDuiMessage(dui, json.encode({
            --                 action = 'setTheme',
            --                 theme = selectedOption.value
            --             }))
            --             SendDuiMessage(dui, json.encode({
            --                 action = 'setBannerImage',
            --                 url = selectedOption.banner
            --             }))
            --         else
            --             print("Error: selectedOption is nil or missing value")
            --         end
            --     end
            -- },
            {
                label = "Theme Switcher",
                type = 'submenu',
                icon = 'fas fa-palette',
                submenu = {
                    {
                        label = 'Default Theme',
                        type = 'button',
                        onConfirm = function()
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'setTheme',
                                    theme = 'blue'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'setBannerImage',
                                    url = 'https://share.creavite.co/68dbd8fb377d6e26798ddcd0.gif'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Theme changed to <span class=\"notification-key\">Blue</span>",
                                    type = 'success'
                                }))
                            end
                        end
                    },
                    {
                        label = 'Purple Theme',
                        type = 'button',
                        onConfirm = function()
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'setTheme',
                                    theme = 'purple'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'setBannerImage',
                                    url = 'https://share.creavite.co/68dbd7c8377d6e26798ddcce.gif'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Theme changed to <span class=\"notification-key\">Purple</span>",
                                    type = 'success'
                                }))
                            end
                        end
                    },
                    {
                        label = 'Orange Theme',
                        type = 'button',
                        onConfirm = function()
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'setTheme',
                                    theme = 'orange'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'setBannerImage',
                                    url = 'https://share.creavite.co/68dbd8a6377d6e26798ddccf.gif'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Theme changed to <span class=\"notification-key\">Orange</span>",
                                    type = 'success'
                                }))
                            end
                        end
                    },
                    -- pink theme
                    {
                        label = 'Pink Theme',
                        type = 'button',
                        onConfirm = function()
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'setTheme',
                                    theme = 'pink'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'setBannerImage',
                                    url = 'https://downloads.replix.xyz/replixpink.gif'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Theme changed to <span class=\"notification-key\">Pink</span>",
                                    type = 'success'
                                }))
                            end
                        end
                    },
                    -- dark theme
                    {
                        label = 'Dark Theme',
                        type = 'button',
                        onConfirm = function()
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'setTheme',
                                    theme = 'dark'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'setBannerImage',
                                    url = 'https://downloads.replix.xyz/replixgrey.png'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Theme changed to <span class=\"notification-key\">Dark</span>",
                                    type = 'success'
                                }))
                            end
                        end
                    },
                    -- red theme
                    {
                        label = 'Red Theme',
                        type = 'button',
                        onConfirm = function()
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'setTheme',
                                    theme = 'red'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'setBannerImage',
                                    url = 'https://downloads.replix.xyz/replixred.gif'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Theme changed to <span class=\"notification-key\">Red</span>",
                                    type = 'success'
                                }))
                            end
                        end
                    }
                }
            },
        }
    }
}

activeMenu = originalMenu


-- Safe copy for DUI
local function safeMenuCopy(menu)
    local copy = {}
    for i, v in ipairs(menu) do
        local item = {
            label = v.label or "",
            type = v.type or ""
        }
        if v.icon then item.icon = v.icon end

        if v.type == "scroll" then
            item.options = {}
            for _, opt in ipairs(v.options or {}) do
                if type(opt) == "table" then
                    table.insert(item.options, {
                        label = tostring(opt.label or ""),
                        value = tostring(opt.value or "")
                    })
                else
                    table.insert(item.options, tostring(opt))
                end
            end
            item.selected = v.selected or 1
        elseif v.type == "slider" then
            item.min = v.min or 0
            item.max = v.max or 100
            item.value = v.value or 50
            item.step = v.step or 1
        elseif v.type == "checkbox" then
            item.checked = v.checked or false
        elseif v.type == "submenu" then
            item.submenu = safeMenuCopy(v.submenu or {})
        end

        table.insert(copy, item)
    end
    return copy
end

-- Initialize PlayerList menu with current players
updatePlayerlistData()

-- Thread to update playerlist data periodically (from replix_main.lua)
CreateThread(function()
    while true do
        Wait(5000) -- Update every 5 seconds
        if _G.clientMenuShowing then
            updatePlayerlistData()
            -- Send updated data to NUI
            if dui then
                SendDuiMessage(dui, json.encode({
                    action = 'setCurrent',
                    current = activeIndex,
                    menu = safeMenuCopy(activeMenu)
                }))
            end
        end
    end
end)

-- Thread to update selected player data in real-time
CreateThread(function()
    while true do
        Wait(500) -- Update every 500ms
        if _G.clientMenuShowing and currentSelectedPlayer then
            -- Get fresh player data
            local freshPlayerData = nil
            local players = getRealPlayerData()
            
            -- Find the current selected player in the fresh data
            for _, player in ipairs(players) do
                if player.id == currentSelectedPlayer.id then
                    freshPlayerData = player
                    break
                end
            end
            
            -- Update the selected player data if found
            if freshPlayerData then
                currentSelectedPlayer = freshPlayerData
                -- Send updated player data to frontend
                if dui then
                    SendDuiMessage(dui, json.encode({
                        action = 'setSelectedPlayer',
                        playerData = currentSelectedPlayer
                    }))
                end
            end
        elseif not _G.clientMenuShowing and currentSelectedPlayer then
            -- Clear selected player when menu is hidden
            currentSelectedPlayer = nil
            if dui then
                SendDuiMessage(dui, json.encode({
                    action = 'setSelectedPlayer',
                    playerData = nil
                }))
            end
        end
    end
end)

function setCurrent()
    if dui and menuInitialized then
        -- Sending setCurrent message
        SendDuiMessage(dui, json.encode({
            action = 'setCurrent',
            current = activeIndex,
            menu = safeMenuCopy(activeMenu)
        }))
    else
        -- setCurrent failed
    end
end

local function isControlJustPressed(control)
    return IsControlJustPressed(0, control) or IsDisabledControlJustPressed(0, control)
end

local function initializeMenu()
    if not menuInitialized and dui then
        menuInitialized = true
        activeMenu = originalMenu
        activeIndex = 1
        
        -- Initializing menu
        SendDuiMessage(dui, json.encode({
            action = 'setFooterText',
            text = 'Alisomali is tuff'
        }))
        -- Show menu based on current state
        SendDuiMessage(dui, json.encode({
            action = 'setMenuVisible',
            visible = _G.clientMenuShowing
        }))
        
        setCurrent()
        -- Menu initialization complete
    end
end

-- Make these global so they can be accessed from different threads
_G.keybindSetupActive = false
_G.inputRecordingActive = false
_G.inputBuffer = ""
_G.inputMaxLength = 100

-- Player info management variables
currentSelectedPlayer = nil
nestedMenus = {}

-- Function to send selected player data to NUI
function sendSelectedPlayerData()
    if not dui or not menuInitialized then return end
    
    local currentItem = activeMenu[activeIndex]
    if not currentItem then return end
    
    -- Check if we're on a player submenu item
    if currentItem.playerData then
        currentSelectedPlayer = currentItem.playerData
        SendDuiMessage(dui, json.encode({
            action = 'setSelectedPlayer',
            playerData = currentItem.playerData
        }))
    -- Check if we're on the PlayerList main menu
    elseif currentItem.label == 'PlayerList' and currentItem.type == 'submenu' and currentItem.submenu and #currentItem.submenu > 0 then
        -- Auto-select first player when on PlayerList main menu
        local firstPlayerItem = currentItem.submenu[1]
        if firstPlayerItem.playerData then
            currentSelectedPlayer = firstPlayerItem.playerData
            SendDuiMessage(dui, json.encode({
                action = 'setSelectedPlayer',
                playerData = firstPlayerItem.playerData
            }))
        end
    -- Check if we're in a player's submenu (actions like Teleport, Bring, etc.)
    elseif currentSelectedPlayer and isInPlayerSubmenu() then
        -- Keep the selected player when in their submenu
        SendDuiMessage(dui, json.encode({
            action = 'setSelectedPlayer',
            playerData = currentSelectedPlayer
        }))
    -- Fallback: if we have a selected player and we're in any submenu, keep it
    elseif currentSelectedPlayer and #nestedMenus > 0 then
        -- Keep the selected player when in any submenu if we have one selected
        SendDuiMessage(dui, json.encode({
            action = 'setSelectedPlayer',
            playerData = currentSelectedPlayer
        }))
    else
        -- Clear selected player when not on any player-related menu
        currentSelectedPlayer = nil
        SendDuiMessage(dui, json.encode({
            action = 'setSelectedPlayer',
            playerData = nil
        }))
    end
end

-- Function to check if we're currently in a player's submenu
function isInPlayerSubmenu()
    -- Check if any of the nested menus contain player data
    for i = 1, #nestedMenus do
        local nestedMenu = nestedMenus[i]
        if nestedMenu.menu and nestedMenu.menu[nestedMenu.index] then
            local menuItem = nestedMenu.menu[nestedMenu.index]
            if menuItem.playerData then
                return true
            end
        end
    end

    -- Also check if we're in a submenu that was created from a player item
    -- This handles the case where we entered a player's submenu from PlayerList
    if #nestedMenus > 0 then
        local lastNestedMenu = nestedMenus[#nestedMenus]
        if lastNestedMenu.menu and lastNestedMenu.menu[lastNestedMenu.index] then
            local parentItem = lastNestedMenu.menu[lastNestedMenu.index]
            if parentItem.playerData then
                return true
            end
        end
    end

    return false
end

-- Function to handle input key recording
local function handleInputKeyRecording()
    if not _G.inputRecordingActive then return end
    
    -- Disable game controls during text input to prevent interference
    DisableAllControlActions(0)
    EnableControlAction(0, 1, true) -- Mouse
    EnableControlAction(0, 2, true) -- Mouse wheel
    
    -- Specifically disable ESC and BACKSPACE to prevent menu/pause interference
    DisableControlAction(0, 322, true) -- ESC
    DisableControlAction(0, 177, true) -- BACKSPACE
    
    -- Key mapping for input
    local inputKeyMap = {
        ["A"] = "a", ["B"] = "b", ["C"] = "c", ["D"] = "d", ["E"] = "e", ["F"] = "f", ["G"] = "g", ["H"] = "h",
        ["I"] = "i", ["J"] = "j", ["K"] = "k", ["L"] = "l", ["M"] = "m", ["N"] = "n", ["O"] = "o", ["P"] = "p",
        ["Q"] = "q", ["R"] = "r", ["S"] = "s", ["T"] = "t", ["U"] = "u", ["V"] = "v", ["W"] = "w", ["X"] = "x",
        ["Y"] = "y", ["Z"] = "z",
        ["1"] = "1", ["2"] = "2", ["3"] = "3", ["4"] = "4", ["5"] = "5", ["6"] = "6", ["7"] = "7", ["8"] = "8", ["9"] = "9", ["0"] = "0",
        ["SPACE"] = " ", ["-"] = "-", ["="] = "=", ["["] = "[", ["]"] = "]", ["\\"] = "\\", [";"] = ";", ["'"] = "'",
        [","] = ",", ["."] = ".", ["/"] = "/", ["`"] = "`"
    }
    
    for keyName, char in pairs(inputKeyMap) do
        local controlId = nil
        -- Map key names to control IDs (correct FiveM control IDs)
        if keyName == "A" then controlId = 34
        elseif keyName == "B" then controlId = 29
        elseif keyName == "C" then controlId = 26
        elseif keyName == "D" then controlId = 9
        elseif keyName == "E" then controlId = 38
        elseif keyName == "F" then controlId = 23
        elseif keyName == "G" then controlId = 47
        elseif keyName == "H" then controlId = 74
        elseif keyName == "I" then controlId = 73
        elseif keyName == "J" then controlId = 74
        elseif keyName == "K" then controlId = 311
        elseif keyName == "L" then controlId = 182
        elseif keyName == "M" then controlId = 244
        elseif keyName == "N" then controlId = 249
        elseif keyName == "O" then controlId = 73
        elseif keyName == "P" then controlId = 199
        elseif keyName == "Q" then controlId = 44
        elseif keyName == "R" then controlId = 45
        elseif keyName == "S" then controlId = 8
        elseif keyName == "T" then controlId = 245
        elseif keyName == "U" then controlId = 73
        elseif keyName == "V" then controlId = 0
        elseif keyName == "W" then controlId = 32
        elseif keyName == "X" then controlId = 73
        elseif keyName == "Y" then controlId = 246
        elseif keyName == "Z" then controlId = 20
        elseif keyName == "1" then controlId = 157
        elseif keyName == "2" then controlId = 158
        elseif keyName == "3" then controlId = 160
        elseif keyName == "4" then controlId = 164
        elseif keyName == "5" then controlId = 165
        elseif keyName == "6" then controlId = 159
        elseif keyName == "7" then controlId = 161
        elseif keyName == "8" then controlId = 162
        elseif keyName == "9" then controlId = 163
        elseif keyName == "0" then controlId = 157
        elseif keyName == "SPACE" then controlId = 22
        elseif keyName == "-" then controlId = 84
        elseif keyName == "=" then controlId = 83
        elseif keyName == "[" then controlId = 39
        elseif keyName == "]" then controlId = 40
        elseif keyName == "\\" then controlId = 40
        elseif keyName == ";" then controlId = 40
        elseif keyName == "'" then controlId = 40
        elseif keyName == "," then controlId = 82
        elseif keyName == "." then controlId = 81
        elseif keyName == "/" then controlId = 81
        elseif keyName == "`" then controlId = 40
        end
        
        if controlId and (IsControlJustPressed(0, controlId) or IsDisabledControlJustPressed(0, controlId)) then
            -- Add character to buffer
            print("Lua: Character key pressed:", keyName, "char:", char, "controlId:", controlId)
            if #_G.inputBuffer < _G.inputMaxLength then
                _G.inputBuffer = _G.inputBuffer .. char
                print("Lua: Character added - new buffer:", _G.inputBuffer)
                SendDuiMessage(dui, json.encode({
                    action = 'updateTextInput',
                    value = _G.inputBuffer
                }))
            else
                print("Lua: Buffer is full, cannot add character")
            end
            break
        end
    end
    
    -- Check for special keys separately (ESC, ENTER, BACKSPACE)
    if IsControlJustPressed(0, 322) or IsDisabledControlJustPressed(0, 322) then -- ESC - Cancel input
        stopInputRecording()
        SendDuiMessage(dui, json.encode({
            action = 'cancelTextInput'
        }))
        -- Close the text input modal
        SendDuiMessage(dui, json.encode({
            action = 'closeTextInput'
        }))
        print("Lua: Input cancelled")
        -- Add a small delay to prevent menu from processing the same ESC press
        Wait(200)
        return
    elseif IsControlJustPressed(0, 18) or IsDisabledControlJustPressed(0, 18) then -- ENTER - Submit input
        stopInputRecording()
        
        -- Handle input submission
        if _G.inputCallback then
            -- Use callback function if provided
            _G.inputCallback(_G.inputBuffer)
        else
            -- Fallback to menu item handling
            local activeData = activeMenu[activeIndex]
            if activeData and activeData.type == 'input' then
                activeData.value = _G.inputBuffer
                setCurrent() -- Refresh the menu display
                
                -- Handle specific input types
                if activeData.originalLabel == 'Set Plate' then
                    -- Set the vehicle's license plate
                    local playerPed = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    
                    if vehicle ~= 0 then
                        -- Set the license plate text
                        SetVehicleNumberPlateText(vehicle, _G.inputBuffer)
                        
                        -- Send notification
                        if dui then
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "License plate set to: <span class=\"notification-key\">" .. _G.inputBuffer .. "</span>",
                                type = 'success'
                            }))
                        end
                        print("Lua: License plate set to:", _G.inputBuffer)
                    else
                        -- Player is not in a vehicle
                        if dui then
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "You must be in a vehicle to set the license plate!",
                                type = 'error'
                            }))
                        end
                        print("Lua: Player is not in a vehicle")
                    end
                elseif activeData.originalLabel == 'Enter Player Name' then
                    -- Handle player name input
                    if dui then
                        SendDuiMessage(dui, json.encode({
                            action = 'notify',
                            message = "Player name set to: <span class=\"notification-key\">" .. _G.inputBuffer .. "</span>",
                            type = 'success'
                        }))
                    end
                    print("Lua: Player name set to:", _G.inputBuffer)
                elseif activeData.originalLabel == 'Enter Money Amount' then
                    -- Handle money amount input
                    local amount = tonumber(_G.inputBuffer)
                    if amount then
                        if dui then
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Money amount set to: <span class=\"notification-key\">$" .. amount .. "</span>",
                                type = 'success'
                            }))
                        end
                        print("Lua: Money amount set to:", amount)
                    else
                        if dui then
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Invalid money amount!",
                                type = 'error'
                            }))
                        end
                        print("Lua: Invalid money amount")
                    end
                end
            end
        end
        
        -- Clear the callback
        _G.inputCallback = nil
        
        SendDuiMessage(dui, json.encode({
            action = 'submitTextInput',
            value = _G.inputBuffer
        }))
        print("Lua: Input submitted:", _G.inputBuffer)
        -- Wait a moment to show the submitted text before closing
        Wait(1000)
        -- Close the text input modal
        SendDuiMessage(dui, json.encode({
            action = 'closeTextInput'
        }))
        -- Add a small delay to prevent menu from processing the same ENTER press
        Wait(200)
        return
    elseif IsControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 177) then -- BACKSPACE - Remove last character
        print("Lua: BACKSPACE pressed, current buffer length:", #_G.inputBuffer)
        if #_G.inputBuffer > 0 then
            _G.inputBuffer = string.sub(_G.inputBuffer, 1, #_G.inputBuffer - 1)
            print("Lua: BACKSPACE - new buffer:", _G.inputBuffer)
            SendDuiMessage(dui, json.encode({
                action = 'updateTextInput',
                value = _G.inputBuffer
            }))
        else
            print("Lua: BACKSPACE - buffer is empty, nothing to delete")
        end
        return
    end
end

local function setupKeybind()
    if not keybindSetup and dui then
        keybindSetup = true
        keybindSetupActive = true
        
        -- Close the menu first
        SendDuiMessage(dui, json.encode({
            action = 'setMenuVisible',
            visible = false
        }))
        _G.clientMenuShowing = false
        
        -- Then open key selection
        SendDuiMessage(dui, json.encode({
            action = 'openKeySelection',
            title = 'Menu Keybind Setup',
            instruction = 'Press any key to set as the menu open key',
            hint = 'ESC to use default (Page Down)'
        }))
        print("Lua: Keybind setup activated")
    else
        print("Lua: Keybind setup already active or DUI not available")
    end
end

local function closeMenu()
    if dui then
        SendDuiMessage(dui, json.encode({
            action = 'setMenuVisible',
            visible = false
        }))
    end
    
    menuInitialized = false
end

-- Handle text input responses via DUI commands
-- This function will be called when the frontend executes: ExecuteCommand('dui_textInputResponse true "value" "inputId"')
function handleTextInputResponse(data)
    local success = data.success
    local value = data.value
    local inputId = data.inputId
    
    if success then
        -- Handle successful input
        if inputId == 'player_name' then
            -- Player name entered
            if dui then
                SendDuiMessage(dui, json.encode({
                    action = 'notify',
                    message = "Name set to: " .. value,
                    type = 'success'
                }))
            end
        elseif inputId == 'give_money' then
            local amount = tonumber(value)
            if amount then
                -- Money amount entered
                if dui then
                    SendDuiMessage(dui, json.encode({
                        action = 'notify',
                        message = "Giving $" .. amount .. " to player",
                        type = 'success'
                    }))
                end
            end
        end
    else
        -- Handle cancelled input
        -- Text input cancelled
        if dui then
            SendDuiMessage(dui, json.encode({
                action = 'notify',
                message = "Input cancelled",
                type = 'warn'
            }))
        end
    end
end
    


-- Main thread
CreateThread(function()
    dui = CreateDui("https://five-m-menu-framework.vercel.app/", 1920, 1080)
    
    if dui then
        
        -- DUI created successfully
        SetDuiUrl(dui, "https://five-m-menu-framework.vercel.app/")
        local attempts = 0
        local maxAttempts = 10
        local duiHandle = nil
        
        while attempts < maxAttempts do
            Wait(500)
            attempts = attempts + 1
            duiHandle = GetDuiHandle(dui)
            
            if duiHandle and duiHandle ~= 0 then
                -- DUI handle obtained
                break
            else
                -- Waiting for DUI handle...
            end
        end
        
        if duiHandle and duiHandle ~= 0 then
            -- Create runtime TXD first
            duiTxd = CreateRuntimeTxd(txdName)
            if duiTxd then
                -- DUI runtime TXD created
                -- Create runtime texture within the TXD
                duiTexture = CreateRuntimeTextureFromDuiHandle(duiTxd, txtName, duiHandle)
                if duiTexture then
                    -- DUI runtime texture created
                else
                    -- Failed to create DUI runtime texture
                end
            else
                -- Failed to create DUI runtime TXD
            end
        else
            -- Could not get valid DUI handle
        end
        
        SendDuiMessage(dui, json.encode({
            action = 'setTheme',
            theme = 'orange'
        }))
        SendDuiMessage(dui, json.encode({
            action = 'setBannerImage',
            url = 'https://share.creavite.co/68dbd8a6377d6e26798ddccf.gif'
        }))
        
        -- Test connection by sending a message
        _G.clientMenuShowing = false
        -- Don't show menu initially - wait for key to be set
        setupKeybind()
    else
        -- Failed to create DUI
        return
    end

    -- Menu toggle thread - uses custom keybind with injection
    CreateThread(function()
        local lastPress = 0
        print("Lua: Menu toggle thread started with menuOpenKey:", menuOpenKey)
        while true do
            -- Use the custom menu open key with injection method
            if IsControlJustPressed(0, menuOpenKey) or IsDisabledControlJustPressed(0, menuOpenKey) then
                print("Lua: Menu open key pressed - Control ID:", menuOpenKey)
                local currentTime = GetGameTimer()
                if currentTime - lastPress > 200 then
                    if _G.clientMenuShowing then
                        -- Send hide message to frontend instead of setting global to false
                        if dui then
                            SendDuiMessage(dui, json.encode({
                                action = 'setMenuVisible',
                                visible = false
                            }))
                        end
                        _G.clientMenuShowing = false
                        -- Menu closed
                    else
                        _G.clientMenuShowing = true
                        -- Menu opened
                        if dui then
                            SendDuiMessage(dui, json.encode({
                                action = 'setMenuVisible',
                                visible = true
                            }))
                        end
                    end
                    lastPress = currentTime
                end
            end
            
            -- Handle F9 keybind setup globally (even when menu is closed) with injection
            if IsControlJustPressed(0, keyMap["F9"]) or IsDisabledControlJustPressed(0, keyMap["F9"]) then -- F9 key
                if _G.clientMenuShowing then
                    -- Menu is open, trigger menu keybind setup
                    if dui then
                        SendDuiMessage(dui, json.encode({
                            action = 'openKeySelection',
                            title = 'Menu Keybind Setup',
                            instruction = 'Press any key to set as the menu open key',
                            hint = 'ESC to use default (Page Down)'
                        }))
                        _G.keybindSetupActive = true
                        keybindSetup = true
                    end
                else
                    -- Menu is closed, open it first then trigger keybind setup
                    _G.clientMenuShowing = true
                    -- Menu opened for keybind setup
                    if dui then
                        SendDuiMessage(dui, json.encode({
                            action = 'setMenuVisible',
                            visible = true
                        }))
                    end
                    -- Small delay to ensure menu is initialized
                    Wait(100)
                    if dui then
                        SendDuiMessage(dui, json.encode({
                            action = 'openKeySelection',
                            title = 'Menu Keybind Setup',
                            instruction = 'Press any key to set as the menu open key',
                            hint = 'ESC to use default (Page Down)'
                        }))
                        _G.keybindSetupActive = true
                        keybindSetup = true
                    end
                end
            end
            
            Wait(0)
        end
    end)


    -- Main menu loop
    local showing = false
    -- Use global nestedMenus instead of local
    _G.clientMenuShowing = false
    
    -- Keybind setup state
    local keybindSetupKey = nil
    local keybindSetupKeyName = ""

    while true do
        if _G.clientMenuShowing and not showing then
            showing = true
            initializeMenu()
            nestedMenus = {} -- Reset global nestedMenus
        elseif not _G.clientMenuShowing and showing then
            showing = false
            closeMenu()
        end
        
        -- Handle input recording globally
        handleInputKeyRecording()
        
        -- Handle keybind setup globally (even when menu is not showing)
        if _G.keybindSetupActive then
            -- Key mapping for better detection
            local keyMap = {
                ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["F11"] = 288, ["F12"] = 289,
                ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["0"] = 157, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
                ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["I"] = 303, ["O"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
                ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["J"] = 74, ["K"] = 311, ["L"] = 182,
                ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["/"] = 81,
                ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
                ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178, ["INSERT"] = 178,
                ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
                ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
            }
            
            -- Check for key presses using the key map
            for keyName, controlId in pairs(keyMap) do
                if IsControlJustPressed(0, controlId) or IsDisabledControlJustPressed(0, controlId) then
                    print("Lua: Key pressed during global keybind setup - Key:", keyName, "Control ID:", controlId)
                    if controlId == 322 then -- ESC key
                        -- Cancel keybind setup
                        _G.keybindSetupActive = false
                        keybindSetup = false
                        print("Lua: keybindSetupActive set to false (cancelled)")
                        
                        if dui then
                            SendDuiMessage(dui, json.encode({
                                action = 'closeKeySelection'
                            }))
                            SendDuiMessage(dui, json.encode({
                                action = 'notify',
                                message = "Keybind setup cancelled",
                                type = 'info'
                            }))
                            -- Show the menu after cancelling keybind setup
                            SendDuiMessage(dui, json.encode({
                                action = 'setMenuVisible',
                                visible = true
                            }))
                        end
                    else
                        -- Check if this key is bindable
                        if controlId == 18 then -- ENTER key
                            -- Control ID 18 (ENTER) is not bindable
                            _G.keybindSetupActive = false
                            keybindSetup = false
                            
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'closeKeySelection'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "This key is <span class=\"notification-key\">Not Bindable</span>",
                                    type = 'warn'
                                }))
                                -- Show the menu after trying to bind ENTER
                                SendDuiMessage(dui, json.encode({
                                    action = 'setMenuVisible',
                                    visible = true
                                }))
                            end
                        else
                            -- Set the keybind using injection method
                            _G.keybindSetupActive = false
                            keybindSetup = false
                            menuOpenKey = controlId
                            print("Lua: menuOpenKey updated to:", menuOpenKey)
                            print("Lua: keybindSetupActive set to false")
                            
                            -- Use the key name from the key map
                            local displayKeyName = keyName
                        
                            -- Update the keybind display in the menu
                            for i, item in ipairs(originalMenu) do
                                if item.type == 'submenu' and item.label == 'Settings' then
                                    for j, subItem in ipairs(item.submenu) do
                                        if subItem.label == 'Menu Keybind' then
                                            subItem.currentKey = displayKeyName
                                            break
                                        end
                                    end
                                    break
                                end
                            end
                            
                            -- Menu keybind set
                            print("Lua: Menu keybind successfully set to Control ID:", controlId, "Key Name:", displayKeyName)
                            if dui then
                                SendDuiMessage(dui, json.encode({
                                    action = 'closeKeySelection'
                                }))
                                SendDuiMessage(dui, json.encode({
                                    action = 'notify',
                                    message = "Menu keybind set to: <span class=\"notification-key\">" .. displayKeyName .. "</span>",
                                    type = 'success'
                                }))
                                -- Show the menu after setting keybind
                                SendDuiMessage(dui, json.encode({
                                    action = 'setMenuVisible',
                                    visible = true
                                }))
                                -- Update the menu to show the new key
                                setCurrent()
                            end
                        end
                    end
                    break
                end
            end
            -- Wait(100) -- Small delay to prevent rapid key detection
            
        end

        if showing then
            EnableControlAction(0, 1, true) -- Mouse
            EnableControlAction(0, 2, true) -- Mouse
            DisableControlAction(0, 11, true) -- Page Down

            if isControlJustPressed(187) then -- Arrow Down
                -- Don't process navigation if text input is active
                if _G.inputRecordingActive then
                    Wait(100)
                    return
                end
                
                activeIndex = activeIndex + 1
                if activeIndex > #activeMenu then activeIndex = 1 end
                setCurrent()
                sendSelectedPlayerData()
                Wait(100)
            elseif isControlJustPressed(188) then -- Arrow Up
                -- Don't process navigation if text input is active
                if _G.inputRecordingActive then
                    Wait(100)
                    return
                end
                
                activeIndex = activeIndex - 1
                if activeIndex < 1 then activeIndex = #activeMenu end
                setCurrent()
                sendSelectedPlayerData()
                Wait(100)
            elseif IsControlPressed(0, 189) then -- Left Arrow (held)
                -- Don't process navigation if text input is active
                if _G.inputRecordingActive then
                    Wait(100)
                    return
                end
                
                local activeData = activeMenu[activeIndex]
                if activeData.type == 'scroll' then
                    -- For scroll, only change on press, not hold
                    if isControlJustPressed(189) then
                    activeData.selected = activeData.selected - 1
                    if activeData.selected < 1 then activeData.selected = #activeData.options end
                    setCurrent()
                    if activeData.onChange then
                        activeData.onChange(activeData.options[activeData.selected])
                        end
                        Wait(100)
                    end
                elseif activeData.type == 'slider' then
                    -- For slider, allow continuous change when held
                    activeData.value = math.max(activeData.min, activeData.value - (activeData.step or 1))
                    setCurrent()
                    if activeData.onChange then
                        activeData.onChange(activeData.value)
                    end
                    Wait(50) -- Faster response for sliders
                end
            elseif IsControlPressed(0, 190) then -- Right Arrow (held)
                -- Don't process navigation if text input is active
                if _G.inputRecordingActive then
                    Wait(100)
                    return
                end
                
                local activeData = activeMenu[activeIndex]
                if activeData.type == 'scroll' then
                    -- For scroll, only change on press, not hold
                    if isControlJustPressed(190) then
                    activeData.selected = activeData.selected + 1
                    if activeData.selected > #activeData.options then activeData.selected = 1 end
                    setCurrent()
                    if activeData.onChange then
                        activeData.onChange(activeData.options[activeData.selected])
                        end
                        Wait(100)
                    end
                elseif activeData.type == 'slider' then
                    -- For slider, allow continuous change when held
                    activeData.value = math.min(activeData.max, activeData.value + (activeData.step or 1))
                    setCurrent()
                    if activeData.onChange then
                        activeData.onChange(activeData.value)
                    end
                    Wait(50) -- Faster response for sliders
                end
            elseif isControlJustPressed(191) then -- Enter
                -- Don't process ENTER if text input is active
                if _G.inputRecordingActive then
                    Wait(100)
                    return
                end
                
                local activeData = activeMenu[activeIndex]
                
                if activeData.type == 'submenu' then
                    if activeData.submenu then
                        nestedMenus[#nestedMenus + 1] = { index = activeIndex, menu = activeMenu }
                        activeIndex = 1
                        activeMenu = activeData.submenu
                        -- Update breadcrumb with full path
                        if dui then
                            local breadcrumb = "Main Menu"
                            for i, nestedMenu in ipairs(nestedMenus) do
                                breadcrumb = breadcrumb .. " > " .. nestedMenu.menu[nestedMenu.index].label
                            end
                            SendDuiMessage(dui, json.encode({
                                action = 'updateBreadcrumb',
                                breadcrumb = breadcrumb
                            }))
                        end
                        setCurrent()
                        sendSelectedPlayerData()
                    end
                elseif activeData.type == 'button' then
                    if activeData.onConfirm then
                        activeData.onConfirm()
                    end
                elseif activeData.type == 'checkbox' then
                    activeData.checked = not activeData.checked
                    setCurrent()
                    if activeData.onConfirm then
                        activeData.onConfirm(activeData.checked)
                    end
                elseif activeData.type == 'scroll' then
                    if activeData.onConfirm then
                        local selectedIndex = activeData.selected
                        activeData.onConfirm(activeData.options[selectedIndex])
                    end
                    setCurrent()
                elseif activeData.type == 'slider' then
                    if activeData.onConfirm then
                        activeData.onConfirm(activeData.value)
                    end
                    setCurrent()
                elseif activeData.type == 'input' then
                    if activeData.onConfirm then
                        activeData.onConfirm()
                    end
                elseif activeData.type == 'keybind' then
                    if activeData.onConfirm then
                        activeData.onConfirm()
                    end
                elseif activeData.type == 'playerlist' then
                    if activeData.onConfirm then
                        activeData.onConfirm()
                    end
                end
            elseif isControlJustPressed(75) then -- F9 keybind setup
                local activeData = activeMenu[activeIndex]
                if activeData and activeData.canBind then
                    if dui then
                        SendDuiMessage(dui, json.encode({
                            action = 'openKeybindSetup',
                            featureName = activeData.bindName or activeData.label
                        }))
                    end
                end
            elseif isControlJustPressed(194) then -- Backspace
                -- Don't process BACKSPACE if text input is active
                if _G.inputRecordingActive then
                    Wait(100)
                    return
                end
                
                local lastMenu = nestedMenus[#nestedMenus]
                if lastMenu then
                    table.remove(nestedMenus)
                    activeIndex = lastMenu.index
                    activeMenu = lastMenu.menu
                    -- Update breadcrumb with full path
                    if dui then
                        local breadcrumb = "Main Menu"
                        for i, nestedMenu in ipairs(nestedMenus) do
                            breadcrumb = breadcrumb .. " > " .. nestedMenu.menu[nestedMenu.index].label
                        end
                        SendDuiMessage(dui, json.encode({
                            action = 'updateBreadcrumb',
                            breadcrumb = breadcrumb
                        }))
                    end
                    setCurrent()
                    sendSelectedPlayerData()
                else
                    -- Hide menu via frontend but keep DrawSprite visible
                    if dui then
                        SendDuiMessage(dui, json.encode({
                            action = 'setMenuVisible',
                            visible = false
                        }))
                        -- Clear selected player when hiding menu
                        SendDuiMessage(dui, json.encode({
                            action = 'setSelectedPlayer',
                            playerData = nil
                        }))
                    end
                    _G.clientMenuShowing = false
                    currentSelectedPlayer = nil
                end
            end
        end
        Wait(0)
    end
end)


-- DUI Drawing thread - Always draw the texture
CreateThread(function()
    while true do
        if duiTexture then
            -- Always draw the DUI texture on screen
            DrawSprite(txdName, txtName, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
        end
        Wait(0)
    end
end)

print("AMPED FIVEM MENU FRAMEWORK LOADED")
