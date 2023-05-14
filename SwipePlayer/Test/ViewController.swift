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
        guard let url = URL(string: "https://d3rlna7iyyu8wu.cloudfront.net/skip_armstrong/skip_armstrong_stereo_subs.m3u8") else { return }
        self.player.start(videoUrl: url)
    }
    
}

