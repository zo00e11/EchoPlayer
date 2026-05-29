//
//  Colors.swift
//  EchoPlayer
//

import SwiftUI

extension Color {
    // Accent (retro warm orange)
    static let echoPrimary = Color(red: 0.91, green: 0.44, blue: 0.19)       // #E87030
    static let echoPrimaryLight = Color(red: 0.94, green: 0.63, blue: 0.31)  // #F0A050
    static let echoGlow = Color(red: 0.91, green: 0.44, blue: 0.19).opacity(0.4)

    // Dark text on light glass
    static let echoText = Color(red: 0.16, green: 0.15, blue: 0.14)          // #2A2623
    static let echoTextMuted = Color(red: 0.40, green: 0.38, blue: 0.35)     // #666159

    // Dark elements
    static let echoDark = Color(red: 0.23, green: 0.21, blue: 0.19)          // #3A3530
    static let echoWindow = Color(red: 0.16, green: 0.14, blue: 0.12, opacity: 0.9) // EQ dark

    // Track / thumb
    static let echoTrackBg = Color.black.opacity(0.08)
    static let echoThumbBg = Color(red: 0.94, green: 0.93, blue: 0.91)       // #F0ECEB

    // Divider
    static let echoDivider = Color.black.opacity(0.10)

    // Background
    static let echoBg = Color(red: 0.10, green: 0.10, blue: 0.10)            // #1A1A1A
}
