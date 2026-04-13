CREATE TABLE IF NOT EXISTS race_sessions (
  id           INT         AUTO_INCREMENT PRIMARY KEY,
  race_id      VARCHAR(64) NOT NULL UNIQUE,   -- UUID from spz-races
  track        VARCHAR(64) NOT NULL,
  track_type   VARCHAR(16) NOT NULL,          -- "circuit" | "sprint"
  car_class    TINYINT     NOT NULL,          -- 0–3
  laps         TINYINT     NOT NULL,
  player_count TINYINT     NOT NULL,
  duration_ms  INT,                           -- total race duration ms
  created_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_track       (track, car_class),
  INDEX idx_created     (created_at)
);

CREATE TABLE IF NOT EXISTS race_results (
  id              INT         AUTO_INCREMENT PRIMARY KEY,
  race_id         VARCHAR(64) NOT NULL,
  player_id       INT         NOT NULL,
  position        TINYINT     NOT NULL,
  finish_time     INT,                        -- total ms, NULL if DNF
  best_lap        INT,                        -- fastest lap ms, NULL for sprint/DNF
  lap_times       JSON,                       -- [65432, 64100, 63900] circuit only
  points_earned   INT         DEFAULT 0,
  sr_change       FLOAT       DEFAULT 0,
  irating_change  INT         DEFAULT 0,
  xp_earned       INT         DEFAULT 0,
  personal_best   TINYINT     DEFAULT 0,      -- 1 if this was a new PB
  dnf             TINYINT     DEFAULT 0,
  dnf_reason      VARCHAR(32) NULL,           -- "disconnect"|"timeout"|"disqualified"
  created_at      TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

  -- FOREIGN KEY (player_id) REFERENCES players(id), -- Assuming players table exists
  INDEX idx_race        (race_id),
  INDEX idx_player      (player_id),
  INDEX idx_player_time (player_id, finish_time)
);

CREATE TABLE IF NOT EXISTS track_records (
  id            INT         AUTO_INCREMENT PRIMARY KEY,
  track         VARCHAR(64) NOT NULL,
  track_type    VARCHAR(16) NOT NULL,         -- "circuit" | "sprint"
  car_class     TINYINT     NOT NULL,
  player_id     INT         NOT NULL,
  best_time     INT         NOT NULL,         -- ms
  best_lap      INT,                          -- fastest single lap ms (circuit only)
  set_at        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  -- FOREIGN KEY (player_id) REFERENCES players(id),
  UNIQUE KEY uq_track_class_player (track, car_class, player_id),
  INDEX idx_track_class (track, car_class, best_time)   -- for leaderboard ORDER BY
);

CREATE TABLE IF NOT EXISTS season_snapshots (
  id           INT         AUTO_INCREMENT PRIMARY KEY,
  season_num   INT         NOT NULL,          -- increments per reset
  snapshot     JSON        NOT NULL,          -- full standings array at time of reset
  created_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_season (season_num)
);
