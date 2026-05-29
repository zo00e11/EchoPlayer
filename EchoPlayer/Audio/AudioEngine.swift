//
//  AudioEngine.swift
//  EchoPlayer
//

import AVFoundation
import Combine

struct Song: Identifiable, Equatable {
    let id: String
    let url: URL
    let name: String
    let ext: String

    init(url: URL, name: String, ext: String) {
        self.id = url.resolvingSymlinksInPath().path
        self.url = url
        self.name = name
        self.ext = ext
    }
}

class AudioEngine: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Float = 0.5
    @Published var speed: Float = 1.0
    @Published var songName = "EchoPlayer"
    @Published var artist = "drop music to start"
    @Published var currentSong: Song?
    @Published var playlist: [Song] = []
    @Published var frequencyBands: [Float] = Array(repeating: 0, count: 24)

    // 0=off, 1=one, 2=all
    var repeatMode: Int = 0

    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var currentPan: Float = 0

    override init() {
        super.init()
        loadPlaylist()
        scanFolder()
        if let first = playlist.first {
            songName = first.name
            artist = first.ext
        }
    }

    // MARK: - Persistence

    func savePlaylist() {
        let paths = playlist.map { $0.url.path }
        UserDefaults.standard.set(paths, forKey: "EchoPlayer_Playlist")
    }

    private func loadPlaylist() {
        guard let paths = UserDefaults.standard.array(forKey: "EchoPlayer_Playlist") as? [String] else { return }
        var loaded: [Song] = []
        for path in paths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                loaded.append(Song(url: url,
                                   name: url.deletingPathExtension().lastPathComponent,
                                   ext: url.pathExtension.uppercased()))
            }
        }
        playlist = loaded
    }

    func addFile(url: URL) {
        let needsAccess = url.startAccessingSecurityScopedResource()
        defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }
        let name = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension.uppercased()
        let song = Song(url: url, name: name, ext: ext)
        if !playlist.contains(where: { $0.url == url }) {
            playlist.append(song)
            savePlaylist()
        }
        playSong(song)
    }

    func removeSong(_ song: Song) {
        let wasPlaying = song == currentSong
        playlist.removeAll { $0.id == song.id }
        savePlaylist()
        if wasPlaying {
            stop()
            if let next = playlist.first {
                playSong(next)
            }
        }
    }

    func playSong(_ song: Song) {
        stop()
        let needsAccess = song.url.startAccessingSecurityScopedResource()
        defer { if needsAccess { song.url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: song.url)
            player = try AVAudioPlayer(data: data)
            player?.delegate = self
            player?.isMeteringEnabled = true
            player?.volume = volume
            player?.enableRate = true
            player?.rate = speed
            player?.pan = currentPan
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            currentTime = 0
            currentSong = song
            songName = song.name
            artist = song.ext
            play()
        } catch {
            songName = "load failed"
            artist = error.localizedDescription
        }
    }

    func next() {
        guard let c = currentSong, let i = playlist.firstIndex(of: c) else { return }
        playSong(playlist[(i + 1) % playlist.count])
    }

    func previous() {
        guard let c = currentSong, let i = playlist.firstIndex(of: c) else { return }
        playSong(playlist[(i - 1 + playlist.count) % playlist.count])
    }

    func play() {
        // No player but playlist exists -> load first song
        if player == nil, let first = playlist.first {
            playSong(first)
            return
        }
        guard player != nil else { return }
        player?.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }

    func toggle() {
        if player == nil, !playlist.isEmpty {
            playSong(playlist[0])
        } else if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        stopTimer()
        currentTime = 0
        duration = 0
        frequencyBands = Array(repeating: 0, count: 24)
    }

    func seek(to time: Double) {
        player?.currentTime = time
        currentTime = time
    }

    func setVolume(_ value: Float) {
        volume = value
        player?.volume = value
    }

    func setSpeed(_ value: Float) {
        speed = max(0.5, min(2.0, value))
        player?.rate = speed
    }

    func setPan(_ value: Float) {
        currentPan = value
        player?.pan = value
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch repeatMode {
        case 1: // ONE - replay same song
            player.currentTime = 0
            player.play()
        case 2: // ALL - next song, loop playlist
            next()
        default: // OFF - next song, stop at end
            if let c = currentSong, let i = playlist.firstIndex(of: c), i + 1 < playlist.count {
                next()
            } else {
                isPlaying = false
                stopTimer()
                currentTime = 0
            }
        }
    }

    // MARK: - Spectrum

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30, repeats: true) { [weak self] _ in
            guard let self, let p = self.player else { return }
            self.currentTime = p.currentTime

            p.updateMeters()
            let avg = p.averagePower(forChannel: 0)
            let peak = p.peakPower(forChannel: 0)
            let avgN = max(0, min(1, (avg + 50) / 50))
            let peakN = max(0, min(1, (peak + 50) / 50))
            let energy = avgN * 0.6 + peakN * 0.4

            let count = 24
            let t = Float(Date().timeIntervalSince1970)

            var bands = self.frequencyBands
            for i in 0..<count {
                let x = Float(i) / Float(count - 1)  // 0...1

                // 三层正弦波叠加 = 圆润波动
                let wave1 = sin(x * .pi) * energy                        // 半圆弧，中间高两边低
                let wave2 = sin(x * .pi * 2 + t * 3.0) * energy * 0.3   // 流动波纹
                let wave3 = sin(x * .pi * 3 + t * 1.7) * energy * 0.15  // 细节涟漪
                let wave4 = sin(t * 2.5 + Float(i) * 0.4) * energy * 0.1 // 微颤

                let raw = wave1 + wave2 + wave3 + wave4
                let shaped = pow(max(0, min(1, raw * 1.4)), 1.4)
                bands[i] = bands[i] * 0.25 + shaped * 0.75
            }
            self.frequencyBands = bands

            if !p.isPlaying && self.isPlaying {
                self.next()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
