//
//  ContentView.swift
//  Jarvis
//
//  Created by Chandramouli Vittal on 19/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var voiceManager = VoiceManager()
    @State private var permissionsGranted = false
    @State private var showCamera = false
    @State private var showPhotos = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Jarvis")
                .font(.largeTitle)
                .bold()

            Text(statusText)
                .font(.body)
                .foregroundStyle(.secondary)

            ScrollView {
                Text(voiceManager.transcript.isEmpty ? "Say something…" : voiceManager.transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxHeight: 240)
            .background(Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: handlePrimaryButton) {
                Label(buttonTitle, systemImage: buttonIcon)
                    .font(.title2)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!permissionsGranted && isIdle)
        }
        .padding()
        .onAppear {
            voiceManager.requestPermissions { authorized in
                permissionsGranted = authorized
            }
        }
        .onChange(of: voiceManager.presentationTarget) { _, target in
            guard let target else { return }
            switch target {
            case .camera:
                showCamera = true
            case .photoPicker:
                showPhotos = true
            }
            voiceManager.presentationTarget = nil
        }
        .sheet(isPresented: $showCamera) {
            ZStack {
                CameraPreviewView()
                    .ignoresSafeArea()
                VintageViewfinderFrame()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showPhotos) {
            ZStack {
                PhotoPickerView()
                VintageViewfinderFrame()
                    .allowsHitTesting(false)
                    .padding()
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}

private extension ContentView {
    var isIdle: Bool {
        if case .idle = voiceManager.state { return true }
        return false
    }

    var statusText: String {
        switch voiceManager.state {
        case .idle: return permissionsGranted ? "Idle" : "Awaiting microphone permission"
        case .listening: return "Listening…"
        case .processing: return "Processing…"
        case .speaking: return "Speaking…"
        case .error(let message): return "Error: \(message)"
        }
    }

    var buttonTitle: String {
        switch voiceManager.state {
        case .idle, .speaking, .error: return "Start Listening"
        case .listening: return "Stop"
        case .processing: return "Processing…"
        }
    }

    var buttonIcon: String {
        switch voiceManager.state {
        case .idle, .speaking, .error: return "mic.fill"
        case .listening: return "stop.fill"
        case .processing: return "hourglass"
        }
    }

    func handlePrimaryButton() {
        switch voiceManager.state {
        case .idle, .speaking, .error:
            voiceManager.toggleListening()
        case .listening:
            voiceManager.toggleListening()
        case .processing:
            break
        }
    }
}
