//
//  ContentView.swift
//  EchoPlayer
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

struct ContentView: View {
    @StateObject private var audio = AudioEngine()
    @State private var isTargeted = false
    @State private var showPlaylist = false

    @State private var speed: Double = 1.0
    @State private var volume: Double = 50
    @State private var repeatMode: Int = 0
    @State private var balance: Double = 0

    private var playing: Bool { audio.isPlaying }

    @State private var powerSoundPlayer: AVAudioPlayer?

    private func playPowerSound() {
        guard let url = Bundle.main.url(forResource: "Morse", withExtension: "aiff") else { return }
        powerSoundPlayer = try? AVAudioPlayer(contentsOf: url)
        powerSoundPlayer?.play()
    }

    var body: some View {
        ZStack {
            // Warm off-white background
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.94, blue: 0.92),
                    Color(red: 0.94, green: 0.93, blue: 0.91),
                    Color(red: 0.95, green: 0.93, blue: 0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                TitleBar(audio: audio)
                    .padding(.top, 22)
                    .padding(.horizontal, 28)

                Color.echoDivider.frame(height: 0.5)
                    .padding(.top, 14).padding(.horizontal, 20)

                // Spectrum + Power
                HStack {
                    EqualizerView(bands: audio.frequencyBands)

                    Spacer()

                    VStack(spacing: 8) {
                        Circle()
                            .fill(playing ? Color.echoPrimary : Color.black.opacity(0.12))
                            .frame(width: 6, height: 6)
                            .shadow(color: playing ? .echoGlow : .clear, radius: 8)

                        Button(action: { audio.toggle(); playPowerSound() }) {
                            ZStack(alignment: .top) {
                                Capsule()
                                    .fill(playing ? Color.echoDark.opacity(0.85) : Color.white.opacity(0.5))
                                    .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 0.6))
                                    .frame(width: 24, height: 44)

                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: playing
                                                ? [Color.echoPrimary, Color.echoPrimaryLight]
                                                : [Color.echoDark, Color.echoDark.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 18, height: 18)
                                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                                    .padding(.top, 3)
                            }
                        }
                        .buttonStyle(.plain)

                        Text(playing ? "ON" : "OFF")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 32)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.echoDark)
                            )
                            .tracking(0.5)
                    }
                }
                .padding(.top, 20).padding(.horizontal, 28)

                Color.echoDivider.frame(height: 0.5)
                    .padding(.top, 20).padding(.horizontal, 20)

                // Sliders
                VStack(spacing: 16) {
                    SliderRow(label: "SPEED", value: $speed, minValue: 0.0, maxValue: 2.0, format: {
                        String(format: "%.2fx", $0)
                    }, resetValue: 1.0)
                    SliderRow(label: "VOLUME", value: $volume, minValue: 0, maxValue: 100) {
                        "\(Int($0))%"
                    }
                    SliderRow(label: "BALANCE", value: $balance, minValue: -1, maxValue: 1, format: {
                        let v = $0
                        if abs(v) < 0.05 { return "C" }
                        if v < 0 { return "L\(Int(abs(v) * 100))%" }
                        return "R\(Int(v * 100))%"
                    }, resetValue: 0)
                }
                .padding(.top, 18).padding(.horizontal, 28)

                Color.echoDivider.frame(height: 0.5)
                    .padding(.top, 18).padding(.horizontal, 20)

                // Song name
                Text(audio.songName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.echoText)
                    .lineLimit(1)
                    .padding(.top, 16)

                // Progress bar
                ProgressBar(
                    currentTime: $audio.currentTime,
                    duration: audio.duration,
                    onSeek: { audio.seek(to: $0) }
                )
                .padding(.top, 6).padding(.horizontal, 28)

                // Playback controls
                HStack {
                    Button(action: { audio.previous() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 16))
                            .foregroundColor(audio.currentSong != nil ? .echoText : .echoTextMuted)
                    }
                    .buttonStyle(.plain)
                    .disabled(audio.currentSong == nil)
                    .frame(width: 44, alignment: .leading)

                    Spacer()

                    Button(action: { audio.toggle() }) {
                        ZStack {
                            Circle()
                                .fill(.thinMaterial)
                                .overlay(Circle().fill(Color.black.opacity(0.04)))
                                .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 0.8))
                                .frame(width: 40, height: 40)

                            Image(systemName: playing ? "pause.fill" : "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.echoText)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: { audio.next() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16))
                            .foregroundColor(audio.currentSong != nil ? .echoText : .echoTextMuted)
                    }
                    .buttonStyle(.plain)
                    .disabled(audio.currentSong == nil)
                    .frame(width: 44, alignment: .trailing)
                }
                .padding(.horizontal, 28)
                .padding(.top, 12)

                // Repeat + Playlist
                HStack {
                    Button(action: {
                        repeatMode = (repeatMode + 1) % 3
                        audio.repeatMode = repeatMode
                    }) {
                        Image(systemName: ["repeat", "repeat.1", "repeat"][repeatMode])
                            .font(.system(size: 11))
                            .foregroundColor(repeatMode > 0 ? .echoPrimary : .echoTextMuted)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 44, alignment: .leading)

                    Spacer()

                    Button(action: { showPlaylist.toggle() }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 11))
                            .foregroundColor(showPlaylist ? .echoPrimary : .echoTextMuted)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 44, alignment: .trailing)
                }
                .padding(.horizontal, 28)
                .padding(.top, 6).padding(.bottom, 20)
            }

            if showPlaylist {
                let selectSong: (Song) -> Void = { song in
                    audio.playSong(song)
                    showPlaylist = false
                }
                let deleteSong: (Song) -> Void = { song in
                    audio.removeSong(song)
                }
                VStack {
                    Spacer()
                    PlaylistSheet(
                        songs: audio.playlist,
                        currentSong: audio.currentSong,
                        onSelect: selectSong,
                        onDelete: deleteSong,
                        onRescan: { audio.scanFolder() },
                        onOpenFolder: { audio.selectPlaylistFolder() },
                        onClose: { showPlaylist = false }
                    )
                    .padding(.bottom, 50)
                }
                .transition(.opacity)
                .hoverGlow()
            }
        }
        .glassCard()
        .frame(width: 380)
        .focusable()
        .onKeyPress { press in
            switch press.key {
            case .space:
                audio.toggle()
                return .handled
            case .leftArrow:
                audio.seek(to: max(0, audio.currentTime - 10))
                return .handled
            case .rightArrow:
                audio.seek(to: min(audio.duration, audio.currentTime + 10))
                return .handled
            case .upArrow:
                volume = min(100, volume + 10)
                return .handled
            case .downArrow:
                volume = max(0, volume - 10)
                return .handled
            default:
                return .ignored
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url { DispatchQueue.main.async { audio.addFile(url: url) } }
            }
            return true
        }
        .onChange(of: speed) { _, v in audio.setSpeed(Float(v)) }
        .onChange(of: volume) { _, v in audio.setVolume(Float(v) / 100.0) }
        .onChange(of: balance) { _, v in audio.setPan(Float(v)) }
        .onAppear {
            audio.scanFolder()
        }
    }
}

#Preview {
    ContentView()
}
