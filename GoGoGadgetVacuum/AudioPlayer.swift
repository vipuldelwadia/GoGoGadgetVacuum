//
//  AudioPlayer.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 20/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

import AVKit
import MediaPlayer

enum Command: String {
    case play
    case pause

    static let StorageKey = "nz.ac.r.gogogadgetvacuum.command"
}

class AudioPlayer {
    static let shared = AudioPlayer()
    private var player: AVAudioPlayer?

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
        guard let path = Bundle.main.path(forResource: "dyson", ofType: "wav") else { return nil }

        let url = URL(fileURLWithPath: path)
        let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        return audioPlayer
    }

    func playVacuum() -> Bool {
        guard let vacuum = player ?? loadVacuum() else { return false }
        player = vacuum


        if vacuum.isPlaying {
            vacuum.pause()
        }
        else {
            vacuum.play()
        }

        return vacuum.isPlaying
    }

    func handleCommand(_ command: Command) {
        switch command {
        case .play:
            play()
        case .pause:
            pause()
        }
    }

    @discardableResult
    private func play() -> Bool {
        guard let player = player, !player.isPlaying else { return false }
        player.play()
        return true
    }

    @discardableResult
    private func pause() -> Bool {
        guard let player = player, player.isPlaying else { return false }
        player.pause()
        return true
    }

    // MARK: MediaPlayer
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] event in
            if self?.play() ?? false {
                return .success
            }
            else {
                return .commandFailed
            }
        }

        commandCenter.pauseCommand.addTarget { [weak self] event in
            if self?.pause() ?? false {
                return .success
            }
            else {
                return .commandFailed
            }
        }
    }

    private func setupNowPlaying() {
        var info = [String: Any]()

        info[MPMediaItemPropertyTitle] = "Go Go Gadget Vacuum"

        if #available(iOS 10.0, *) {
            let image = #imageLiteral(resourceName: "vacuum-cleaner.pdf")
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
