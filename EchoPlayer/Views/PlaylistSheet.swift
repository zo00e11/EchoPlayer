//
//  PlaylistSheet.swift
//  EchoPlayer
//

import SwiftUI

struct PlaylistSheet: View {
    let songs: [Song]
    let currentSong: Song?
    var onSelect: (Song) -> Void
    var onDelete: (Song) -> Void
    var onRescan: () -> Void
    var onOpenFolder: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Playlist")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.echoText)
                    .tracking(0.5)

                Text("\(songs.count)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.echoTextMuted)

                Spacer()

                Button(action: onOpenFolder) {
                    Image(systemName: "folder")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.echoTextMuted)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(.thinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(.plain)
                .help("Open playlist folder")

                Button(action: onRescan) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.echoTextMuted)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(.thinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(.plain)
                .help("Scan folder for new songs")

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.echoTextMuted)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(.thinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Color.black.opacity(0.08).frame(height: 0.5)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(songs.enumerated()), id: \.element.id) { idx, song in
                        HStack(spacing: 10) {
                            Button(action: { onSelect(song) }) {
                                HStack(spacing: 10) {
                                    if song == currentSong {
                                        Image(systemName: "waveform")
                                            .font(.system(size: 10))
                                            .foregroundColor(.echoPrimary)
                                            .frame(width: 16)
                                    } else {
                                        Text("\(idx + 1)")
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundColor(.echoTextMuted)
                                            .frame(width: 16)
                                    }

                                    Text(song.name)
                                        .font(.system(size: 12, weight: song == currentSong ? .semibold : .regular))
                                        .foregroundColor(song == currentSong ? .echoPrimary : .echoText)
                                        .lineLimit(1)

                                    Spacer()

                                    Text(song.ext)
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.echoTextMuted)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            Button(action: { onDelete(song) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.echoTextMuted.opacity(0.5))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            song == currentSong
                                ? Color.echoPrimary.opacity(0.15)
                                : Color.clear
                        )

                        if idx < songs.count - 1 {
                            Color.black.opacity(0.04)
                                .frame(height: 0.5)
                                .padding(.leading, 40)
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
        .frame(width: 300)
    }
}

#Preview {
    PlaylistSheet(
        songs: [
            Song(url: URL(fileURLWithPath: "/a.mp3"), name: "Song A", ext: "MP3"),
            Song(url: URL(fileURLWithPath: "/b.flac"), name: "Song B", ext: "FLAC"),
        ],
        currentSong: nil,
        onSelect: { _ in },
        onDelete: { _ in },
        onRescan: {},
        onOpenFolder: {},
        onClose: {}
    )
    .padding()
}
