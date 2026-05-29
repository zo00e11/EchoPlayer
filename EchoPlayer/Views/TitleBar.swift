//
//  TitleBar.swift
//  EchoPlayer
//

import SwiftUI

struct TitleBar: View {
    @ObservedObject var audio: AudioEngine

    var body: some View {
        HStack(spacing: 10) {
            Text("::")
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(.echoText)
                .tracking(1)

            Text("ECHOPLAYER")
                .font(.system(size: 13, weight: .bold, design: .default))
                .foregroundColor(.echoText)
                .tracking(2)

            Spacer()

            // 4 animated bars
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(audio.isPlaying ? Color.echoPrimary : Color.echoTextMuted.opacity(0.3))
                        .frame(width: 4)
                        .frame(height: barHeight(for: i))
                }
            }
            .animation(.easeInOut(duration: 0.12), value: audio.frequencyBands.map { Int($0 * 10) })
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let bandIndex = index * 6
        guard bandIndex < audio.frequencyBands.count else { return 4 }
        let value = CGFloat(audio.frequencyBands[bandIndex])
        return 4 + 12 * max(0, min(1, value))
    }
}

#Preview {
    TitleBar(audio: AudioEngine())
        .padding()
        .frame(width: 380)
}
