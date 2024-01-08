//
//  Player.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 24.11.2022.

import UIKit
import MediaPlayer

class PlayerCore : UIView, IPlayer, AVPlayerItemOutputPushDelegate {
    
    var isPlaying = false
    
    private var player : AVPlayer!
    private var playerLayer : AVPlayerLayer!
    private var isFinishContent = false
    
    var preferedPeakBitRate : Double = 0 {
        didSet {
            if let playerItem = self.player.currentItem {
                playerItem.preferredPeakBitRate = self.preferedPeakBitRate
            }
        }
    }
    
    var statusEvent: ((PlayerStatus) -> Void)?
    var timeEvent: ((Float64, Float64) -> Void)?
    
    init() {
        super.init(frame: CGRect.zero)
        self.createPlayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createPlayer()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createPlayer() {
        self.backgroundColor = .black
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: self.player)
        
        self.playerLayer.videoGravity = .resizeAspect
//        self.playerLayer.backgroundColor = UIColor.black.cgColor
        self.layer.insertSublayer(self.playerLayer, at: 0)
        
//        self.layer.needsDisplayOnBoundsChange = true
//        self.playerLayer.needsDisplayOnBoundsChange = true
        
        self.addObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame.size = self.bounds.size
    }
    
    func start(videoUrl: URL, fromTime:Int64 = 0) {
        self.stop()
        
        let playerItem = AVPlayerItem(url: videoUrl)
        playerItem.preferredPeakBitRate = self.preferedPeakBitRate
        self.player.addObserver(self, forKeyPath: "currentItem.status", options: [.initial, .new], context: nil)
        
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferFull", context: nil)
        
        self.player.replaceCurrentItem(with: playerItem)
        
        if fromTime > 0 {
            self.player.seek(to: CMTimeMake(value: fromTime, timescale: Int32(1)))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func stop() {
        if let playerItem = self.player.currentItem {
            self.player.pause()
            self.isPlaying = false
            self.player.removeObserver(self, forKeyPath: "currentItem.status", context: nil)
            
            playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
            playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
            playerItem.removeObserver(self, forKeyPath: "playbackBufferFull", context: nil)
            
            NotificationCenter.default.removeObserver(self,
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            self.player.replaceCurrentItem(with: nil)
            self.statusEvent?(.Stoped)
        }
    }
    
    func play() {
        self.isPlaying = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        if self.isFinishContent {
            self.isFinishContent = false
            self.seekToTime(time: 0)
        } else {
            if self.totalSecond() == 0 { // live
                if let livePosition = self.player.currentItem?.seekableTimeRanges.last as? CMTimeRange {
                    self.player.seek(to:CMTimeRangeGetEnd(livePosition)) { isFinish in
                        self.player.play()
                        self.statusEvent?(.Playing)
                    }
                }
            } else { // vod
                self.player.play()
                self.statusEvent?(.Playing)
            }
        }
    }
    
    func pause() {
        self.isPlaying = false
        UIApplication.shared.isIdleTimerDisabled = false
        self.player.pause()
        self.statusEvent?(.Paused)
    }
    
    private var timeObserver : Any?
    
    private func addObserver() {
        self.timeObserver =  self.player.addPeriodicTimeObserver (
            forInterval: CMTimeMake(value: Int64(1), timescale: 300), queue: .main,
            using: { [weak self] time in
                guard let strongSelf = self else { return }
                strongSelf.periodicTimeProcess(time: time)
            })
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive),
           name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func removeObserver() {
        if let observer = self.timeObserver {
            self.player.removeTimeObserver(observer)
            self.timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? AVPlayer == self.player {
            if let currentItem = self.player.currentItem {
                if keyPath == "currentItem.status"  {
                    if currentItem.status == .some(.readyToPlay) {
                        self.statusEvent?(.ReadyToPlay)
                        if self.isPlaying { self.play() }
                    } else if currentItem.status == .some(.failed) {
                        self.playerError(errorMessage: currentItem.error.debugDescription)
                    }
                } else if keyPath == "playbackBufferEmpty" {
                    self.statusEvent?(.Buffering)
                } else if keyPath == "playbackLikelyToKeepUp" {
                    self.statusEvent?(.Playing)
                } else if keyPath == "playbackBufferFull" {
                    self.statusEvent?(.Playing)
                }
            }
        }
    }
    
    @objc
    private func applicationDidBecomeActive() {
        if self.isPlaying {
            self.player?.play()
        }
    }
    
    func playerError(errorMessage:String) {
        print(errorMessage)
    }
    
    private func periodicTimeProcess(time:CMTime) {
        if let playerDuration = self.player.currentItem?.duration {
            
            let totalTime = CMTimeGetSeconds(playerDuration)
            
            if !totalTime.isNaN {
                var currentTime = CMTimeGetSeconds(time)
                currentTime = currentTime > totalTime ? totalTime : currentTime
                
                self.timeEvent?(currentTime, totalTime)
            }
        }
    }
    
    @objc
    private func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == self.player.currentItem {
            self.statusEvent?(.Finished)
        }
    }
    
    func seekToTime(time:Float64, seekingFinish: (()->Void)? = nil) {
        
        if let playerItem = self.player.currentItem {
            playerItem.seek(to: CMTime(seconds: time, preferredTimescale: 1), completionHandler: { (isFinish) in
                self.play()
                seekingFinish?()
            })
        }
    }
    
    func currentSecond() -> Float64 {
        if let playerItem = self.player.currentItem {
            let current = CMTimeGetSeconds(playerItem.currentTime())
            return current
        }
        return 0
    }
    
    func totalSecond() -> Float64 {
        if let playerItem = self.player.currentItem {
            let duration = playerItem.duration
            let durationTime = CMTimeGetSeconds(duration)
            if durationTime.isNaN {
                return 0
            } else {
                return durationTime
            }
        } else {
            return 0
        }
    }
    
    deinit {
        self.stop()
        self.removeObserver()
    }
}

public enum PlayerStatus {
    case ReadyToPlay
    case Playing
    case Buffering
    case Paused
    case Stoped
    case Finished
}

