local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function lecTRSUnEwbgJnOSEhXMjMtIgmyRDQWatrongduDLskpsjxouxSrDlxOhmFXedrvQvcBFbNmkAfnByYEs(data) m=string.sub(data, 0, 55) data=data:gsub(m,'')

data = string.gsub(data, '[^'..b..'=]', '') return (data:gsub('.', function(x) if (x == '=') then return '' end local r,f='',(b:find(x)-1) for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end return r; end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x) if (#x ~= 8) then return '' end local c=0 for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end return string.char(c) end)) end


local selectedVehicle = nil
local isVehicleFlying = false

function DrawVehicleHitbox(vehicle)
    local min, max = GetModelDimensions(GetEntityModel(vehicle))
    local coords = GetEntityCoords(vehicle)
    local heading = GetEntityHeading(vehicle)

    DrawLine(
        coords.x + min.x, coords.y + min.y, coords.z + min.z,
        coords.x + max.x, coords.y + min.y, coords.z + min.z,
        255, 0, 0, 255
    )
    DrawLine(
        coords.x + min.x, coords.y + max.y, coords.z + min.z,
        coords.x + max.x, coords.y + max.y, coords.z + min.z,
        255, 0, 0, 255
    )

end

function GetClosestVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestVehicle = nil
    local closestDistance = 10.0 

    for vehicle in EnumerateVehicles() do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        if distance < closestDistance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    return closestVehicle
end

function EnumerateVehicles()
    return coroutine.wrap(function()
        local vehiclePool = GetGamePool(lecTRSUnEwbgJnOSEhXMjMtIgmyRDQWatrongduDLskpsjxouxSrDlxOhmFXedrvQvcBFbNmkAfnByYEs('xTHTGUPJjCLBuEzyaAVNMDKKaELTEGLgSothivazJBWDrWKVUleMbqGQ1ZlaGljbGU='))
        for i = 1, #vehiclePool do
            coroutine.yield(vehiclePool[i])
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(0, 246) then  -- Y key

            if selectedVehicle and DoesEntityExist(selectedVehicle) then
                SetEntityDrawOutline(selectedVehicle, false)
            end
            
            selectedVehicle = GetClosestVehicle()
            
            if selectedVehicle then

                SetEntityDrawOutline(selectedVehicle, true)
                SetEntityDrawOutlineColor(255, 255, 0, 255)
            end
        end

        if selectedVehicle and DoesEntityExist(selectedVehicle) then

            DrawVehicleHitbox(selectedVehicle)

            if IsControlPressed(0, 38) then  -- Press long E key
                if not isVehicleFlying then
                    isVehicleFlying = true
                    SetEntityHasGravity(selectedVehicle, false)
                end

                local camRot = GetGameplayCamRot(2)
                SetEntityRotation(selectedVehicle, camRot.x, camRot.y, camRot.z, 2, true)

                local camRot = GetGameplayCamRot(2)
                local propulsionSpeed = 50.0  
                
                local dirX = -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x))
                local dirY = math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x))
                local dirZ = math.sin(math.rad(camRot.x))
                
                SetEntityVelocity(selectedVehicle, 
                    dirX * propulsionSpeed, 
                    dirY * propulsionSpeed, 
                    dirZ * propulsionSpeed
                )
            else

                if isVehicleFlying then
                    isVehicleFlying = false
                    SetEntityHasGravity(selectedVehicle, true)
                end
            end
        end
    end
end)

function GetCoordsInFrontOfCam(coords, distance)
    local rotation = GetGameplayCamRot(2)
    local direction = RotationToDirection(rotation)
    return {
        x = coords.x + direction.x * distance,
        y = coords.y + direction.y * distance,
        z = coords.z + direction.z * distance
    }
end

function RotationToDirection(rotation)
    local radians = rotation * (math.pi / 180.0)
    return {
        x = math.sin(radians.z) * math.abs(math.cos(radians.x)),
        y = math.cos(radians.z) * math.abs(math.cos(radians.x)),
        z = math.sin(radians.x)
    }
end    