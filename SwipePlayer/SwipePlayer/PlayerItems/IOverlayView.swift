//
//  IOverlayView.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 21.03.2023.
//

import UIKit

protocol IOverlayView:UIView, OverlayProtocol {
    ///This property provide to reach by overlay's controls like play-pause or seeking
    var player:SwipePlayer! { get set }

    func showLoading()
    func hideLoading()
    func showOverlay()
    func hideOverlay()
    func updateUI(status:PlayerStatus)
    func getPlayerView() -> UIView
}

@objc
protocol OverlayProtocol {
    @objc optional func startPlaying()
    @objc optional func finishPlaying()
    @objc optional func swipeViewMinimized()
    @objc optional func swipeViewMaximized()
    @objc optional func updateSeekbar(currentTime:Float64, totalTime:Float64)
    @objc optional func orientationChange(current:UIInterfaceOrientationMask)
}
