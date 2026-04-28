import { useState, useEffect } from 'preact/hooks'
import { Flag } from 'lucide-preact'
import { Badge } from './components/Badge'
import './components/Badge.css'
import './components/Avatar.css'

interface LeaderboardEntry {
  rank: number
  name: string
  vehicle: string
  time: string
  avatar?: string
}

function NametagBanner({ name }: { name: string }) {
  return (
    <div class="nametag-banner">
      <div class="nametag-avatar">
        <Flag size={24} />
      </div>
      <div class="nametag-info">
        <span class="nametag-subtitle">Track Leaderboard</span>
        <span class="nametag-name">{name}</span>
      </div>
      <div style={{ marginLeft: 'auto', textAlign: 'right' }}>
        <div class="nametag-subtitle">Telemetry</div>
        <div class="status-pill">
          <div class="status-dot" />
          <span style={{ color: '#29D398', fontWeight: 700, fontSize: 11, fontFamily: 'var(--font-mono)' }}>
            LIVE
          </span>
        </div>
      </div>
    </div>
  )
}

function LeaderboardRow({ entry, index }: { entry: LeaderboardEntry; index: number }) {
  const initials = entry.name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2)
  const isLeader = entry.rank === 1
  const gap = index === 0
    ? <span style={{ opacity: 0.3 }}>—</span>
    : `+${(index * 0.421 + Math.random() * 0.3).toFixed(3)}`

  return (
    <tr class="leaderboard-row-animate" style={{ animationDelay: `${0.08 + index * 0.03}s` }}>
      <td class="rank-cell">
        {isLeader
          ? <Badge variant="primary">01</Badge>
          : <span style={{ opacity: 0.5, fontFamily: 'var(--font-primary)', fontWeight: 800 }}>
              {entry.rank.toString().padStart(2, '0')}
            </span>
        }
      </td>
      <td>
        <div class="player-cell">
          <span class="spz-avatar" style={{ width: 24, height: 24, fontSize: 10 }}>
            {entry.avatar ? <img src={entry.avatar} alt="" /> : initials}
          </span>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <span class="player-name">{entry.name}</span>
            <span class="player-meta">Pro Driver</span>
          </div>
        </div>
      </td>
      <td class="vehicle-cell">{entry.vehicle}</td>
      <td class="gap-cell">{gap}</td>
      <td class={`time-cell${isLeader ? ' leader' : ''}`}>{entry.time}</td>
    </tr>
  )
}

export function App() {
  const [visible, setVisible] = useState(false)
  const [trackName, setTrackName] = useState('Los Santos Circuit')
  const [entries, setEntries] = useState<LeaderboardEntry[]>([])

  useEffect(() => {
    const handler = (e: MessageEvent) => {
      const { action, data } = e.data
      if (action === 'showLeaderboard') {
        setTrackName(data.trackName || 'Unknown Track')
        setEntries(data.entries || [])
        setVisible(true)
      } else if (action === 'hideLeaderboard') {
        setVisible(false)
      }
    }
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && visible) {
        setVisible(false)
        fetch('https://spz-leaderboard/close', { method: 'POST' }).catch(() => {})
      }
    }
    window.addEventListener('message', handler)
    window.addEventListener('keydown', onKey)
    return () => {
      window.removeEventListener('message', handler)
      window.removeEventListener('keydown', onKey)
    }
  }, [visible])

  if (!visible) return null

  return (
    <div id="app">
      <div class="leaderboard-container">
        <NametagBanner name={trackName} />
        <div class="leaderboard-table-wrap">
          <table class="spz-table">
            <thead>
              <tr>
                <th style={{ textAlign: 'center', width: 60 }}>Pos</th>
                <th>Driver</th>
                <th>Vehicle</th>
                <th style={{ textAlign: 'right' }}>Gap</th>
                <th style={{ textAlign: 'right' }}>Lap Time</th>
              </tr>
            </thead>
            <tbody>
              {entries.map((entry, i) => (
                <LeaderboardRow key={entry.rank} entry={entry} index={i} />
              ))}
            </tbody>
          </table>
        </div>
        <div class="leaderboard-hint">
          <span>[ESC] To Close</span>
          <span class="sep">|</span>
          <span>Spicez-Core Competitive</span>
        </div>
      </div>
    </div>
  )
}
