RegisterNetEvent('ss-skylift:attachVehicle', function(entity, attachedEntity, ActivePlayers)
    for _, v in ipairs(ActivePlayers) do
        TriggerClientEvent('ss-skylift:attachVehicle', v, entity, attachedEntity)
    end
end)

RegisterNetEvent('ss-skylift:detachVehicle', function(attachedEntity, ActivePlayers)
    for _, v in ipairs(ActivePlayers) do
        TriggerClientEvent('ss-skylift:detachVehicle', v, attachedEntity)
    end
end)