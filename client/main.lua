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

-- Default binding, declared once so the key registered here and the key the
-- race HUD prints are the same value.
local KEY_BOARD = "F6"

-- The race this player last finished. Set by spz-races when results land, so
-- opening the board straight after a race lands on THAT race rather than making
-- the player hunt for it in the archive.
--
-- Only while the result is FRESH. The board is a general leaderboard as well as
-- a results screen; pressing the key an hour later should open the leaderboard,
-- not drop you back into a race you have stopped caring about.
local RESULTS_FRESH_MS = 5 * 60 * 1000

local lastRaceId = nil
local lastRaceAt = 0

RegisterNetEvent("SPZ:raceEnd", function(results)
    if results and results.raceId then
        lastRaceId = results.raceId
        lastRaceAt = GetGameTimer()
    end
end)

-- The deep-link target, or nil when there is nothing recent to show.
local function freshRaceOpts()
    if not lastRaceId then return nil end
    if (GetGameTimer() - lastRaceAt) > RESULTS_FRESH_MS then return nil end
    return { tab = "races", raceId = lastRaceId }
end

local function openBoard(opts)
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)

    -- Name lets the UI mark and jump to the player's own row.
    local name = GetPlayerName(PlayerId())
    local ok, profile = pcall(function() return exports['spz-identity']:GetProfile() end)
    if ok and type(profile) == 'table' and profile.username then name = profile.username end

    SendNUIMessage({
        action = "open",
        player = name,
        -- nil for a normal open: the board starts where it always did.
        tab    = opts and opts.tab or nil,
        raceId = opts and opts.raceId or nil,
    })
end

local function closeBoard()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

-- F6. Straight into the race you just drove when one has just finished,
-- otherwise the leaderboard as it always opened.
RegisterCommand("leaderboard", function() openBoard(freshRaceOpts()) end, false)

-- Straight to the race you just drove. Called by spz-races from the post-race
-- prompt; falls back to the plain board if no race has finished this session.
-- Explicit results command: ignores the freshness window, because asking for
-- results by name means you want them however long ago the race was.
RegisterCommand("raceresults", function()
    openBoard(lastRaceId and { tab = "races", raceId = lastRaceId } or nil)
end, false)

exports("OpenLastRaceResults", function()
    openBoard(lastRaceId and { tab = "races", raceId = lastRaceId } or nil)
end)
RegisterKeyMapping("leaderboard", "Race results / leaderboard", "keyboard", KEY_BOARD)

-- Tell the race HUD which key opens results, so the in-race key strip prints it
-- alongside the recovery keys. spz-races pushes its own keys the same way; this
-- resource owns this one, so it pushes it itself rather than raceUI hardcoding
-- a value that lives here.
CreateThread(function()
    while GetResourceState("spz-raceUI") ~= "started" do Wait(500) end
    pcall(function()
        exports["spz-raceUI"]:SetKeyHints({ results = KEY_BOARD })
    end)
end)

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

RegisterNUICallback("rerollRival", function(_, cb)
    local res = lib.callback.await("spz-progression:rerollRival", false)
    if res and res.ok then lib.notify({ description = "New rival drawn", type = "success" })
    else lib.notify({ description = (res and res.error) or "Failed", type = "error" }) end
    cb(res or { ok = false })
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

    elseif tab == "races" then
        -- Archive list, or one race in full when the UI asks for a specific id.
        if data.raceId then
            lib.callback("spz-races:getRaceResults", false, function(r) cb(r or {}) end, { raceId = data.raceId })
        else
            lib.callback("spz-races:getRaceArchive", false, function(r) cb(r or {}) end, { limit = 40 })
        end

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
