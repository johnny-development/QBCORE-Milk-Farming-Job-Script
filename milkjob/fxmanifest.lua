fx_version 'cerulean'
game 'gta5'

author 'YourName'
description 'Milk Job Script'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Ensure this matches your database wrapper
    'server/main.lua',
}
