//
//  FullScreenVC.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 13.03.2023.
//

import UIKit

class FullScreenVC: UINavigationController {

    var playerView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let windowScene = self.window?.windowScene else { return }
//        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
//            print(error.localizedDescription)
//        }
        self.navigationBar.isHidden = true
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = UIColor.black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let player = self.playerView {
            self.view.addSubview(player)
            player.frame = self.view.bounds
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}
