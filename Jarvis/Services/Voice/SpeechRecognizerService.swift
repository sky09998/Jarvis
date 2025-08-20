//
//  SpeechRecognizerService.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import AVFoundation
import Speech

protocol SpeechRecognizerServiceDelegate: AnyObject {
    func speechRecognizerService(_ service: SpeechRecognizerService, didUpdateTranscript transcript: String)
    func speechRecognizerService(_ service: SpeechRecognizerService, didFinishWithTranscript transcript: String)
    func speechRecognizerService(_ service: SpeechRecognizerService, didEncounterError error: Error)
}

final class SpeechRecognizerService: NSObject {
    weak var delegate: SpeechRecognizerServiceDelegate?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: Locale.preferredLanguages.first ?? "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    func startRecording() {
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            delegate?.speechRecognizerService(self, didEncounterError: error)
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            delegate?.speechRecognizerService(self, didEncounterError: error)
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }
            if let result = result {
                let transcript = result.bestTranscription.formattedString
                self.delegate?.speechRecognizerService(self, didUpdateTranscript: transcript)
                if result.isFinal {
                    self.stopRecording()
                    self.delegate?.speechRecognizerService(self, didFinishWithTranscript: transcript)
                }
            }

            if let error = error {
                self.stopRecording()
                self.delegate?.speechRecognizerService(self, didEncounterError: error)
            }
        }
    }

    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // ignore
        }
    }
}


