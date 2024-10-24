local canShow = Config.CanShowNotification

function debugPrint(message)
    if Config.DebugMode then
        local formattedMessage = string.format("[DEBUG] %s: %s", os.date("%Y-%m-%d %H:%M:%S"), message)
        print(formattedMessage)
    end
end

function playSound(effectName, soundSet)
    PlaySoundFrontend(-1, effectName, soundSet, true)
end

function GetClosestVehicleFromPos(coords, maxDistance, ignoreEntity)
    local objs = GetGamePool('CVehicle')
    local nearbyVehicles = {}
    local nearestDist, nearestObj = math.huge, nil

    if #objs == 0 then return nearestObj end

    for i = 0, #objs do
        local objCoo = GetEntityCoords(objs[i])
        local dist = #(objCoo - coords)
        if dist <= maxDistance then
            table.insert(nearbyVehicles, objs[i])
        end
    end

    if #nearbyVehicles == 0 then return nearestObj end

    for i = 1, #nearbyVehicles do
        local obj = nearbyVehicles[i]
        local objCoo = GetEntityCoords(obj)
        local dist = #(objCoo - coords)
        if dist < nearestDist and obj ~= ignoreEntity then
            nearestDist = dist
            nearestObj = obj
        end
    end

    return nearestObj
end

CreateThread(function ()
    while true do
        Wait(10)
        local canSleep = true
        local playerPed = GetPlayerPed(-1)
        if IsPedInAnyVehicle(playerPed, false) then
            local myVehicle = GetVehiclePedIsIn(playerPed, false)
            local myVehicleHash = GetEntityModel(myVehicle)
            if myVehicleHash == 1044954915 then  -- Skylift model hash
                if canShow then
                    showNotification("Press ~INPUT_CONTEXT~ to use the magnet")
                    canShow = false
                end
                canSleep = false
                if IsControlJustPressed(1, 38) then  -- 'E' key by default
                    local vehicle = GetClosestVehicleFromPos(GetEntityCoords(myVehicle), Config.MaxVehicleDistance, myVehicle)
                    
                    if vehicle then
                        debugPrint("Nearby Vehicle found: " .. tostring(vehicle))
                        if IsEntityAttachedToAnyVehicle(vehicle) then
                            if IsEntityAttachedToEntity(vehicle, myVehicle) then
                                canShow = true
                                TriggerServerEvent('ss-skylift:detachVehicle', NetworkGetNetworkIdFromEntity(vehicle), GetActivePlayersServerId())
                                showNotification("Vehicle detached and dropped!")
                                playSound("Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset")
                            end
                        else
                            local vehicleHash = GetEntityModel(vehicle)
                            if IsThisModelACar(vehicleHash) or IsThisModelABike(vehicleHash) or IsThisModelATrain(vehicleHash) or IsThisModelABicycle(vehicleHash) or IsThisModelAQuadbike(vehicleHash) then
                                local vehiclePos = GetEntityCoords(vehicle)
                                local myVehiclePos = GetEntityCoords(myVehicle)
                                local pDist = #(vehiclePos - myVehiclePos)
                                if pDist <= 10.0 then
                                    debugPrint('Attaching vehicle to skylift')
                                    TriggerServerEvent('ss-skylift:attachVehicle', NetworkGetNetworkIdFromEntity(vehicle), NetworkGetNetworkIdFromEntity(myVehicle), GetActivePlayersServerId())
                                    showNotification("Vehicle attached successfully!")
                                    playSound("Checkpoint_Hit", "GTAO_FM_Events_Soundset")
                                end
                            else
                                showNotification("This is not a valid vehicle to attach!")
                                playSound("ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET")
                            end
                        end
                    else
                        showNotification("No vehicles nearby!")
                        playSound("ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET")
                    end
                end
            end
        else
            canShow = true
        end
        if canSleep then 
            Wait(500)
        end
    end
end)

function GetActivePlayersServerId()
    local ActivePlayers = {}
    for _, v in ipairs(GetActivePlayers()) do
        table.insert(ActivePlayers, GetPlayerServerId(v))
    end
    return ActivePlayers
end

RegisterNetEvent('ss-skylift:attachVehicle')
AddEventHandler('ss-skylift:attachVehicle', function(entity, attachedEntity)
    debugPrint('Received "attachVehicle"')
    AttachEntityToEntity(NetworkGetEntityFromNetworkId(entity), NetworkGetEntityFromNetworkId(attachedEntity), 0, 0.0, -3.0, -1.0, 0.0, 0.0, 0.0, true, true, true, true, 1, true)
end)

RegisterNetEvent('ss-skylift:detachVehicle')
AddEventHandler('ss-skylift:detachVehicle', function(attachedEntity)
    debugPrint('Received "detachVehicle"')
    DetachEntity(NetworkGetEntityFromNetworkId(attachedEntity), true, true)
end)

function showNotification(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, 5000)
end
