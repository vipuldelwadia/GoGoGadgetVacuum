//
//  ViewController.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 20/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    @IBOutlet private weak var volumeContainer: UIView!
    @IBOutlet weak var vacuumButton: UIButton!
    private var volumeView: MPVolumeView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        volumeView = MPVolumeView(frame: volumeContainer.bounds)
        volumeContainer.addSubview(volumeView)

//        vacuumButton.setImage(#imageLiteral(resourceName: "vacuum-cleaner.pdf").withRenderingMode(.alwaysTemplate), for: .normal)
    }

    @IBAction func vacuumTapped(_ sender: Any) {
        let command: Command = Store.shared.lastCommand == .play ? .pause : .play
        Store.shared.setCommand(command)
//        let isPlaying = AudioPlayer.shared.playVacuum()
//        let image = isPlaying ? #imageLiteral(resourceName: "vacuum-cleaner.pdf") : #imageLiteral(resourceName: "vacuum-cleaner.pdf").withRenderingMode(.alwaysTemplate)
//        vacuumButton.setImage(image, for: .normal)
    }
}
