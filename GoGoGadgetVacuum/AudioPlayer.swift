//
//  AudioPlayer.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 20/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

import AVKit
import MediaPlayer

enum AudioStatus {
    case playing
    case paused
}

class AudioPlayer {
    static let shared = AudioPlayer()
    private var player: AVAudioPlayer?

    private var currentStatus: AudioStatus {
        if player?.isPlaying ?? false {
            return .playing
        }
        else {
            return .paused
        }
    }

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        }
        catch {
            print("failed to set audio session category to playback")
        }

        player = loadVacuum()
        setupRemoteTransportControls()
        setupNowPlaying()
    }

    private func loadVacuum() -> AVAudioPlayer? {
        guard let path = Bundle.main.path(forResource: "vacuum", ofType: "wav") else { return nil }

        let url = URL(fileURLWithPath: path)
        let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.numberOfLoops = -1
        return audioPlayer
    }

    @discardableResult
    private func play() -> Bool {
        guard let player = player, !player.isPlaying else { return false }

        return player.play()
    }

    private func pause() {
        guard let player = player, player.isPlaying else { return }

        player.pause()
    }

    @discardableResult
    func playPause() -> AudioStatus {
        guard let player = player else { return .paused }

        if player.isPlaying {
            pause()
            return .paused
        }
        else {
            return play() ? .playing : .paused
        }
    }

    // MARK: MediaPlayer
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }

            if self.play() {
                Store.shared.setAudioStatus(self.currentStatus, commandSource: .localSystem)
                return .success
            }
            else {
                Store.shared.setAudioStatus(self.currentStatus, commandSource: .localSystem)
                return .commandFailed
            }
        }

        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }

            self.pause()
            Store.shared.setAudioStatus(self.currentStatus, commandSource: .localSystem)
            return .success
        }
    }

    private func setupNowPlaying() {
        var info = [String: Any]()

        info[MPMediaItemPropertyTitle] = "Go Go Gadget Vacuum"

        if #available(iOS 10.0, *), let image = UIImage(named: "vacuum") {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
