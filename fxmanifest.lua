fx_version 'cerulean'
game 'gta5'

name 'spz-leaderboard'
description 'SPiceZ-Core — Leaderboard tablet UI (standings, classes, records, activity)'
version '1.0.0'
author 'SPiceZ-Core'
lua54 'on'

shared_script '@ox_lib/init.lua'

client_script 'client/main.lua'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/Assets/*.png',
    'ui/fonts/*.ttf',
}

dependencies {
    'ox_lib',
    'spz-races',
}
