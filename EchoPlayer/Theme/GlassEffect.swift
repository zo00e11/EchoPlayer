//
//  GlassEffect.swift
//  EchoPlayer
//

import SwiftUI

// MARK: - Main card glassmorphism (light bg)

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.92).opacity(0.88))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
            )
            .shadow(color: .black.opacity(0.35), radius: 40, x: 0, y: 8)
            .shadow(color: .black.opacity(0.10), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Sub-component glass

struct GlassSurface: ViewModifier {
    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(red: 0.16, green: 0.14, blue: 0.12).opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
            )
    }
}

// MARK: - Hover glow

struct HoverGlow: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: isHovered ? Color.echoPrimary.opacity(0.20) : .clear,
                radius: isHovered ? 14 : 0
            )
            .animation(.easeOut(duration: 0.2), value: isHovered)
            .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - View extensions

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }

    func glassSurface(radius: CGFloat = 12) -> some View {
        modifier(GlassSurface(cornerRadius: radius))
    }

    func hoverGlow() -> some View {
        modifier(HoverGlow())
    }
}
