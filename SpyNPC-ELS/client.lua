--[[
    NPC ELS Pattern Controller
    client.lua

    Architecture:
    - A scanner thread runs every NPC_ELS.scanInterval ms. It looks for NPC
      vehicles within NPC_ELS.scanRadius that have a siren active and whose
      model is listed in NPC_ELS.vehicles.
    - When a qualifying vehicle is found for the first time it gets its own
      dedicated pattern thread spawned for it. The thread index is stored in
      activeVehicles so it is never double-spawned.
    - When a vehicle's siren goes inactive OR it moves out of range OR it is
      deleted, its thread exits cleanly and the entry is removed from
      activeVehicles so it can be picked up again if the siren comes back on.
    - Player-driven vehicles are never touched regardless of model name.
    - Vehicles not in the config are never touched (existing behaviour).
]]



local activeVehicles = {}

local function resolvePatternSet(vehicleCfg)
    if vehicleCfg.patternSet then
        return vehicleCfg.patternSet
    end
    if vehicleCfg.patternSetName then
        return NPC_ELS.patternSets[vehicleCfg.patternSetName]
    end
    return nil
end

local function applyFrame(vehicle, frame)
    local onSet = {}
    for _, extraId in ipairs(frame.on) do
        onSet[extraId] = true
    end
    for i = 1, 14 do
        if DoesExtraExist(vehicle, i) then
            if onSet[i] then
                SetVehicleExtra(vehicle, i, false)
            else
                SetVehicleExtra(vehicle, i, true)
            end
        end
    end
end

local function shouldKeepRunning(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    if IsEntityDead(vehicle)        then return false end
    if not IsVehicleSeatFree(vehicle, -1) then
        local driver = GetPedInVehicleSeat(vehicle, -1)
        if IsPedAPlayer(driver) then return false end
    end
    if not IsVehicleSirenOn(vehicle) then return false end
    return true
end

local function spawnPatternThread(vehicle, patternSet)
    CreateThread(function()
        local frames       = patternSet.frames
        local speed        = patternSet.patternSpeed or NPC_ELS.scanInterval
        local frameCount   = #frames
        local currentFrame = 1

        if NPC_ELS.debugMode then
            local model = GetEntityModel(vehicle)
            print(('[npc_els] Pattern thread started for vehicle handle %d (model hash %d)'):format(vehicle, model))
        end

        while shouldKeepRunning(vehicle) do
            applyFrame(vehicle, frames[currentFrame])
            currentFrame = (currentFrame % frameCount) + 1
            Wait(speed)
        end

        activeVehicles[vehicle] = nil

        if NPC_ELS.debugMode then
            print(('[npc_els] Pattern thread ended for vehicle handle %d'):format(vehicle))
        end
    end)
end

CreateThread(function()
    Wait(3000)

    while true do
        local playerPed    = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local radius       = NPC_ELS.scanRadius

        local pool = GetGamePool('CVehicle')

        for _, vehicle in ipairs(pool) do
            if not activeVehicles[vehicle] then

                local vCoords = GetEntityCoords(vehicle)
                local dist    = #(playerCoords - vCoords)

                if dist <= radius then

                    if IsVehicleSirenOn(vehicle) then

                        local driver = GetPedInVehicleSeat(vehicle, -1)
                        local isNPC  = (driver ~= 0) and (not IsPedAPlayer(driver))

                        local noDriver = (driver == 0)

                        if isNPC or noDriver then

                            local modelHash = GetEntityModel(vehicle)
                            local modelName = string.lower(
                                GetDisplayNameFromVehicleModel(modelHash)
                            )

                            local vehicleCfg = NPC_ELS.vehicles[modelName]

                            if not vehicleCfg then
                                for spawnName, cfg in pairs(NPC_ELS.vehicles) do
                                    if GetHashKey(spawnName) == modelHash then
                                        vehicleCfg = cfg
                                        modelName  = spawnName
                                        break
                                    end
                                end
                            end

                            if NPC_ELS.debugMode and not vehicleCfg then
                                print(('[npc_els] Untracked NPC emergency vehicle: "%s" (hash %d)'):format(modelName, modelHash))
                            end

                            if vehicleCfg then
                                local patternSet = resolvePatternSet(vehicleCfg)

                                if patternSet and #patternSet.frames > 0 then
                                    activeVehicles[vehicle] = true
                                    spawnPatternThread(vehicle, patternSet)
                                end
                            end
                        end
                    end
                end
            end
        end

        Wait(NPC_ELS.scanInterval)
    end
end)
