fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/cache.lua',
    'server/writer.lua',
    'server/records.lua',
    'server/standings.lua',
    'server/stats.lua',
    'server/snapshot.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

exports {
    'WriteRaceSession',
    'WriteResult',
    'UpdateTrackRecord',
    'GetPersonalBest',
    'GetTrackRecords',
    'GetAllTrackRecords',
    'GetGlobalStandings',
    'GetClassStandings',
    'GetPlayerStats',
    'GetPlayerHistory',
    'GetLastSnapshot'
}
