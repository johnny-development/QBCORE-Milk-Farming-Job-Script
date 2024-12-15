local QBCore = exports['qb-core']:GetCoreObject()
local hasJob = false -- Tracks if the player has started the job
local currentTask = nil -- Tracks the current task stage

-- Add Blips
local function createBlips()
    -- Job NPC Blip
    local jobBlip = AddBlipForCoord(Config.NPC.JobNPC.coords.x, Config.NPC.JobNPC.coords.y, Config.NPC.JobNPC.coords.z)
    SetBlipSprite(jobBlip, 442) -- Use a suitable blip sprite for jobs
    SetBlipDisplay(jobBlip, 4)
    SetBlipScale(jobBlip, 0.8)
    SetBlipColour(jobBlip, 5) -- Yellow
    SetBlipAsShortRange(jobBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Milk Job Start")
    EndTextCommandSetBlipName(jobBlip)

    -- Cow Location Blip
    local cowBlip = AddBlipForCoord(Config.Tasks.CowLocation.coords.x, Config.Tasks.CowLocation.coords.y, Config.Tasks.CowLocation.coords.z)
    SetBlipSprite(cowBlip, 442) -- Use a cow-related sprite
    SetBlipDisplay(cowBlip, 4)
    SetBlipScale(cowBlip, 0.8)
    SetBlipColour(cowBlip, 25) -- Green
    SetBlipAsShortRange(cowBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Cow Milking Location")
    EndTextCommandSetBlipName(cowBlip)

    -- Sell Location Blip
    local sellBlip = AddBlipForCoord(Config.Tasks.SellLocation.coords.x, Config.Tasks.SellLocation.coords.y, Config.Tasks.SellLocation.coords.z)
    SetBlipSprite(sellBlip, 605) -- Use a cash icon for selling
    SetBlipDisplay(sellBlip, 4)
    SetBlipScale(sellBlip, 0.8)
    SetBlipColour(sellBlip, 11) -- Blue
    SetBlipAsShortRange(sellBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Milk Selling Point")
    EndTextCommandSetBlipName(sellBlip)
end

-- Spawn NPCs and Cow
CreateThread(function()
    createBlips() -- Create the blips

    -- Spawn Job NPC
    local jobNPC = Config.NPC.JobNPC
    local pedModel = GetHashKey(jobNPC.model)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(10) end
    local jobPed = CreatePed(4, pedModel, jobNPC.coords.x, jobNPC.coords.y, jobNPC.coords.z - 1.0, jobNPC.heading, false, true)
    FreezeEntityPosition(jobPed, true)
    SetEntityInvincible(jobPed, true)
    SetBlockingOfNonTemporaryEvents(jobPed, true)

    -- Spawn Cow
    local cow = Config.Tasks.CowLocation
    local cowModel = GetHashKey('a_c_cow')
    RequestModel(cowModel)
    while not HasModelLoaded(cowModel) do Wait(10) end
    local cowPed = CreatePed(4, cowModel, cow.coords.x, cow.coords.y, cow.coords.z - 1.0, cow.heading, false, true)
    FreezeEntityPosition(cowPed, true)
    SetEntityInvincible(cowPed, true)
    SetBlockingOfNonTemporaryEvents(cowPed, true)
    SetPedCanRagdoll(cowPed, false)

    -- Spawn Sell NPC
    local sellNPC = Config.NPC.SellNPC
    local sellPedModel = GetHashKey(sellNPC.model)
    RequestModel(sellPedModel)
    while not HasModelLoaded(sellPedModel) do Wait(10) end
    local sellPed = CreatePed(4, sellPedModel, sellNPC.coords.x, sellNPC.coords.y, sellNPC.coords.z - 1.0, sellNPC.heading, false, true)
    FreezeEntityPosition(sellPed, true)
    SetEntityInvincible(sellPed, true)
    SetBlockingOfNonTemporaryEvents(sellPed, true)
    SetPedCanRagdoll(sellPed, false)

    -- Setup Interactions
    if Config.UseQBTarget then
        -- QB-target Setup
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

        exports['qb-target']:AddTargetEntity(cowPed, {
            options = {
                {
                    type = 'client',
                    event = 'milkjob:milkCow',
                    icon = 'fas fa-hand-holding-water',
                    label = 'Milk the Cow'
                }
            },
            distance = 2.5
        })

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
    else
        -- QTarget Setup
        exports['qtarget']:AddTargetEntity(jobPed, {
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

        exports['qtarget']:AddTargetEntity(cowPed, {
            options = {
                {
                    type = 'client',
                    event = 'milkjob:milkCow',
                    icon = 'fas fa-hand-holding-water',
                    label = 'Milk the Cow'
                }
            },
            distance = 2.5
        })

        exports['qtarget']:AddTargetEntity(sellPed, {
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
end)

-- Start Milk Job
RegisterNetEvent('milkjob:startJob', function()
    if hasJob then
        TriggerEvent('QBCore:Notify', 'You are already working as a milk farmer.', 'error')
        return
    end

    hasJob = true
    currentTask = 'milkCow'
    SetNewWaypoint(Config.Tasks.CowLocation.coords.x, Config.Tasks.CowLocation.coords.y)
    TriggerEvent('QBCore:Notify', 'You have started the milk farming job. Go to the cow to begin!', 'success')
end)

-- Milk Cow Event
RegisterNetEvent('milkjob:milkCow', function()
    if not hasJob then
        TriggerEvent('QBCore:Notify', 'You need to start the milk farming job first!', 'error')
        return
    end

    if currentTask ~= 'milkCow' then
        TriggerEvent('QBCore:Notify', 'You are not supposed to milk the cow yet!', 'error')
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
        TriggerServerEvent('milkjob:rewardMilk')
        ClearPedTasks(ped)
        currentTask = 'sellMilk'
        SetNewWaypoint(Config.Tasks.SellLocation.coords.x, Config.Tasks.SellLocation.coords.y)
        TriggerEvent('QBCore:Notify', 'You have milked the cow. Deliver the milk to the selling point!', 'success')
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
        TriggerEvent('QBCore:Notify', 'You are not ready to sell milk yet!', 'error')
        return
    end

    TriggerServerEvent('milkjob:sellMilk')
    TriggerEvent('QBCore:Notify', 'You have completed the milk job. Come back to the job NPC to start again!', 'success')
    hasJob = false
    currentTask = nil
end)
