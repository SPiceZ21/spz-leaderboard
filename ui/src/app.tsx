import { useState, useEffect, useMemo } from 'preact/hooks'
import { Flag, Trophy, Timer, MapPin, ChevronDown } from 'lucide-preact'
import { Badge } from './components/Badge'
import { Tabs } from './components/Tabs'
import './components/Badge.css'
import './components/Avatar.css'
import './components/Tabs.css'

interface LeaderboardEntry {
  rank: number
  name: string
  vehicle?: string
  time?: string
  points?: number
  wins?: number
  avatar?: string
  track?: string
}

function NametagBanner({ title, subtitle }: { title: string; subtitle: string }) {
  return (
    <div class="nametag-banner">
      <div class="nametag-avatar">
        <Flag size={24} />
      </div>
      <div class="nametag-info">
        <span class="nametag-subtitle">{subtitle}</span>
        <span class="nametag-name">{title}</span>
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

function LeaderboardRow({ entry, index, type }: { entry: LeaderboardEntry; index: number; type: 'points' | 'timetrial' }) {
  const initials = entry.name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2)
  const isLeader = entry.rank === 1
  
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
            <span class="player-meta">{type === 'points' ? 'Competitive' : 'Time Trial'}</span>
          </div>
        </div>
      </td>
      {type === 'timetrial' ? (
        <>
          <td class="vehicle-cell">{entry.vehicle || '—'}</td>
          <td class={`time-cell${isLeader ? ' leader' : ''}`}>{entry.time}</td>
        </>
      ) : (
        <>
          <td class="stat-cell" style={{ textAlign: 'right' }}>{entry.wins ?? 0}</td>
          <td class="points-cell" style={{ textAlign: 'right' }}>
            <span class="points-value">{entry.points ?? 0}</span>
            <span class="points-label">PTS</span>
          </td>
        </>
      )}
    </tr>
  )
}

export function App() {
  const [visible, setVisible] = useState(false)
  const [activeTab, setActiveTab] = useState('points')
  const [trackFilter, setTrackFilter] = useState('all')
  const [pointEntries, setPointEntries] = useState<LeaderboardEntry[]>([])
  const [timeTrialEntries, setTimeTrialEntries] = useState<LeaderboardEntry[]>([])
  const [tracks, setTracks] = useState<{id: string, name: string}[]>([])

  useEffect(() => {
    const handler = (e: MessageEvent) => {
      const { action, data } = e.data
      if (action === 'showLeaderboard') {
        if (data.points) setPointEntries(data.points)
        if (data.timetrial) setTimeTrialEntries(data.timetrial)
        if (data.tracks) setTracks(data.tracks)
        if (data.defaultTab) setActiveTab(data.defaultTab)
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

  const filteredEntries = useMemo(() => {
    if (activeTab === 'points') return pointEntries
    if (trackFilter === 'all') return timeTrialEntries
    return timeTrialEntries.filter(e => e.track === trackFilter)
  }, [activeTab, trackFilter, pointEntries, timeTrialEntries])

  if (!visible) return null

  const tabs = [
    { id: 'points', label: 'Points Standings', icon: Trophy },
    { id: 'timetrial', label: 'Time Trial', icon: Timer },
  ]

  return (
    <div id="app">
      <div class="leaderboard-container">
        <NametagBanner 
          subtitle="Spicez Competitive" 
          title={activeTab === 'points' ? 'Global Standings' : 'Track Records'} 
        />
        
        <div class="leaderboard-controls">
          <Tabs 
            tabs={tabs} 
            activeTab={activeTab} 
            onChange={setActiveTab} 
            variant="pills"
          />
          
          {activeTab === 'timetrial' && (
            <div class="filter-wrapper">
              <MapPin size={14} class="filter-icon" />
              <select 
                class="track-select" 
                value={trackFilter} 
                onChange={(e) => setTrackFilter((e.target as HTMLSelectElement).value)}
              >
                <option value="all">All Tracks</option>
                {tracks.map(t => (
                  <option key={t.id} value={t.id}>{t.name}</option>
                ))}
              </select>
              <ChevronDown size={14} class="select-chevron" />
            </div>
          )}
        </div>

        <div class="leaderboard-table-wrap">
          <table class="spz-table">
            <thead>
              {activeTab === 'points' ? (
                <tr>
                  <th style={{ textAlign: 'center', width: 60 }}>Pos</th>
                  <th>Driver</th>
                  <th style={{ textAlign: 'right' }}>Wins</th>
                  <th style={{ textAlign: 'right' }}>Points</th>
                </tr>
              ) : (
                <tr>
                  <th style={{ textAlign: 'center', width: 60 }}>Pos</th>
                  <th>Driver</th>
                  <th>Vehicle</th>
                  <th style={{ textAlign: 'right' }}>Time</th>
                </tr>
              )}
            </thead>
            <tbody>
              {filteredEntries.length > 0 ? (
                filteredEntries.map((entry, i) => (
                  <LeaderboardRow 
                    key={`${activeTab}-${entry.rank}-${i}`} 
                    entry={entry} 
                    index={i} 
                    type={activeTab as 'points' | 'timetrial'}
                  />
                ))
              ) : (
                <tr>
                  <td colspan={4} style={{ textAlign: 'center', padding: '40px', opacity: 0.5 }}>
                    No entries found
                  </td>
                </tr>
              )}
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

