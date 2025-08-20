//
//  VintageViewfinderFrame.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import SwiftUI

struct VintageViewfinderFrame: View {
    var body: some View {
        ZStack {
            // Subtle vignette
            RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.35), Color.black.opacity(0.8)]), center: .center, startRadius: 10, endRadius: 320)
                .blendMode(.multiply)

            // Corner brackets
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let len: CGFloat = min(w, h) * 0.12

                Path { p in
                    // TL
                    p.move(to: CGPoint(x: 20, y: 20 + len))
                    p.addLine(to: CGPoint(x: 20, y: 20))
                    p.addLine(to: CGPoint(x: 20 + len, y: 20))
                    // TR
                    p.move(to: CGPoint(x: w - 20 - len, y: 20))
                    p.addLine(to: CGPoint(x: w - 20, y: 20))
                    p.addLine(to: CGPoint(x: w - 20, y: 20 + len))
                    // BL
                    p.move(to: CGPoint(x: 20, y: h - 20 - len))
                    p.addLine(to: CGPoint(x: 20, y: h - 20))
                    p.addLine(to: CGPoint(x: 20 + len, y: h - 20))
                    // BR
                    p.move(to: CGPoint(x: w - 20 - len, y: h - 20))
                    p.addLine(to: CGPoint(x: w - 20, y: h - 20))
                    p.addLine(to: CGPoint(x: w - 20, y: h - 20 - len))
                }
                .stroke(Color.green.opacity(0.8), lineWidth: 2)
            }

            // Retro labels
            VStack {
                HStack {
                    Text("ISO 400").font(.caption2).foregroundStyle(.green.opacity(0.8))
                    Spacer()
                    Text(Date(), style: .time).font(.caption2).foregroundStyle(.green.opacity(0.8))
                }
                .padding([.top, .horizontal], 8)
                Spacer()
                HStack {
                    Circle().fill(Color.red.opacity(0.8)).frame(width: 8, height: 8)
                    Text("REC").font(.caption2).foregroundStyle(.red.opacity(0.8))
                    Spacer()
                    Text("F2.8 1/60").font(.caption2).foregroundStyle(.green.opacity(0.8))
                }
                .padding([.bottom, .horizontal], 8)
            }
        }
        .compositingGroup()
    }
}


