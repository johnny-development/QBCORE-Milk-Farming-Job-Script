Config = {}

-- Inventory Type (true for OX Inventory, false for QB Inventory)
Config.UseOxInventory = false

-- Toggle between QB-target and QTarget (true for QB-target, false for QTarget)
Config.UseQBTarget = true

Config.NPC = {
    JobNPC = {
        model = 'a_m_m_farmer_01',
        coords = vector3(-1316.57, -2795.61, 13.94),
        heading = 200.0
    },
    SellNPC = {
        model = 'csb_chef',
        coords = vector3(-1320.15, -2793.35, 13.94),
        heading = 150.0
    }
}

Config.Tasks = {
    CowLocation = {
        coords = vector3(-1323.35, -2791.7, 13.94), -- Location to milk the cow
        heading = 90.0
    },
    SellLocation = {
        coords = vector3(-1320.15, -2793.35, 13.94) -- Location to sell milk
    }
}

Config.Rewards = {
    MilkItem = 'milk_bucket',
    MinAmount = 1,
    MaxAmount = 3,
    SellPrice = 50
}
