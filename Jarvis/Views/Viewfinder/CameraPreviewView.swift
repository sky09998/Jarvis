//
//  CameraPreviewView.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import SwiftUI
import AVFoundation

final class CameraSessionController {
    let session = AVCaptureSession()
    private var isConfigured = false
    private let sessionQueue = DispatchQueue(label: "camera.session.queue", qos: .userInitiated)

    func configureIfNeeded() {
        guard !isConfigured else { return }
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            defer { self.session.commitConfiguration(); self.isConfigured = true }

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else { return }
            self.session.addInput(input)
        }
    }

    func start() {
        sessionQueue.async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.setup()
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    final class PreviewUIView: UIView {
        private let controller = CameraSessionController()
        private var previewLayer: AVCaptureVideoPreviewLayer?

        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

        func setup() {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    guard granted else { return }
                    if let layer = self.layer as? AVCaptureVideoPreviewLayer {
                        self.previewLayer = layer
                        layer.session = self.controller.session
                        layer.videoGravity = .resizeAspectFill
                    }
                    self.controller.configureIfNeeded()
                    self.controller.start()
                }
            }
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if window == nil { controller.stop() }
        }
    }
}


