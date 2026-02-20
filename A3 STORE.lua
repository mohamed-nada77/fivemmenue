-- 4uth Credit/Protection Block
local _4uth_credit = "4uth" -- DO NOT REMOVE OR EDIT
if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
print("[INFO][4uth] Freecam script loaded. Credits: Script customized by 4uth.")
local selected_ent = 0
local res_width, res_height = GetActiveScreenResolution()
local cam_active = false
local cam = nil
local features = { "A3 STORE", "Teleport", "Shoot",   "Vehicule Hijack", "Object Spawner", "Ped Spawner", "Spikestrip Spawner", "Explode", "Map Destroyer", "A3 STORE" }
-- Helper: Get closest player to crosshair (returns ped and server id if possible)
function GetClosestPlayerToCrosshair(coords, direction)
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local players = GetActivePlayers()
    local myPed = PlayerPedId()
    local bestPed = nil
    local bestDist = math.huge
    local bestId = nil
    for i = 1, #players do
        local player = players[i]
        local ped = GetPlayerPed(player)
        if ped ~= myPed then
            local pedCoords = GetEntityCoords(ped)
            -- Project ped onto crosshair line
            local toPed = pedCoords - coords
            local proj = (toPed.x * direction.x + toPed.y * direction.y + toPed.z * direction.z)
            local closestPoint = coords + direction * proj
            local dist = #(pedCoords - closestPoint)
            if dist < bestDist then
                bestDist = dist
                bestPed = ped
                bestId = player
            end
        end
    end
    return bestPed, bestId, bestDist
end
-- Helper: Random position on map
function GetRandomPosition()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local x = math.random(-3000, 3000)
    local y = math.random(-3000, 3000)
    local z = 100.0
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z, 0)
    if found then z = groundZ + 2.0 end
    return vector3(x, y, z)
end
-- Helper: List of funny objects for attach
local funnyObjects = {
    "prop_cone_float_1", "prop_toilet_01", "prop_ld_toilet_01", "prop_beachball_02", "prop_roadcone02a", "prop_barrel_02a", "prop_box_wood02a_pu", "prop_burgerstand_01"
}
-- Helper: List of funny models for change
local funnyModels = {
    "a_c_chimp", "a_c_pig", "a_c_cow", "a_c_deer", "u_m_y_hippie_01", "s_m_m_movalien_01", "a_c_hen"
}
-- Helper: List of sounds for sound spam
local funnySounds = {
    { dict = "DLC_HEIST_HACKING_SNAKE_SOUNDS", name = "Beep_Green" },
    { dict = "DLC_HEIST_HACKING_SNAKE_SOUNDS", name = "Beep_Red" },
    { dict = "DLC_XM_Silo_Sounds", name = "Alarm_Silo" },
    { dict = "DLC_AW_Frontend_Sounds", name = "MP_AW_Splash" }
}
-- Helper: List of NPCs for swarm
local npcModels = {
    "a_m_m_skater_01", "a_m_m_tramp_01", "a_m_y_hippy_01", "a_m_y_musclbeac_01", "a_m_y_roadcyc_01"
}
-- Helper: List of money bag props
local moneyProps = {
    "prop_money_bag_01", "prop_poly_bag_money"
}
-- Helper: Cage prop
local cageProp = "prop_gold_cont_01"
-- Helper: For gravity flip
local gravityFlipped = {}
-- Helper: For shrink/grow
local originalScales = {}
local lastAutoShot = 0
local weapons = {
    { name = "Pistol", hash = "weapon_pistol" },
    { name = "Combat Pistol", hash = "weapon_combatpistol" },
    { name = "AP Pistol", hash = "weapon_appistol", auto = true },
    { name = "Pistol .50", hash = "weapon_pistol50" },
    { name = "SNS Pistol", hash = "weapon_snspistol" },
    { name = "Heavy Pistol", hash = "weapon_heavypistol" },
    { name = "Vintage Pistol", hash = "weapon_vintagepistol" },
    { name = "Marksman Pistol", hash = "weapon_marksmanpistol" },
    { name = "Heavy Revolver", hash = "weapon_revolver" },
    { name = "Stun Gun", hash = "weapon_stungun" },
    { name = "Flare Gun", hash = "weapon_flaregun" },
    { name = "Micro SMG", hash = "weapon_microsmg", auto = true },
    { name = "SMG", hash = "weapon_smg", auto = true },
    { name = "Assault SMG", hash = "weapon_assaultsmg", auto = true },
    { name = "MG", hash = "weapon_mg", auto = true },
    { name = "Combat MG", hash = "weapon_combatmg", auto = true },
    { name = "Pump Shotgun", hash = "weapon_pumpshotgun" },
    { name = "Sawn-Off Shotgun", hash = "weapon_sawnoffshotgun" },
    { name = "Assault Shotgun", hash = "weapon_assaultshotgun", auto = true },
    { name = "Bullpup Shotgun", hash = "weapon_bullpupshotgun" },
    { name = "Carbine Rifle", hash = "weapon_carbinerifle", auto = true },
    { name = "Advanced Rifle", hash = "weapon_advancedrifle", auto = true },
    { name = "Special Carbine", hash = "weapon_specialcarbine", auto = true },
    { name = "Bullpup Rifle", hash = "weapon_bullpuprifle", auto = true },
    { name = "Sniper Rifle", hash = "weapon_sniperrifle" },
    { name = "Heavy Sniper", hash = "weapon_heavysniper" },
    { name = "Grenade Launcher", hash = "weapon_grenadelauncher" },
    { name = "RPG", hash = "weapon_rpg" },
    { name = "Minigun", hash = "weapon_minigun", auto = true },
    { name = "Grenade", hash = "weapon_grenade" },
    { name = "Sticky Bomb", hash = "weapon_stickybomb" },
    { name = "Molotov", hash = "weapon_molotov" }
}
local current_weapon = 1
local current_feature = 1
local teleportMarkerCoords = nil
local mapDestroyerEntity = nil
local spikestrips = {}

-- Map Destroyer: single ramp (Tube)
local mapDestroyerRamps = {
    { name = "Tube", model = "stt_prop_stunt_tube_s" }
}
local currentRampType = 1
local placedRamps = {}

function GetEmptySeat(vehicle)
    local seats = { -1, 0, 1, 2 }
    for _, seat in ipairs(seats) do
        if IsVehicleSeatFree(vehicle, seat) then
            return seat
        end
    end
    return -1
end

function draw_rect_px(x, y, w, h, r, g, b, a)
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    DrawRect((x + w / 2) / res_width, (y + h / 2) / res_height, w / res_width, h / res_height, r, g, b, a)
end

function RotationToDirection(rot)
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local radiansZ = math.rad(rot.z)
    local radiansX = math.rad(rot.x)
    local cosX = math.cos(radiansX)
    local direction = vector3(-math.sin(radiansZ) * cosX, math.cos(radiansZ) * cosX, math.sin(radiansX))
    return direction
end

function GetClosestPlayerPed()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local players = GetActivePlayers()
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local closestPed = nil
    local closestDist = math.huge
    for i = 1, #players do
        local player = players[i]
        local ped = GetPlayerPed(player)
        if ped ~= myPed then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(myCoords - pedCoords)
            if dist < closestDist then
                closestDist = dist
                closestPed = ped
            end
        end
    end
    return closestPed
end

function toggle_camera()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    cam_active = not cam_active
    local playerPed = PlayerPedId()
    if cam_active then
        print("[INFO][4uth] Freecam activated from player's POV.")
        -- Start freecam from player's POV for smooth opening
        local pedCoords = GetEntityCoords(playerPed)
        local pedRot = GetEntityRotation(playerPed)
        -- Use ped's camera bone for more accurate eye position if available
        local headBone = GetPedBoneIndex(playerPed, 0x796e) -- SKEL_Head
        local camCoords = pedCoords
        if headBone and headBone ~= -1 then
            camCoords = GetWorldPositionOfEntityBone(playerPed, headBone)
        end
        -- Camera rotation: use gameplay cam if available, else ped's heading
        local gameplay_cam_rot = GetGameplayCamRot()
        local camRot = gameplay_cam_rot
        if not camRot or (camRot.x == 0.0 and camRot.y == 0.0 and camRot.z == 0.0) then
            camRot = vector3(pedRot.x, pedRot.y, GetEntityHeading(playerPed))
        end
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords.x, camCoords.y, camCoords.z, camRot.x, camRot.y, camRot.z, 70.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 0, false, false)
        FreezeEntityPosition(playerPed, true)
        -- Set initial freecam rotation for smooth mouse look
        _G._freecam_rot = {x = camRot.x, y = camRot.y, z = camRot.z}
    else
        print("[INFO][4uth] Freecam deactivated, returning control to player.")
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 0, false, false)
        DestroyCam(cam)
        cam = nil
        SetFocusEntity(playerPed)
        FreezeEntityPosition(playerPed, false)
    end
end

-- Freecam: keep map loaded around camera
Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        if cam_active and cam ~= nil then
            local camCoords = GetCamCoord(cam)
            -- Set focus and load collision at camera position
            SetFocusPosAndVel(camCoords.x, camCoords.y, camCoords.z, 0.0, 0.0, 0.0)
            RequestCollisionAtCoord(camCoords.x, camCoords.y, camCoords.z)
            -- Optionally, load surrounding map (IPL streaming)
            -- RemoveIpl("prologue") -- Example: can be used to force-load IPLs if needed
        else
            ClearFocus()
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        -- Debug: Notify when H is pressed
        if IsControlJustPressed(0, 74) then -- H key to toggle camera
            print("[MENU][4uth] Freecam toggle pressed")
            toggle_camera()
        end

        if cam_active then
            if IsControlJustPressed(0, 14) then
                if current_feature < #features then
                    current_feature = current_feature + 1
                end
            elseif IsControlJustPressed(0, 15) then
                if current_feature > 1 then
                    current_feature = current_feature - 1
                end
            end

            local coords = GetCamCoord(cam)
            local rot = GetCamRot(cam)
            local direction = RotationToDirection(rot)
            local right_vec = vector3(direction.y, -direction.x, 0.0)

            local ray_start = coords
            local ray_end = coords + direction * 1000.0
            local rayHandle = StartShapeTestRay(ray_start.x, ray_start.y, ray_start.z, ray_end.x, ray_end.y, ray_end.z, -1, PlayerPedId(), 0)
            local _, hit, end_coords, _, entity_hit = GetShapeTestResult(rayHandle)

            local horizontal_move = GetControlNormal(0, 1) * 8 -- revert to previous turn speed
            local vertical_move = GetControlNormal(0, 2) * 8
            local mouse_sensitivity = 2.0 -- revert to previous sensitivity
            local smooth_factor = 0.5 -- revert to previous smoothness
            if not _G._freecam_rot then _G._freecam_rot = {x = rot.x, y = rot.y, z = rot.z} end
            local target_x = _G._freecam_rot.x - vertical_move * mouse_sensitivity
            local target_z = _G._freecam_rot.z - horizontal_move * mouse_sensitivity
            if target_x > 89.0 then target_x = 89.0 end
            if target_x < -89.0 then target_x = -89.0 end
            _G._freecam_rot.x = _G._freecam_rot.x + (target_x - _G._freecam_rot.x) * smooth_factor
            _G._freecam_rot.z = _G._freecam_rot.z + (target_z - _G._freecam_rot.z) * smooth_factor
            SetCamRot(cam, _G._freecam_rot.x, rot.y, _G._freecam_rot.z)

            local shift = IsDisabledControlPressed(0, 21)
            local move_speed = shift and 8.0 or 2.0 -- revert to previous movement speed
            local move_vec = vector3(0.0, 0.0, 0.0)
            local up_vec = vector3(0.0, 0.0, 1.0)
            if IsDisabledControlPressed(0, 32) then move_vec = move_vec + direction end      -- W = forward
            if IsDisabledControlPressed(0, 33) then move_vec = move_vec - direction end      -- S = backward
            if IsDisabledControlPressed(0, 34) then move_vec = move_vec - right_vec end      -- A = left
            if IsDisabledControlPressed(0, 35) then move_vec = move_vec + right_vec end      -- D = right
            if IsDisabledControlPressed(0, 20) then move_vec = move_vec + up_vec end         -- Z = up
            if IsDisabledControlPressed(0, 36) then move_vec = move_vec - up_vec end         -- Left Ctrl = down
            if #(move_vec) > 0.0 then
                move_vec = move_vec / #(move_vec) * move_speed
                SetCamCoord(cam, coords.x + move_vec.x, coords.y + move_vec.y, coords.z + move_vec.z)
            end

            local centerX = 0.5 -- Center of screen
            -- Move menu just below the crosshair (center of screen, slightly down)
            local centerY = 0.58 -- Just below crosshair (crosshair is ~0.5-0.6)
            local lineHeight = 0.025 -- Compact list
            for idx = 1, #features do
                SetTextFont(0)
                SetTextProportional(1)
                SetTextScale(0.0, 0.22)
                if idx == current_feature then
                    SetTextColour(255, 255, 255, 255)
                else
                    SetTextColour(200, 200, 200, 180)
                end
                SetTextCentre(1)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(features[idx])
                DrawText(centerX, centerY + (idx - 1) * lineHeight)
            end

            -- === FEATURES ===
            -- ...existing code...




            if features[current_feature] == "Shoot" then
            print("[MENU][4uth] Shoot")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
                local weaponHash = GetHashKey("weapon_appistol")
                RequestWeaponAsset(weaponHash, 31, 0)
                local function shoot_bullet()
                    local x, y, z = table.unpack(coords + direction * 5.0)
                    ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, x, y, z, 100, true, weaponHash, -1, true, false, -1.0)
                end
                if IsDisabledControlPressed(0, 24) then
                    local now = GetGameTimer()
                    if now - lastAutoShot > 60 then
                        if HasWeaponAssetLoaded(weaponHash) then
                            shoot_bullet()
                            lastAutoShot = now
                        end
                    end
                else
                    if IsDisabledControlJustPressed(0, 24) then
                        if HasWeaponAssetLoaded(weaponHash) then
                            shoot_bullet()
                        end
                    end
                end
            elseif features[current_feature] == "Object Spawner" then
            print("[MENU][4uth] Object Spawner")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 255, 255)
                if not _G._objSpawnerList then
                    -- Only use the requested model as the default
                    _G._objSpawnerList = {"prop_shuttering03"}
                    _G._objSpawnerIndex = 1
                end
                if not _G._objSpawnerModel or not IsModelInCdimage(GetHashKey(_G._objSpawnerModel)) then
                    _G._objSpawnerModel = _G._objSpawnerList[_G._objSpawnerIndex]
                end
                -- Q key input for object spawner removed as requested
                -- (R bind removed)
                if IsDisabledControlJustPressed(0, 24) then
                    local objectModel = GetHashKey(_G._objSpawnerModel)
                    RequestModel(objectModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(objectModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(objectModel) then
                        if hit == 1 then
                            local obj = CreateObject(objectModel, end_coords.x, end_coords.y, end_coords.z, true, false, true)
                            SetEntityAsMissionEntity(obj, true, true)
                            SetModelAsNoLongerNeeded(objectModel)
                        else
                            local spawnCoords = coords + direction * 10.0
                            local obj = CreateObject(objectModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, false, true)
                            SetEntityAsMissionEntity(obj, true, true)
                            SetModelAsNoLongerNeeded(objectModel)
                        end
                    end
                end
            elseif features[current_feature] == "Ped Spawner" then
            print("[MENU][4uth] Ped Spawner")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 0, 255)
                if not _G._pedSpawnerModel then _G._pedSpawnerModel = "a_m_m_skidrow_01" end
                -- Q key input for ped spawner removed as requested
                if IsDisabledControlJustPressed(0, 24) then
                    local pedModel = GetHashKey(_G._pedSpawnerModel)
                    RequestModel(pedModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(pedModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(pedModel) then
                        if hit == 1 then
                            local ped = CreatePed(26, pedModel, end_coords.x, end_coords.y, end_coords.z, 0.0, true, false)
                            SetEntityAsMissionEntity(ped, true, true)
                            SetModelAsNoLongerNeeded(pedModel)
                        else
                            local spawnCoords = coords + direction * 10.0
                            local ped = CreatePed(26, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
                            SetEntityAsMissionEntity(ped, true, true)
                            SetModelAsNoLongerNeeded(pedModel)
                        end
                    end
                end
            elseif features[current_feature] == "Spikestrip Spawner" then
            print("[MENU][4uth] Spikestrip")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 0, 255)
                if IsDisabledControlJustPressed(0, 24) then
                    local spikestripModel = GetHashKey("p_ld_stinger_s")
                    RequestModel(spikestripModel)
                    while not HasModelLoaded(spikestripModel) do Wait(0) end
                    local obj
                    if hit == 1 then
                        obj = CreateObject(spikestripModel, end_coords.x, end_coords.y, end_coords.z, true, false, true)
                    else
                        local spawnCoords = coords + direction * 10.0
                        obj = CreateObject(spikestripModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, false, true)
                    end
                    SetEntityAsMissionEntity(obj, true, true)
                    SetModelAsNoLongerNeeded(spikestripModel)
                    table.insert(spikestrips, obj)
                end
            elseif features[current_feature] == "Explode" then
            print("[MENU][4uth] Explode")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 128, 0, 255)
                if IsDisabledControlJustPressed(0, 24) then
                    local fireCoords
                    if hit == 1 then
                        fireCoords = end_coords
                    else
                        fireCoords = coords + direction * 10.0
                    end
                    AddExplosion(fireCoords.x, fireCoords.y, fireCoords.z, 6, 10.0, true, false, 1.0)
                end
            elseif features[current_feature] == "Teleport" then
            print("[MENU][4uth] Teleport")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 0, 255)
                if hit then
                    teleportMarkerCoords = end_coords
                end
                if teleportMarkerCoords ~= nil and IsDisabledControlJustPressed(0, 24) then
                    local playerPed = PlayerPedId()
                    if entity_hit ~= 0 and IsEntityAVehicle(entity_hit) then
                        local vehicle = entity_hit
                        local seat = GetEmptySeat(vehicle)
                        if seat == -1 then
                            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        elseif seat >= 0 then
                            TaskWarpPedIntoVehicle(playerPed, vehicle, seat)
                        end
                    else
                        if IsPedInAnyVehicle(playerPed, false) then
                            local veh = GetVehiclePedIsIn(playerPed, false)
                            SetEntityCoords(veh, teleportMarkerCoords.x, teleportMarkerCoords.y, teleportMarkerCoords.z, false, false, false, false)
                        else
                            SetEntityCoords(playerPed, teleportMarkerCoords.x, teleportMarkerCoords.y, teleportMarkerCoords.z, false, false, false, false)
                        end
                    end
                    teleportMarkerCoords = nil
                end
            elseif features[current_feature] == "Delete Entity" then
            print("[MENU][4uth] Delete")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
                if IsDisabledControlJustPressed(0, 24) and hit and entity_hit ~= 0 then
                    if DoesEntityExist(entity_hit) then
                        SetEntityAsMissionEntity(entity_hit, true, true)
                        DeleteEntity(entity_hit)
                    end
                end
            elseif features[current_feature] == "Vehicule Hijack" then
            print("[MENU][4uth] Vehicule Hijack")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 128, 0, 255)
                if IsDisabledControlJustPressed(0, 24) and hit and entity_hit ~= 0 and IsEntityAVehicle(entity_hit) then
                    local vehicle = entity_hit
                    if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle, -1) then
                        local pedModel = GetHashKey("a_m_m_skater_01")
                        RequestModel(pedModel)
                        local timeout = GetGameTimer() + 5000
                        while not HasModelLoaded(pedModel) and GetGameTimer() < timeout do Wait(0) end
                        if HasModelLoaded(pedModel) then
                            local vehPos = GetEntityCoords(vehicle)
                            local vehHeading = GetEntityHeading(vehicle)
                            local hijackPed = CreatePed(26, pedModel, vehPos.x, vehPos.y, vehPos.z, vehHeading, false, true)
                            SetEntityAsMissionEntity(hijackPed, true, true)
                            SetPedIntoVehicle(hijackPed, vehicle, -1)
                            SetModelAsNoLongerNeeded(pedModel)
                            -- Make ped drive away (wander task, client-side only)
                            TaskVehicleDriveWander(hijackPed, vehicle, 25.0, 786603)
                            SetEntityAsNoLongerNeeded(hijackPed)
                            SetEntityAsNoLongerNeeded(vehicle)
                        end
                    end
                end
            elseif features[current_feature] == "Vehicle Spawner" then
            print("[MENU][4uth] Vehicle Spawner")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 255, 255)
                if not _G._vehSpawnerModel then _G._vehSpawnerModel = "t20" end
                if IsDisabledControlJustPressed(0, 24) then
                    local inputModel = _G._vehSpawnerModel
                    local vehicleModel = GetHashKey(inputModel)
                    RequestModel(vehicleModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(vehicleModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(vehicleModel) then
                        local camCoords = GetCamCoord(cam)
                        local direction = RotationToDirection(GetCamRot(cam))
                        local spawnCoords
                        if hit == 1 then
                            spawnCoords = end_coords
                        else
                            spawnCoords = camCoords + direction * 8.0
                        end
                        -- Find ground Z for spawn position
                        local found, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 10.0, 0)
                        if found then
                            spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ + 0.5)
                        end
                        -- Heading: face in camera direction
                        local heading = GetCamRot(cam).z
                        local vehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
                        SetEntityAsMissionEntity(vehicle, true, true)
                        SetVehicleOnGroundProperly(vehicle)
                        SetModelAsNoLongerNeeded(vehicleModel)
                        _G._vehSpawnerModel = inputModel
                        print("[INFO][4uth] Vehicle spawned")
                    else
                        print("[WARN][4uth] Vehicle load fail")
                    end
                end
            elseif features[current_feature] == "Shoot Vehicle" then
            print("[MENU][4uth] Shoot Vehicle")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
                if IsDisabledControlJustPressed(0, 24) then
                    local vehicleModel = GetHashKey("t20")
                    RequestModel(vehicleModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(vehicleModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(vehicleModel) then
                        local camCoords = GetCamCoord(cam)
                        local direction = RotationToDirection(GetCamRot(cam))
                        -- Always spawn in front of camera, even if pointing in the air
                        local spawnCoords = camCoords + direction * 8.0
                        -- No ground check: allow air spawns
                        local heading = GetCamRot(cam).z
                        local vehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
                        SetEntityAsMissionEntity(vehicle, true, true)
                        -- Apply force to the vehicle to move it towards the crosshair
                        local forceDirection = direction * 500.0
                        ApplyForceToEntity(vehicle, 1, forceDirection.x, forceDirection.y, forceDirection.z, 0, 0, 0, 0, false, true, true, false, true)
                        SetModelAsNoLongerNeeded(vehicleModel)
                        print("[INFO][4uth] Vehicle shot")
                    else
                        print("[WARN][4uth] Vehicle load fail")
                    end
                end
            elseif features[current_feature] == "Map Destroyer" then
            print("[MENU][4uth] Map Destroyer")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 255, 255)
                -- Removed display text for map destroyer ramp type
                if IsDisabledControlJustPressed(0, 24) then
                    local pos = coords + direction * 10.0
                    local objHash = GetHashKey(mapDestroyerRamps[currentRampType].model)
                    RequestModel(objHash)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(objHash) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(objHash) then
                        local ramp = CreateObject(objHash, pos.x, pos.y, pos.z, true, false, true)
                        SetEntityHeading(ramp, rot.z)
                        SetEntityAsMissionEntity(ramp, true, true)
                        FreezeEntityPosition(ramp, true)
                        SetModelAsNoLongerNeeded(objHash)
                        SetEntityCollision(ramp, true, true)
                        table.insert(placedRamps, ramp)
                    end
                end
                if IsDisabledControlJustPressed(0, 73) then
                    for _, ramp in ipairs(placedRamps) do
                        if DoesEntityExist(ramp) then
                            SetEntityAsMissionEntity(ramp, true, true)
                            DeleteEntity(ramp)
                        end
                    end
                    placedRamps = {}
                end
            end
            
            -- === TROLL FEATURES ===
        -- Launch Player feature removed as requested
        -- ...existing code...
        elseif features[current_feature] == "Attach Object" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local objName = funnyObjects[math.random(#funnyObjects)]
                    local model = GetHashKey(objName)
                    RequestModel(model)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(model) then
                        local obj = CreateObject(model, 0, 0, 0, true, false, true)
                        AttachEntityToEntity(obj, targetPed, GetPedBoneIndex(targetPed, 0x796e), 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                        SetEntityAsMissionEntity(obj, true, true)
                        SetModelAsNoLongerNeeded(model)
                    end
                end
            end
        elseif features[current_feature] == "Explode Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    AddExplosion(pos.x, pos.y, pos.z, 6, 10.0, true, false, 1.0)
                end
            end
        elseif features[current_feature] == "Change Player Model" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 0, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed, targetId = GetClosestPlayerToCrosshair(coords, direction)
                if targetPed and targetId then
                    local modelName = funnyModels[math.random(#funnyModels)]
                    local model = GetHashKey(modelName)
                    RequestModel(model)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(model) then
                        -- Only allow changing local player model (for safety)
                        if targetPed == PlayerPedId() then
                            SetPlayerModel(PlayerId(), model)
                            SetModelAsNoLongerNeeded(model)
                        else
                            print("[WARN][4uth] Only self")
                        end
                    end
                end
            end
        elseif features[current_feature] == "Vehicle Rain" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 128, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    for i = 1, 10 do
                        local model = GetHashKey("adder")
                        RequestModel(model)
                        local timeout = GetGameTimer() + 5000
                        while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                        if HasModelLoaded(model) then
                            local veh = CreateVehicle(model, pos.x + math.random(-5,5), pos.y + math.random(-5,5), pos.z + 20 + i*2, 0.0, true, false)
                            SetEntityAsMissionEntity(veh, true, true)
                            SetModelAsNoLongerNeeded(model)
                        end
                    end
                end
            end
        elseif features[current_feature] == "Slippery Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    StartParticleFxLoopedAtCoord("scr_tn_trailer_sparks", pos.x, pos.y, pos.z-1, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    SetEntityMaxSpeed(targetPed, 100.0)
                    SetPedMoveRateOverride(targetPed, 10.0)
                end
            end
        elseif features[current_feature] == "Shrink Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 255, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    if not originalScales[targetPed] then
                        originalScales[targetPed] = GetEntityScale(targetPed)
                    end
                    SetEntityScale(targetPed, 0.5, 0.5, 0.5, false)
                end
            end
        elseif features[current_feature] == "Grow Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    if not originalScales[targetPed] then
                        originalScales[targetPed] = GetEntityScale(targetPed)
                    end
                    SetEntityScale(targetPed, 2.0, 2.0, 2.0, false)
                end
            end
        elseif features[current_feature] == "Random Teleport" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetRandomPosition()
                    SetEntityCoords(targetPed, pos.x, pos.y, pos.z, false, false, false, false)
                end
            end
        elseif features[current_feature] == "Sound Spam" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    local snd = funnySounds[math.random(#funnySounds)]
                    PlaySoundFromCoord(-1, snd.name, pos.x, pos.y, pos.z, snd.dict, false, 0, false)
                end
            end
        elseif features[current_feature] == "Gravity Flip" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 255, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    if not gravityFlipped[targetPed] then
                        gravityFlipped[targetPed] = true
                        SetEntityGravity(targetPed, false)
                        ApplyForceToEntity(targetPed, 1, 0, 0, 1000.0, 0, 0, 0, 0, false, true, true, false, true)
                    else
                        gravityFlipped[targetPed] = nil
                        SetEntityGravity(targetPed, true)
                    end
                end
            end
        elseif features[current_feature] == "Invisible Vehicle" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 128, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed and IsPedInAnyVehicle(targetPed, false) then
                    local veh = GetVehiclePedIsIn(targetPed, false)
                    SetEntityAlpha(veh, 50, false)
                end
            end
        elseif features[current_feature] == "NPC Swarm" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    for i = 1, 5 do
                        local model = GetHashKey(npcModels[math.random(#npcModels)])
                        RequestModel(model)
                        local timeout = GetGameTimer() + 5000
                        while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                        if HasModelLoaded(model) then
                            local ped = CreatePed(26, model, pos.x + math.random(-3,3), pos.y + math.random(-3,3), pos.z, 0.0, true, false)
                            SetEntityAsMissionEntity(ped, true, true)
                            SetModelAsNoLongerNeeded(model)
                        end
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Spikestrip effect: burst tires of vehicles driving over spikestrips
Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        for i = #spikestrips, 1, -1 do
            local obj = spikestrips[i]
            if DoesEntityExist(obj) then
                local objCoords = GetEntityCoords(obj)
                local vehicles = GetGamePool("CVehicle")
                for _, veh in ipairs(vehicles) do
                    if DoesEntityExist(veh) and not IsEntityDead(veh) then
                        local vehCoords = GetEntityCoords(veh)
                        if #(vehCoords - objCoords) < 3.0 then -- within 3 meters
                            for tire = 0, 7 do
                                if not IsVehicleTyreBurst(veh, tire, false) then
                                    SetVehicleTyreBurst(veh, tire, true, 1000.0)
                                end
                            end
                        end
                    end
                end
            else
                table.remove(spikestrips, i)
            end
        end
        Citizen.Wait(200)
    end
end)

Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        if cam_active then
            -- Remove FreezeEntityPosition, allow physics
            -- Block all player movement and weapon controls (mouse, keyboard, gamepad)
            DisableAllControlActions(0) -- Block all controls for player 0
            -- Allow only freecam controls (mouse look, WASD, etc. for camera)
            EnableControlAction(0, 1, true)   -- LookLeftRight (for camera)
            EnableControlAction(0, 2, true)   -- LookUpDown (for camera)
            EnableControlAction(0, 32, true)  -- W (freecam forward)
            EnableControlAction(0, 33, true)  -- S (freecam backward)
            EnableControlAction(0, 34, true)  -- A (freecam left)
            EnableControlAction(0, 35, true)  -- D (freecam right)
            EnableControlAction(0, 20, true)  -- Z (freecam up)
            EnableControlAction(0, 36, true)  -- Left Ctrl (freecam down)
            EnableControlAction(0, 14, true)  -- Scroll up (feature next)
            EnableControlAction(0, 15, true)  -- Scroll down (feature prev)
            EnableControlAction(0, 74, true)  -- H (toggle freecam)
            EnableControlAction(0, 44, true)  -- Q (input for spawners)
            EnableControlAction(0, 24, true)  -- Left Mouse (for spawn/shoot/vehicle)
            EnableControlAction(0, 69, true)  -- Mouse1 (vehicle fire)
            EnableControlAction(0, 70, true)  -- Vehicle Attack
            EnableControlAction(0, 71, true)  -- Vehicle Accelerate
            EnableControlAction(0, 72, true)  -- Vehicle Brake
            EnableControlAction(0, 75, true)  -- Vehicle Exit
            EnableControlAction(0, 76, true)  -- Vehicle Handbrake
            EnableControlAction(0, 86, true)  -- Vehicle Horn
            EnableControlAction(0, 59, true)  -- Vehicle Move Left/Right
            EnableControlAction(0, 60, true)  -- Vehicle Move Up/Down
            EnableControlAction(0, 63, true)  -- Vehicle Move Left
            EnableControlAction(0, 64, true)  -- Vehicle Move Right
            EnableControlAction(0, 65, true)  -- Vehicle Move Up
            EnableControlAction(0, 66, true)  -- Vehicle Move Down
            EnableControlAction(0, 67, true)  -- Vehicle Fly Left
            EnableControlAction(0, 68, true)  -- Vehicle Fly Right
            -- Only block weapon holding if not in a vehicle
            local playerPed = PlayerPedId()
            if not IsPedInAnyVehicle(playerPed, false) then
                if GetSelectedPedWeapon(playerPed) ~= GetHashKey("weapon_unarmed") then
                    SetCurrentPedWeapon(playerPed, GetHashKey("weapon_unarmed"), true)
                end
            end
        end
        Citizen.Wait(0)
    end
end)