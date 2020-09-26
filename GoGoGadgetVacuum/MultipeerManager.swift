//
//  MultipeerManager.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 26/09/20.
//  Copyright © 2020 Vipul Delwadia. All rights reserved.
//

import MultipeerKit

class MultipeerManager {
    static let shared = MultipeerManager()

    let transceiver: MultipeerTransceiver

    init() {
        var config = MultipeerConfiguration.default
        config.serviceType = "gadgetvacuum"
        transceiver = MultipeerTransceiver(configuration: config)
    }

    func resume() {
        transceiver.resume()
    }
}

enum RemoteCommand: String, Codable {
    case toggle
}
