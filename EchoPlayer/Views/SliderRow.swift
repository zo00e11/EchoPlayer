//
//  SliderRow.swift
//  EchoPlayer
//

import SwiftUI

struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let minValue: Double
    let maxValue: Double
    let format: (Double) -> String
    var resetValue: Double? = nil

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.echoTextMuted)
                .tracking(1.5)
                .frame(width: 56, alignment: .trailing)

            GeometryReader { geo in
                let pct = (value - minValue) / (maxValue - minValue)

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
                        .frame(width: max(4, geo.size.width * CGFloat(pct)), height: 4)

                    Circle()
                        .fill(Color.echoThumbBg)
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                        .offset(x: max(0, geo.size.width * CGFloat(pct) - 7))
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            let ratio = min(1, max(0, drag.location.x / geo.size.width))
                            let raw = minValue + ratio * (maxValue - minValue)
                            let stepped = round(raw / 0.05) * 0.05
                            value = min(maxValue, max(minValue, stepped))
                        }
                )
            }
            .frame(height: 18)

            Text(format(value))
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color.echoDark)
                )
                .onTapGesture(count: 2) {
                    if let reset = resetValue {
                        value = reset
                    }
                }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SliderRow(label: "SPEED", value: .constant(1.0), minValue: 0.5, maxValue: 2.0, format: {
            String(format: "%.2fx", $0)
        }, resetValue: 1.0)
        SliderRow(label: "VOLUME", value: .constant(60), minValue: 0, maxValue: 100, format: {
            "\(Int($0))%"
        })
    }
    .padding()
    .frame(width: 380)
}
