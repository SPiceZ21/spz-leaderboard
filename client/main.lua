-- client/main.lua
local isOpen = false

-- Base theme (server.cfg spz_theme_* convars via spz-core).
local function pushLeaderboardTheme(theme)
    if theme and next(theme) then
        SendNUIMessage({ action = 'theme', theme = theme })
    end
end
CreateThread(function()
    local ok, theme = pcall(function() return exports['spz-core']:GetTheme() end)
    if ok then pushLeaderboardTheme(theme) end
end)
AddEventHandler('SPZ:themeUpdated', function(theme) pushLeaderboardTheme(theme) end)

local function openBoard()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)

    -- Name lets the UI mark and jump to the player's own row.
    local name = GetPlayerName(PlayerId())
    local ok, profile = pcall(function() return exports['spz-identity']:GetProfile() end)
    if ok and type(profile) == 'table' and profile.username then name = profile.username end

    SendNUIMessage({ action = "open", player = name })
end

local function closeBoard()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

RegisterCommand("leaderboard", function() openBoard() end, false)
RegisterKeyMapping("leaderboard", "Open Leaderboard", "keyboard", "F6")

-- ESC / Backspace fallback close
CreateThread(function()
    while true do
        if isOpen then
            if IsControlJustPressed(0, 200) or IsControlJustPressed(0, 177) then
                closeBoard()
            end
            Wait(0)
        else
            Wait(300)
        end
    end
end)

RegisterNUICallback("lbClose", function(_, cb)
    closeBoard()
    cb("ok")
end)

-- NUI asks for a tab's data → we relay to spz-races leaderboard callbacks
RegisterNUICallback("lbFetch", function(data, cb)
    local tab   = data.tab
    local class = data.class or "S"

    if tab == "standings" then
        lib.callback("spz-races:getGlobalStandings", false, function(r) cb(r or {}) end, { limit = 50 })

    elseif tab == "classes" then
        lib.callback("spz-races:getClassStandings", false, function(r) cb(r or {}) end, { class = class, limit = 50 })

    elseif tab == "records" then
        lib.callback("spz-races:getAllTrackRecords", false, function(r) cb(r or {}) end, {})

    elseif tab == "rivals" then
        lib.callback("spz-progression:getRivalBoard", false, function(r) cb(r or {}) end)

    elseif tab == "duels" then
        lib.callback("spz-races:getDuelBoard", false, function(r) cb(r or {}) end, { limit = 50 })

    elseif tab == "activity" then
        lib.callback("spz-races:getActivityFeed", false, function(r) cb(r or {}) end, { limit = 50 })

    elseif tab == "me" then
        -- Stats power the tiles; the recent-race history powers the charts.
        lib.callback("spz-races:getPlayerStats", false, function(stats)
            lib.callback("spz-races:getPlayerHistory", false, function(hist)
                lib.callback("spz-races:getPlayerActivity", false, function(activity)
                    lib.callback("spz-races:getPlayerTrackSummary", false, function(tracks)
                        cb({
                            stats    = stats or {},
                            history  = (hist and hist.rows) or {},
                            activity = activity or {},   -- day x track counts (heatmap)
                            tracks   = tracks or {},     -- career totals per track (filter)
                        })
                    end, {})
                end, { days = 364 })
            end, { page = 1, pageSize = 60 })
        end, {})

    else
        cb({})
    end
end)
