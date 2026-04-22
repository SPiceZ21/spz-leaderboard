fx_version 'cerulean'
game 'gta5'

name 'spz-leaderboard'
description 'SPiceZ-Core — Race results, track records, global standings'
version '1.0.0'
author 'SPiceZ-Core'

lua54 'yes'

shared_scripts {
    'shared/init.lua',
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

dependencies {
    'spz-lib',
    'spz-core',
    'spz-identity',
    'spz-races',
    'spz-progression',
    'oxmysql'
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
