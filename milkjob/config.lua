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

Config.Cows = {
    Locations = {
        { coords = vector3(-1323.35, -2791.7, 13.94), heading = 90.0 },
        { coords = vector3(-1325.35, -2793.7, 13.94), heading = 90.0 },
        { coords = vector3(-1327.35, -2795.7, 13.94), heading = 90.0 },
        { coords = vector3(-1329.35, -2797.7, 13.94), heading = 90.0 },
        { coords = vector3(-1331.35, -2799.7, 13.94), heading = 90.0 },
        { coords = vector3(-1333.35, -2801.7, 13.94), heading = 90.0 },
        { coords = vector3(-1335.35, -2803.7, 13.94), heading = 90.0 },
        { coords = vector3(-1337.35, -2805.7, 13.94), heading = 90.0 },
        { coords = vector3(-1339.35, -2807.7, 13.94), heading = 90.0 },
        { coords = vector3(-1341.35, -2809.7, 13.94), heading = 90.0 },
        { coords = vector3(-1343.35, -2811.7, 13.94), heading = 90.0 },
        { coords = vector3(-1345.35, -2813.7, 13.94), heading = 90.0 },
        { coords = vector3(-1347.35, -2815.7, 13.94), heading = 90.0 },
        { coords = vector3(-1349.35, -2817.7, 13.94), heading = 90.0 },
        { coords = vector3(-1351.35, -2819.7, 13.94), heading = 90.0 }
    }
}

Config.Rewards = {
    MilkItem = 'milk_bucket',
    MinAmount = 1,
    MaxAmount = 3,
    SellPrice = 50
}
