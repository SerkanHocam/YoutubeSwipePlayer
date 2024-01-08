//
//  ViewController.swift
//  Samples
//
//  Created by Serkan Kayaduman on 15.05.2023.
//

import UIKit
import SwipePlayer

class ViewController: UIViewController {
    var player : SwipePlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func btnDefaultSettings(_ sender: Any) {
        if let oldPlayer = self.player {
            oldPlayer.close()
        }
        let player = SwipePlayer(viewController: self)
        player.detailView = DetailView()
        guard let url = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8") else { return }
        player.start(videoUrl: url)
        
        player.play()
        
        self.player = player
    }
    
    @IBAction func btnDiffrentOverlay(_ sender: Any) {
        if let oldPlayer = self.player {
            oldPlayer.close()
        }
        
        guard let newOverlay = Bundle.main.loadNibNamed("NewOverlay", owner: nil)?[0] as? NewOverlay else { return }
        
        let player = SwipePlayer(viewController: self)
        player.overlay = newOverlay
        player.detailView = DetailView()
        
        guard let url = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8") else { return }
        player.start(videoUrl: url)
        
        self.player = player
    }
    
    @IBAction func btnTopHeader(_ sender: Any) {
        if let oldPlayer = self.player {
            oldPlayer.close()
        }
        guard let newOverlay = Bundle.main.loadNibNamed("NewOverlay", owner: nil)?[0] as? NewOverlay else { return }
        guard let header = Bundle.main.loadNibNamed("HeaderView", owner: nil)?[0] as? HeaderView else { return }
        let detail = DetailView()
        
        let player = SwipePlayer(viewController: self)
        player.overlay = newOverlay
        player.headerView = header
        player.detailView = detail
        
        player.backgroundColor = header.backgroundColor
        detail.backgroundColor = .clear
        
        guard let url = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8") else { return }
        player.start(videoUrl: url)
        
        self.player = player
    }
    
    @IBAction func btnSolid(_ sender: Any) {
        if let oldPlayer = self.player {
            oldPlayer.close()
        }
        let minimizedFrame : CGRect = {
            let width = UIScreen.main.bounds.width / 2.5
            let height = width * 0.6
            return CGRect(x: UIScreen.main.bounds.width - (width + 10), y: UIScreen.main.bounds.height - height - 80, width: width, height: height)
        }()
        
        let player = SwipePlayer(viewController: self, minimizedPlayerFrame: minimizedFrame)
        
        player.detailView = DetailView()
        player.miniPlayerView = nil
        
        
        guard let url = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8") else { return }
        player.start(videoUrl: url)
        
        self.player = player
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
