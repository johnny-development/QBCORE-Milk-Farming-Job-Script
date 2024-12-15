local QBCore = exports['qb-core']:GetCoreObject()
local hasJob = false -- Tracks if the player has started the job
local currentTask = nil -- Tracks the current task stage
local milkingProgress = {} -- Tracks which cows have been milked

-- Add Blips and Spawn Cows
local function createBlipsAndCows()
    -- Job NPC Blip
    local jobBlip = AddBlipForCoord(Config.NPC.JobNPC.coords.x, Config.NPC.JobNPC.coords.y, Config.NPC.JobNPC.coords.z)
    SetBlipSprite(jobBlip, 442) -- Briefcase icon
    SetBlipDisplay(jobBlip, 4)
    SetBlipScale(jobBlip, 0.8)
    SetBlipColour(jobBlip, 5) -- Yellow
    SetBlipAsShortRange(jobBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Milk Job Start")
    EndTextCommandSetBlipName(jobBlip)

    -- Sell NPC Blip
    local sellBlip = AddBlipForCoord(Config.NPC.SellNPC.coords.x, Config.NPC.SellNPC.coords.y, Config.NPC.SellNPC.coords.z)
    SetBlipSprite(sellBlip, 605) -- Dollar icon
    SetBlipDisplay(sellBlip, 4)
    SetBlipScale(sellBlip, 0.8)
    SetBlipColour(sellBlip, 11) -- Blue
    SetBlipAsShortRange(sellBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Milk Selling Point")
    EndTextCommandSetBlipName(sellBlip)

    -- Spawn Cows and Blips
    for i, cow in ipairs(Config.Cows.Locations) do
        local cowModel = GetHashKey('a_c_cow')
        RequestModel(cowModel)
        while not HasModelLoaded(cowModel) do Wait(10) end

        local cowPed = CreatePed(4, cowModel, cow.coords.x, cow.coords.y, cow.coords.z - 1.0, cow.heading, false, true)
        FreezeEntityPosition(cowPed, true)
        SetEntityInvincible(cowPed, true)
        SetBlockingOfNonTemporaryEvents(cowPed, true)
        SetPedCanRagdoll(cowPed, false)

        -- Initialize milking progress for this cow
        milkingProgress[i] = false

        -- Add interaction with cow
        if Config.UseQBTarget then
            exports['qb-target']:AddTargetEntity(cowPed, {
                options = {
                    {
                        type = 'client',
                        event = 'milkjob:milkCow',
                        icon = 'fas fa-hand-holding-water',
                        label = 'Milk the Cow',
                        cowIndex = i -- Pass the cow index
                    }
                },
                distance = 2.5
            })
        else
            exports['qtarget']:AddTargetEntity(cowPed, {
                options = {
                    {
                        type = 'client',
                        event = 'milkjob:milkCow',
                        icon = 'fas fa-hand-holding-water',
                        label = 'Milk the Cow',
                        cowIndex = i -- Pass the cow index
                    }
                },
                distance = 2.5
            })
        end
    end
end

-- Check if all cows have been milked
local function allCowsMilked()
    for _, milked in ipairs(milkingProgress) do
        if not milked then
            return false
        end
    end
    return true
end

-- Start Milk Job
RegisterNetEvent('milkjob:startJob', function()
    if hasJob then
        TriggerEvent('QBCore:Notify', 'You are already working as a milk farmer.', 'error')
        return
    end

    hasJob = true
    currentTask = 'milkCows'
    TriggerEvent('QBCore:Notify', 'You have started the milk farming job. Milk all the cows to complete your task!', 'success')
end)

-- Milk Cow Event
RegisterNetEvent('milkjob:milkCow', function(data)
    if not hasJob then
        TriggerEvent('QBCore:Notify', 'You need to start the milk farming job first!', 'error')
        return
    end

    if currentTask ~= 'milkCows' then
        TriggerEvent('QBCore:Notify', 'You are not supposed to milk cows right now!', 'error')
        return
    end

    local cowIndex = data.cowIndex
    if milkingProgress[cowIndex] then
        TriggerEvent('QBCore:Notify', 'This cow has already been milked!', 'error')
        return
    end

    local ped = PlayerPedId()
    QBCore.Functions.Progressbar('milking_cow', 'Milking the Cow...', 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'amb@world_human_gardener_plant@male@base',
        anim = 'base',
        flags = 49,
    }, {}, {}, function()
        milkingProgress[cowIndex] = true -- Mark the cow as milked
        TriggerServerEvent('milkjob:rewardMilk')
        ClearPedTasks(ped)
        TriggerEvent('QBCore:Notify', 'You have milked the cow!', 'success')

        -- Check if all cows are milked
        if allCowsMilked() then
            currentTask = 'sellMilk'
            TriggerEvent('QBCore:Notify', 'All cows have been milked! Go to the selling point to complete your job.', 'success')
            SetNewWaypoint(Config.NPC.SellNPC.coords.x, Config.NPC.SellNPC.coords.y)
        end
    end, function()
        ClearPedTasks(ped)
        TriggerEvent('QBCore:Notify', 'You canceled the milking process.', 'error')
    end)
end)

-- Sell Milk Event
RegisterNetEvent('milkjob:sellMilk', function()
    if not hasJob then
        TriggerEvent('QBCore:Notify', 'You need to start the milk farming job first!', 'error')
        return
    end

    if currentTask ~= 'sellMilk' then
        TriggerEvent('QBCore:Notify', 'You must milk all the cows before selling!', 'error')
        return
    end

    TriggerServerEvent('milkjob:sellMilk')
    TriggerEvent('QBCore:Notify', 'You have completed the milk job. Come back to the job NPC to start again!', 'success')
    hasJob = false
    currentTask = nil
    milkingProgress = {} -- Reset milking progress
end)

-- Initialize Blips and Cows
CreateThread(createBlipsAndCows)
