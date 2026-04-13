fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/cache.lua',
    'server/writer.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

exports {
    'WriteRaceSession',
    'WriteResult',
    'UpdateTrackRecord'
}
