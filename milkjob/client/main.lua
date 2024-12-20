local QBCore = exports['qb-core']:GetCoreObject()
local hasJob = false -- Tracks if the player has started the job
local currentTask = nil -- Tracks the current task stage
local spawnedVehicle = nil -- Tracks the spawned vehicle
local milkingProgress = {} -- Tracks which cows have been milked

-- Spawn NPCs and Blips
local function spawnNPCs()
    -- Spawn Job NPC
    local jobNPC = Config.NPC.JobNPC
    local pedModel = GetHashKey(jobNPC.model)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(10) end
    local jobPed = CreatePed(4, pedModel, jobNPC.coords.x, jobNPC.coords.y, jobNPC.coords.z - 1.0, jobNPC.heading, false, true)
    FreezeEntityPosition(jobPed, true)
    SetEntityInvincible(jobPed, true)
    SetBlockingOfNonTemporaryEvents(jobPed, true)

    -- Add interaction for Job NPC
    if Config.UseQBTarget then
        exports['qb-target']:AddTargetEntity(jobPed, {
            options = {
                {
                    type = 'client',
                    event = 'milkjob:startJob',
                    icon = 'fas fa-briefcase',
                    label = 'Start Milk Job'
                }
            },
            distance = 2.5
        })
    end

    -- Add Job NPC Blip
    local jobBlip = AddBlipForCoord(jobNPC.coords.x, jobNPC.coords.y, jobNPC.coords.z)
    SetBlipSprite(jobBlip, 442) -- Briefcase icon
    SetBlipDisplay(jobBlip, 4)
    SetBlipScale(jobBlip, 0.8)
    SetBlipColour(jobBlip, 5) -- Yellow
    SetBlipAsShortRange(jobBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Milk Job Start")
    EndTextCommandSetBlipName(jobBlip)

    -- Spawn Sell NPC
    local sellNPC = Config.NPC.SellNPC
    local sellPedModel = GetHashKey(sellNPC.model)
    RequestModel(sellPedModel)
    while not HasModelLoaded(sellPedModel) do Wait(10) end
    local sellPed = CreatePed(4, sellPedModel, sellNPC.coords.x, sellNPC.coords.y, sellNPC.coords.z - 1.0, sellNPC.heading, false, true)
    FreezeEntityPosition(sellPed, true)
    SetEntityInvincible(sellPed, true)
    SetBlockingOfNonTemporaryEvents(sellPed, true)

    -- Add interaction for Sell NPC
    if Config.UseQBTarget then
        exports['qb-target']:AddTargetEntity(sellPed, {
            options = {
                {
                    type = 'client',
                    event = 'milkjob:sellMilk',
                    icon = 'fas fa-dollar-sign',
                    label = 'Sell Milk'
                }
            },
            distance = 2.5
        })
    end

    -- Add Sell NPC Blip
    local sellBlip = AddBlipForCoord(sellNPC.coords.x, sellNPC.coords.y, sellNPC.coords.z)
    SetBlipSprite(sellBlip, 605) -- Dollar icon
    SetBlipDisplay(sellBlip, 4)
    SetBlipScale(sellBlip, 0.8)
    SetBlipColour(sellBlip, 11) -- Blue
    SetBlipAsShortRange(sellBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Milk Selling Point")
    EndTextCommandSetBlipName(sellBlip)
end

-- Spawn Cows
local function spawnCows()
    for i, cow in ipairs(Config.Cows.Locations) do
        local cowModel = GetHashKey('a_c_cow')
        RequestModel(cowModel)
        while not HasModelLoaded(cowModel) do Wait(10) end

        local cowPed = CreatePed(4, cowModel, cow.coords.x, cow.coords.y, cow.coords.z - 1.0, cow.heading, false, true)
        FreezeEntityPosition(cowPed, true)
        SetEntityInvincible(cowPed, true)
        SetBlockingOfNonTemporaryEvents(cowPed, true)
        SetPedCanRagdoll(cowPed, false)

        -- Add Cow Blip
        local cowBlip = AddBlipForCoord(cow.coords.x, cow.coords.y, cow.coords.z)
        SetBlipSprite(cowBlip, 442) -- Cow icon (can be customized)
        SetBlipDisplay(cowBlip, 4)
        SetBlipScale(cowBlip, 0.7)
        SetBlipColour(cowBlip, 25) -- Green
        SetBlipAsShortRange(cowBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Milking Cow")
        EndTextCommandSetBlipName(cowBlip)

        -- Add interaction for cows
        if Config.UseQBTarget then
            exports['qb-target']:AddTargetEntity(cowPed, {
                options = {
                    {
                        type = 'client',
                        event = 'milkjob:milkCow',
                        icon = 'fas fa-hand-holding-water',
                        label = 'Milk the Cow',
                        cowIndex = i
                    }
                },
                distance = 2.5
            })
        end
    end
end

-- Start Milk Job
RegisterNetEvent('milkjob:startJob', function()
    if hasJob then
        TriggerEvent('QBCore:Notify', 'You are already working as a milk farmer.', 'error')
        return
    end

    hasJob = true
    currentTask = 'milkCows'

    -- Spawn vehicle
    local vehicleHash = GetHashKey(Config.Vehicle.model)
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do Wait(10) end
    spawnedVehicle = CreateVehicle(vehicleHash, Config.Vehicle.coords.x, Config.Vehicle.coords.y, Config.Vehicle.coords.z, Config.Vehicle.heading, true, false)
    SetVehicleOnGroundProperly(spawnedVehicle)
    SetEntityAsMissionEntity(spawnedVehicle, true, true)

    -- Give keys
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(spawnedVehicle))
    TriggerEvent('QBCore:Notify', 'Your vehicle has been spawned, and you have been given the keys.', 'success')

    TriggerEvent('QBCore:Notify', 'You have started the milk farming job. Milk all the cows to complete your task!', 'success')
end)

-- Milk Cow Event
RegisterNetEvent('milkjob:milkCow', function(data)
    local cowIndex = data.cowIndex
    if milkingProgress[cowIndex] then
        TriggerEvent('QBCore:Notify', 'This cow has already been milked!', 'error')
        return
    end

    QBCore.Functions.Progressbar('milking_cow', 'Milking the Cow...', 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        milkingProgress[cowIndex] = true
        TriggerServerEvent('milkjob:rewardMilk')
        TriggerEvent('QBCore:Notify', 'You have milked the cow!', 'success')
    end, function()
        TriggerEvent('QBCore:Notify', 'You canceled the milking process.', 'error')
    end)
end)

-- Sell Milk Event
RegisterNetEvent('milkjob:sellMilk', function()
    if not hasJob then
        TriggerEvent('QBCore:Notify', 'You need to start the milk farming job first!', 'error')
        return
    end

    -- Despawn the vehicle
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        DeleteEntity(spawnedVehicle)
        spawnedVehicle = nil
        TriggerEvent('QBCore:Notify', 'Your vehicle has been removed.', 'info')
    end

    TriggerServerEvent('milkjob:sellMilk')
    TriggerEvent('QBCore:Notify', 'You have completed the milk job. Come back to the job NPC to start again!', 'success')
    hasJob = false
    currentTask = nil
    milkingProgress = {} -- Reset progress
end)

-- Initialize
CreateThread(function()
    spawnNPCs()
    spawnCows()
end)
