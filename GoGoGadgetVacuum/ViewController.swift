//
//  ViewController.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 20/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

import MultipeerKit

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    @IBOutlet weak var vacuumButton: UIButton!
    @IBOutlet weak var lastCommandLabel: UILabel!

    lazy var vacuumImage = UIImage(named: "vacuum")!

    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.addObserver(self)
    }

    @IBAction func vacuumTapped(_ sender: Any) {
        viewModel.togglePlay()
    }

    @IBAction func sendItTapped(_ sender: Any) {
        viewModel.togglePlayRemote()
    }
}

extension ViewController: ViewModelObserver {
    func stateChanged(newState: ViewModel.ViewState) {
        switch newState.playerStatus {
        case .playing:
            vacuumButton.setImage(vacuumImage, for: .normal)
        case .paused:
            vacuumButton.setImage(vacuumImage.withRenderingMode(.alwaysTemplate), for: .normal)
        }

        lastCommandLabel.text = newState.sourceText
    }
}
