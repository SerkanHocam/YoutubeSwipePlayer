//
//  MinimizeView.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 22.11.2022.
//

import UIKit

class MinimizeView: UIView, IMiniPlayerView {
    
    var player: SwipePlayer!
    @IBOutlet weak var txtCaption: UILabel!
    
    @IBOutlet weak var btnPlayPause:UIButton!
    
    func updateUI(status: PlayerStatus) {
        switch status {
        case .Playing:
            self.btnPlayPause.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            break
        case .Paused:
            self.btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
            break
        case .Stoped:
            self.btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
            break
        case .Finished:
            self.btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
            break
        default: break
        }
    }
    
    @IBAction func btnPlayPause_click(_ sender: Any) {
        self.player.toggle()
    }
    
    @IBAction func btnClose_click(_ sender: Any) {
        self.player.close()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let xCoord = self.player.minimizedFrame.origin.x + self.player.minimizedFrame.width + 8
        self.txtCaption.frame.origin = CGPoint(x: xCoord, y: 0)
        self.txtCaption.frame.size = CGSize(width: self.btnPlayPause.frame.origin.x, height: self.frame.height)
    }
    
}
