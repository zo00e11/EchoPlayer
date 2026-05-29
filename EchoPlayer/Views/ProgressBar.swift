//
//  ProgressBar.swift
//  EchoPlayer
//

import SwiftUI

struct ProgressBar: View {
    @Binding var currentTime: Double
    let duration: Double
    var onSeek: (Double) -> Void

    @State private var isDragging = false
    @State private var dragValue: Double = 0

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let progress = duration > 0 ? (isDragging ? dragValue : currentTime) / duration : 0

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.echoPrimary.opacity(0.5),
                                    Color.echoPrimary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, geo.size.width * CGFloat(progress)), height: 4)

                    Circle()
                        .fill(Color.white)
                        .frame(width: isDragging ? 12 : 8, height: isDragging ? 12 : 8)
                        .shadow(color: .black.opacity(0.15), radius: isDragging ? 4 : 2)
                        .offset(x: max(0, geo.size.width * CGFloat(progress) - (isDragging ? 6 : 4)))
                        .animation(.easeOut(duration: 0.1), value: isDragging)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let ratio = min(1, max(0, value.location.x / geo.size.width))
                            dragValue = ratio * duration
                            onSeek(dragValue)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            }
            .frame(height: 24)

            HStack {
                Text(formatTime(isDragging ? dragValue : currentTime))
                Spacer()
                Text(formatTime(duration))
            }
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundColor(.echoTextMuted)
        }
    }

    private func formatTime(_ s: Double) -> String {
        guard s.isFinite, s >= 0 else { return "0:00" }
        let m = Int(s) / 60
        let sec = Int(s) % 60
        return "\(m):\(String(format: "%02d", sec))"
    }
}

#Preview {
    ProgressBar(currentTime: .constant(65), duration: 240, onSeek: { _ in })
        .padding()
        .frame(width: 340)
}
