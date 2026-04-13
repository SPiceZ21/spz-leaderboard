---@param results table
function WriteRaceSession(results)
    MySQL.Sync.execute(
        [[INSERT IGNORE INTO race_sessions
          (race_id, track, track_type, car_class, laps, player_count, duration_ms)
          VALUES (?, ?, ?, ?, ?, ?, ?)]],
        {
            results.raceId,
            results.track,
            results.type,
            results.carClass,
            results.laps,
            #results.finishers + #results.dnf,
            results.duration,
        }
    )
end

---@param raceId string
---@param playerResult table
function WriteResult(raceId, playerResult)
    local profile = exports["spz-identity"]:GetProfile(playerResult.source)
    if not profile then return end

    MySQL.Sync.execute(
        [[INSERT INTO race_results
          (race_id, player_id, position, finish_time, best_lap, lap_times,
           points_earned, sr_change, irating_change, xp_earned, personal_best, dnf, dnf_reason)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)]],
        {
            raceId,
            profile.id,
            playerResult.position or 99,
            playerResult.finish_time,
            playerResult.best_lap,
            playerResult.lap_times and json.encode(playerResult.lap_times) or nil,
            playerResult.points_earned or 0,
            playerResult.sr_change or 0,
            playerResult.irating_change or 0,
            playerResult.xp_earned or 0,
            playerResult.personal_best and 1 or 0,
            playerResult.dnf and 1 or 0,
            playerResult.dnf_reason,
        }
    )
end

---@param track string
---@param trackType string
---@param carClass number
---@param finisher table
function UpdateTrackRecord(track, trackType, carClass, finisher)
    if finisher.dnf or not finisher.finish_time then return end

    -- player_id lookup
    local profile = exports["spz-identity"]:GetProfile(finisher.source)
    local playerId = profile and profile.id or nil
    if not playerId then return end

    MySQL.Sync.execute(
        [[INSERT INTO track_records (track, track_type, car_class, player_id, best_time, best_lap)
          VALUES (?, ?, ?, ?, ?, ?)
          ON DUPLICATE KEY UPDATE
            best_time = IF(VALUES(best_time) < best_time, VALUES(best_time), best_time),
            best_lap  = IF(VALUES(best_time) < best_time, VALUES(best_lap),  best_lap),
            set_at    = IF(VALUES(best_time) < best_time, NOW(),             set_at)]],
        {
            track,
            trackType,
            carClass,
            playerId,
            finisher.finish_time,
            finisher.best_lap,
        }
    )
end

-- Exports
exports('WriteRaceSession', WriteRaceSession)
exports('WriteResult', WriteResult)
exports('UpdateTrackRecord', UpdateTrackRecord)
