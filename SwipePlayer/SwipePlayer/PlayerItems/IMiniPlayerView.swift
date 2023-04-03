//
//  IMiniPlayerView.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 21.03.2023.
//

import UIKit

protocol IMiniPlayerView:UIView, OverlayProtocol {
    var player:SwipePlayer! { get set }
    func updateUI(status:PlayerStatus)
}

@objc
protocol MiniPlayerProtocol {
    @objc optional func startPlaying()
    @objc optional func finishPlaying()
    @objc optional func updateSeekbar(currentTime:Float64, totalTime:Float64)
}
