local QBCore = exports['qb-core']:GetCoreObject()

-- Reward Milk Event
RegisterNetEvent('milkjob:rewardMilk', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = math.random(Config.Rewards.MinAmount, Config.Rewards.MaxAmount)

    if Config.UseOxInventory then
        exports.ox_inventory:AddItem(src, Config.Rewards.MilkItem, amount)
    else
        Player.Functions.AddItem(Config.Rewards.MilkItem, amount)
    end

    TriggerClientEvent('QBCore:Notify', src, 'You received ' .. amount .. ' milk buckets!', 'success')
end)

-- Sell Milk Event
RegisterNetEvent('milkjob:sellMilk', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Config.UseOxInventory then
        local milkCount = exports.ox_inventory:Search(src, 'count', Config.Rewards.MilkItem)
        if milkCount > 0 then
            exports.ox_inventory:RemoveItem(src, Config.Rewards.MilkItem, milkCount)
            local reward = milkCount * Config.Rewards.SellPrice
            Player.Functions.AddMoney('cash', reward)
            TriggerClientEvent('QBCore:Notify', src, 'You sold the milk for $' .. reward, 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'You have no milk to sell!', 'error')
        end
    else
        local milkCount = Player.Functions.GetItemByName(Config.Rewards.MilkItem)
        if milkCount and milkCount.amount > 0 then
            local reward = milkCount.amount * Config.Rewards.SellPrice
            Player.Functions.RemoveItem(Config.Rewards.MilkItem, milkCount.amount)
            Player.Functions.AddMoney('cash', reward)
            TriggerClientEvent('QBCore:Notify', src, 'You sold the milk for $' .. reward, 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'You have no milk to sell!', 'error')
        end
    end
end)
