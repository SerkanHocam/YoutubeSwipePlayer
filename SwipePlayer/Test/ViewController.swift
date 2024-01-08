//
//  ViewController.swift
//  Test
//
//  Created by Serkan Kayaduman on 16.04.2023.
//

import UIKit
import SwipePlayer

class ViewController: UIViewController {

    private var player : SwipePlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = SwipePlayer(viewController: self)
        // Do any additional setup after loading the view.
    }

    @IBAction func startPlayer(_ sender: Any) {
        guard let url = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8") else { return }
        self.player.start(videoUrl: url)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

