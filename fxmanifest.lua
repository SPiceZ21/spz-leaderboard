fx_version 'cerulean'
game 'gta5'

name 'spz-leaderboard'
description 'SPiceZ-Core — Leaderboard tablet UI (race results and archive, standings, classes, records, activity)'
version '1.7.3'
author 'SPiceZ-Core'
lua54 'on'

shared_script '@ox_lib/init.lua'

client_scripts {
    '@spz-hud/shim.lua',   -- NUI goes through spz-hud
    'client/main.lua',
}

exports {
    'OpenLastRaceResults',
}

-- ui_page 'ui/index.html'  -- drawn by spz-hud now (web/public/apps/spz-leaderboard); uncomment + drop the shim to roll back

-- UI files are not shipped from here: spz-hud serves this resource's page
-- (synced from ui/ by spz-hud/tools/sync-apps.mjs).

dependencies {
    'spz-hud',
    'ox_lib',
    'spz-core',
    'spz-races',
}
