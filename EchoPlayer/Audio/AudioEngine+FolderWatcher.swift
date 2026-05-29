//
//  AudioEngine+FolderWatcher.swift
//  EchoPlayer
//

import Foundation
import AppKit
import Combine

extension AudioEngine {

    private static let bookmarkKey = "EchoPlayer_PlaylistFolderBookmark"

    var folderURL: URL {
        if let bookmarkData = UserDefaults.standard.data(forKey: Self.bookmarkKey) {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale) {
                return url
            }
        }
        return URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("Desktop")
            .appendingPathComponent("常用文件")
            .appendingPathComponent("playlist")
    }

    func selectPlaylistFolder() {
        let panel = NSOpenPanel()
        panel.title = "选择歌单文件夹"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            if let bookmarkData = try? url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil
            ) {
                UserDefaults.standard.set(bookmarkData, forKey: Self.bookmarkKey)
            }
            _ = url.startAccessingSecurityScopedResource()
            scanFolder()
        }
    }

    func scanFolder() {
        let url = folderURL
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else { return }
        guard let files = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: []
        ) else { return }

        let exts: Set<String> = ["mp3", "wav", "flac", "m4a", "aac", "ogg", "wma"]
        let folderSongs = files
            .filter { exts.contains($0.pathExtension.lowercased()) }
            .map { fileURL -> Song in
                Song(url: fileURL,
                     name: fileURL.deletingPathExtension().lastPathComponent,
                     ext: fileURL.pathExtension.uppercased())
            }

        playlist = folderSongs
        objectWillChange.send()
        savePlaylist()
    }

    func openPlaylistFolder() {
        NSWorkspace.shared.open(folderURL)
    }
}
