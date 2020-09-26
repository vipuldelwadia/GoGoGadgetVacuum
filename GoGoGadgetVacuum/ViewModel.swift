//
//  ViewModel.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 26/09/20.
//  Copyright © 2020 Vipul Delwadia. All rights reserved.
//

class ViewModel {
    struct ViewState {
        var playerStatus: PlayerStatus
        var sourceText: String?

        enum PlayerStatus {
            case playing
            case paused
        }
    }

    private var observations = [ObjectIdentifier : Observation]()
    private var currentViewState: ViewState? {
        didSet {
            if let newViewState = currentViewState {
                notifyObservers(of: newViewState)
            }
        }
    }

    init() {
        Store.shared.addObserver(self) 

        MultipeerManager.shared.transceiver.receive(RemoteCommand.self, using: { payload, peer in
            if payload == .toggle {
                self.togglePlay(commandSource: .remoteApp(sender: peer.name))
            }
        })
    }

    func mapViewState(model: Model) -> ViewState {
        let newViewState: ViewState
        switch model.audioStatus {
        case .playing:
            newViewState = .init(playerStatus: .playing,
                                 sourceText: "Audio started \(model.commandSource.asText)")
        case .paused:
            newViewState = .init(playerStatus: .paused,
                                 sourceText: "Audio paused \(model.commandSource.asText)")
        }
        return newViewState
    }

    func togglePlay(commandSource: CommandSource = .localApp) {
        let newAudioStatus = AudioPlayer.shared.playPause()
        Store.shared.setAudioStatus(newAudioStatus, commandSource: commandSource)
    }

    func togglePlayRemote() {
        MultipeerManager.shared.transceiver.broadcast(RemoteCommand.toggle)
    }
}

fileprivate extension CommandSource {
    var asText: String {
        switch self {
        case .localApp, .localSystem:
            return ""
        case .remoteApp(let sender):
            return "by \(sender)"
        }
    }
}

// MARK: StoreObserver
extension ViewModel: StoreObserver {
    func modelUpdated(newModel: Model) {
        currentViewState = mapViewState(model: newModel)
    }
}

// MARK: Observer
extension ViewModel {
    func addObserver(_ observer: ViewModelObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)

        if let viewState = currentViewState {
            observer.stateChanged(newState: viewState)
        }
    }

    func removeObserver(_ observer: ViewModelObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

private extension ViewModel {
    struct Observation {
        weak var observer: ViewModelObserver?
    }

    func notifyObservers(of newViewState: ViewState) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                // observer gone, let's ditch our ref
                observations.removeValue(forKey: id)
                continue
            }

            observer.stateChanged(newState: newViewState)
        }
    }
}

protocol ViewModelObserver: class {
    func stateChanged(newState: ViewModel.ViewState)
}
