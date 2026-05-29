//
//  EqualizerView.swift
//  EchoPlayer
//

import SwiftUI

struct EqualizerView: View {
    let bands: [Float]

    private let barCount = 24
    private let minBarHeight: CGFloat = 6
    private let maxBarHeight: CGFloat = 40

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(Color.orange)
                    .frame(width: 3)
                    .frame(height: barHeight(for: i))
            }
        }
        .animation(.easeInOut(duration: 0.12), value: bands.map { Int($0 * 10) })
        .frame(width: 200, height: 56)
        .clipped()
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.16, green: 0.14, blue: 0.12).opacity(0.9))
        )
    }

    private func barHeight(for index: Int) -> CGFloat {
        guard index < bands.count else { return minBarHeight }
        let value = CGFloat(bands[index])
        return minBarHeight + (maxBarHeight - minBarHeight) * max(0, min(1, value))
    }
}

#Preview {
    EqualizerView(bands: Array(repeating: 0.5, count: 24))
        .padding()
}
