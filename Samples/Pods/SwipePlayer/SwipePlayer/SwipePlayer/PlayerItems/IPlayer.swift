//
//  IPlayer.swift
//  SwipePlayer
//
//  Created by Serkan Kayaduman on 8.05.2023.
//

import AVKit

protocol IPlayer : UIView {
    func currentSecond() -> Float64
    func totalSecond() -> Float64
    
    func seekToTime(time:Float64, seekingFinish: (()->Void)?)
    
    func start(videoUrl: URL, fromTime:Int64)
    
    func play()
    func pause()
    func stop()
    
    var statusEvent: ((PlayerStatus) -> Void)? { get set }
    var timeEvent: ((Float64, Float64) -> Void)? { get set }
    var isPlaying : Bool { get set }
    
}
