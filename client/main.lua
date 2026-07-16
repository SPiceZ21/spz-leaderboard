-- client/main.lua
local isOpen = false

local function openBoard()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
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

    elseif tab == "activity" then
        lib.callback("spz-races:getActivityFeed", false, function(r) cb(r or {}) end, { limit = 50 })

    elseif tab == "me" then
        lib.callback("spz-races:getPlayerStats", false, function(r) cb(r or {}) end, {})

    else
        cb({})
    end
end)
