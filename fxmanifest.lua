fx_version 'cerulean'
game 'gta5'

name 'spz-leaderboard'
description 'SPiceZ-Core — Leaderboard tablet UI (race results and archive, standings, classes, records, activity)'
version '1.7.2'
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

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/Assets/*.png',
    'ui/Assets/ranks/*.svg',
    'ui/rankup.css',
    'ui/rankup.js',
    'ui/Assets/rankfx/*.webm',
    'ui/Assets/rankfx/*.png',
    'ui/Assets/rankfx/*.json',
    'ui/fonts/*.ttf',
}

dependencies {
    'spz-hud',
    'ox_lib',
    'spz-core',
    'spz-races',
}
