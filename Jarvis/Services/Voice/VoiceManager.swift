//
//  VoiceManager.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import AVFoundation
import AVFAudio

@MainActor
final class VoiceManager: ObservableObject, SpeechRecognizerServiceDelegate {
    enum State {
        case idle
        case listening
        case processing
        case speaking
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var transcript: String = ""
    @Published var presentationTarget: PresentationTarget?

    private let speechRecognizerService = SpeechRecognizerService()
    private let ttsService = TextToSpeechService()

    init() {
        speechRecognizerService.delegate = self
        ttsService.onFinishSpeaking = { [weak self] in
            self?.state = .idle
        }
    }

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { micGranted in
                guard micGranted else { completion(false); return }
                self.speechRecognizerService.requestAuthorization { speechGranted in
                    completion(speechGranted)
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
                guard micGranted else { completion(false); return }
                self.speechRecognizerService.requestAuthorization { speechGranted in
                    completion(speechGranted)
                }
            }
        }
    }

    func toggleListening() {
        switch state {
        case .idle, .speaking, .error:
            transcript = ""
            state = .listening
            speechRecognizerService.startRecording()
        case .listening:
            speechRecognizerService.stopRecording()
            state = .processing
            processTranscript()
        case .processing:
            break
        }
    }

    func speak(_ text: String) {
        state = .speaking
        ttsService.speak(text)
    }

    enum PresentationTarget {
        case camera
        case photoPicker
    }

    func requestPresentation(_ target: PresentationTarget) {
        presentationTarget = target
    }

    private func processTranscript() {
        AIService.process(utterance: transcript, context: [:]) { intent in
            JarvisShortcuts.processAIIntent(intent, manager: self)
        }
    }

    // MARK: - SpeechRecognizerServiceDelegate
    func speechRecognizerService(_ service: SpeechRecognizerService, didUpdateTranscript transcript: String) {
        self.transcript = transcript
    }

    func speechRecognizerService(_ service: SpeechRecognizerService, didFinishWithTranscript transcript: String) {
        self.transcript = transcript
        state = .processing
        processTranscript()
    }

    func speechRecognizerService(_ service: SpeechRecognizerService, didEncounterError error: Error) {
        state = .error(error.localizedDescription)
    }
}

extension VoiceManager {
    func summarize(intent: AIIntent) -> String {
        switch intent.type {
        case .createReminder:
            return "Creating a reminder\(intent.parameters["time"].map { " for \($0)" } ?? "")."
        case .createCalendarEvent:
            return "Scheduling a calendar event\(intent.parameters["time"].map { " at \($0)" } ?? "")."
        case .sendMessage:
            return "Preparing to send a message\(intent.parameters["name"].map { " to \($0)" } ?? "")."
        case .placeCall:
            return "Preparing to place a call\(intent.parameters["name"].map { " to \($0)" } ?? "")."
        case .playMusic:
            return "Playing music."
        case .openCamera:
            return "Opening the camera."
        case .showPhotos:
            return "Showing recent photos."
        case .getHealthSummary:
            return "Fetching your health summary."
        case .getLocation:
            return "Checking your current location."
        case .genericAnswer:
            return "Got it. Let me think about that."
        case .unknown:
            return "I didn't catch that. Could you rephrase?"
        }
    }
}


