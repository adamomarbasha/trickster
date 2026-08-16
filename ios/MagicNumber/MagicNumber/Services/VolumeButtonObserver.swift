import AVFoundation
import MediaPlayer
import SwiftUI
import UIKit

@MainActor
final class VolumeButtonObserver: ObservableObject {
    private let audioSession = AVAudioSession.sharedInstance()
    private var volumeObservation: NSKeyValueObservation?
    private var hiddenVolumeView: MPVolumeView?
    private weak var volumeSlider: UISlider?
    private var lastVolume: Float = AVAudioSession.sharedInstance().outputVolume
    private var lastHandledAt = Date.distantPast
    private var isRecentering = false
    private var onIncrease: (() -> Void)?
    private var onDecrease: (() -> Void)?

    private let midpoint: Float = 0.5
    private let debounceInterval: TimeInterval = 0.16
    private let minimumDelta: Float = 0.005

    func start(onIncrease: @escaping () -> Void, onDecrease: @escaping () -> Void) {
        self.onIncrease = onIncrease
        self.onDecrease = onDecrease

        do {
            try audioSession.setCategory(.ambient, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Unable to activate audio session: \(error.localizedDescription)")
        }

        installHiddenVolumeViewIfNeeded()
        lastVolume = audioSession.outputVolume
        observeSystemVolume()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            recenterSystemVolume()
        }
    }

    func stop() {
        volumeObservation?.invalidate()
        volumeObservation = nil
        hiddenVolumeView?.removeFromSuperview()
        hiddenVolumeView = nil
        volumeSlider = nil
        onIncrease = nil
        onDecrease = nil
    }

    private func observeSystemVolume() {
        volumeObservation?.invalidate()
        volumeObservation = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] _, change in
            Task { @MainActor in
                self?.handleVolumeChange(change.newValue)
            }
        }
    }

    private func handleVolumeChange(_ newVolume: Float?) {
        guard let newVolume else { return }

        if isRecentering {
            lastVolume = newVolume
            return
        }

        let delta = newVolume - lastVolume
        lastVolume = newVolume

        guard abs(delta) >= minimumDelta else { return }
        guard Date().timeIntervalSince(lastHandledAt) >= debounceInterval else { return }

        lastHandledAt = Date()

        if delta > 0 {
            onIncrease?()
        } else {
            onDecrease?()
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 90_000_000)
            recenterSystemVolume()
        }
    }

    private func installHiddenVolumeViewIfNeeded() {
        guard hiddenVolumeView == nil else { return }

        func attemptInstall() {
            let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
            volumeView.alpha = 0.01
            volumeView.showsRouteButton = false

            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap(\.windows)
                .first(where: \.isKeyWindow) else {
                // Retry shortly if no key window yet
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    attemptInstall()
                }
                return
            }

            window.addSubview(volumeView)
            hiddenVolumeView = volumeView
            volumeSlider = volumeView.subviews.compactMap { $0 as? UISlider }.first
        }

        attemptInstall()
    }

    private func recenterSystemVolume() {
        guard let volumeSlider else { return }

        isRecentering = true
        volumeSlider.setValue(midpoint, animated: false)
        volumeSlider.sendActions(for: .touchUpInside)
        lastVolume = midpoint

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 240_000_000)
            isRecentering = false
        }
    }
}
