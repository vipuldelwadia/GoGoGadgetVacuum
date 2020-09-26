//
//  Store.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 21/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

enum CommandSource: Equatable {
    case localApp
    case localSystem
    case remoteApp(sender: String)
}

class Store {
    static let shared = Store()

    private var model = Model(audioStatus: .paused, commandSource: .localApp) {
        didSet {
            notifyObservers(of: model)
        }
    }

    private var observations = [ObjectIdentifier : Observation]()

    func setAudioStatus(_ newAudioStatus: AudioStatus, commandSource: CommandSource) {
        let newModel = Model(audioStatus: newAudioStatus, commandSource: commandSource)
        if newModel != model {
            model = newModel
        }
    }
}

struct Model: Equatable {
    var audioStatus: AudioStatus
    var commandSource: CommandSource
}

// MARK: Observer
protocol StoreObserver: class {
    func modelUpdated(newModel: Model)
}

extension Store {
    func addObserver(_ observer: StoreObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
        observer.modelUpdated(newModel: model)
    }

    func removeObserver(_ observer: StoreObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }

    private func notifyObservers(of newModel: Model) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                // observer gone, let's ditch our ref
                observations.removeValue(forKey: id)
                continue
            }
            
            observer.modelUpdated(newModel: newModel)
        }
    }
}

private extension Store {
    struct Observation {
        weak var observer: StoreObserver?
    }
}
