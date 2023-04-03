//
//  VideoPlayer.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 23.02.2023.
//

import UIKit

class SwipePlayer {
    
    private let player = PlayerCore()
    private let swipeView: SwipeView
    private let parentVC: UIViewController
    
    private var minimizedFrame : CGRect = {
        let width = UIScreen.main.bounds.width / 2
        let height = width * 0.6
        return CGRect(x: 0.0, y: UIScreen.main.bounds.height - height - 80, width: width, height: height)
    }()
    
    public var currentTime : Float64 { return self.player.currentSecond() }
    public var totalTime : Float64 { return self.player.totalSecond() }
    public var swipeViewState : PlayerViewState { return self.swipeView.state }
    
    public var overlay : IOverlayView? {
        didSet {
            if let oldOverlay = oldValue {
                self.player.removeFromSuperview()
                oldOverlay.removeFromSuperview()
            }
            if let newOverlay = self.overlay {
                newOverlay.player = self
                
                let parent = newOverlay.getPlayerView()
                parent.addSubview(self.player)
                self.player.frame = parent.bounds
                
                self.swipeView.videoPlayer = self.overlay
            }
        }
    }
    
    public var miniPlayerView : IMiniPlayerView? {
        didSet {
            if let oldOverlay = oldValue {
                oldOverlay.removeFromSuperview()
            }
            if let newView = self.miniPlayerView {
                newView.player = self
                self.swipeView.minimizeView = newView
            }
        }
    }
    public var detailView : UIView? {
        didSet {
            if let oldDetail = oldValue {
                oldDetail.removeFromSuperview()
            }
            if let detail = self.detailView {
                self.swipeView.detailView = detail
            }
        }
    }
    public var backgroundColor:UIColor? {
        didSet {
            self.swipeView.backgroundColor = self.backgroundColor
        }
    }
    public var headerView : UIView? {
        didSet {
            if let oldHeader = oldValue {
                oldHeader.removeFromSuperview()
            }
            if let newHeader = self.headerView {
                self.swipeView.headerView = newHeader
            }
        }
    }
    init(viewController: UIViewController, minimizedPlayerFrame:CGRect? = nil, maximizedPlayerHeight:CGFloat? = nil) {
        self.parentVC = viewController
        if let frm = minimizedPlayerFrame {
            self.minimizedFrame = frm
        }
        self.player.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth,.flexibleHeight]
        
        self.swipeView = SwipeView(frame: self.minimizedFrame, maximizePlayerHeight: maximizedPlayerHeight)
        
        self.initialize()
    }
    
    private func initialize() {
        self.backgroundColor = .white
        if let view = Bundle.main.loadNibNamed("MinimizeView", owner: nil)?[0] as? IMiniPlayerView {
            self.miniPlayerView = view
        }
        if let view = Bundle.main.loadNibNamed("OverlayView", owner: nil)?[0] as? IOverlayView {
            self.overlay = view
        }
        self.player.statusEvent = { [weak self] statusInfo in
            guard let strongSelf = self else { return }
            if statusInfo == .ReadyToPlay {
                strongSelf.overlay?.hideLoading()
            }
            strongSelf.overlay?.updateUI(status: statusInfo)
            strongSelf.miniPlayerView?.updateUI(status: statusInfo)
        }
        self.player.timeEvent = { [weak self] (currentTime, totalTime) in
            guard let strongSelf = self else { return }
            strongSelf.overlay?.updateSeekbar?(currentTime: currentTime, totalTime: totalTime)
        }
        self.swipeView.swipeViewEvent = {[weak self] state in
            guard let strongSelf = self else { return }
            if state == .minimized {
                strongSelf.overlay?.hideOverlay()
                strongSelf.overlay?.swipeViewMinimized?()
            } else {
                strongSelf.overlay?.swipeViewMaximized?()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationRotate),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc
    private func orientationRotate() {
        switch UIDevice.current.orientation {
        case .portrait:
            self.exitFullScreen()
            break
        case .landscapeLeft, .landscapeRight:
            self.fullScreen()
            break
        default:
            break
        }
    }
    
    func seekToTime(time:Float64, onTime:(()->Void)? = nil) {
        self.player.seekToTime(time: time, seekingFinish: onTime)
    }
    
    public func toggleFullScreen() {
        if self.fullScreenVC == nil {
            self.fullScreen()
        } else {
            self.exitFullScreen()
        }
    }
    
    private var fullScreenVC : FullScreenVC?
    private var superView:UIView?
    
    var currentOrientation : UIInterfaceOrientationMask {
        return self.fullScreenVC == nil ? .portrait : .landscape
    }
    
    public func fullScreen() {
        if self.fullScreenVC == nil {
            
            let vc = FullScreenVC()
            vc.modalPresentationStyle = .fullScreen
            if let o = self.overlay {
                vc.playerView = o
                self.superView = o.superview
            } else {
                vc.playerView = self.player
                self.superView = self.player.superview
            }
            self.fullScreenVC = vc
            self.parentVC.present(vc, animated: true) { [weak self] in
                guard let overlay = self?.overlay else { return }
                overlay.orientationChange?(current: .landscape)
            }
        }
    }
    
    public func exitFullScreen(animated:Bool = true) {
        if let vc = self.fullScreenVC, let parentView = self.superView {
            
            if let o = self.overlay {
                o.frame = parentView.bounds
                parentView.addSubview(o)
            } else {
                self.player.frame = parentView.bounds
                parentView.addSubview(self.player)
            }
            self.overlay?.orientationChange?(current: .portrait)
            vc.dismiss(animated: animated)
            self.fullScreenVC = nil
        }
    }
    
    public func start(videoUrl:URL, fromTime:Int64 = 0) {
        self.parentVC.view.insertSubview(self.swipeView, at: self.parentVC.view.subviews.count)
        self.overlay?.showLoading()
        self.player.start(videoUrl: videoUrl, fromTime: fromTime)
        self.swipeView.open()
    }
    
    public func toggle() {
        if self.player.isPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    public func play() {
        self.player.play()
    }
    
    public func pause() {
        self.player.pause()
    }
    
    public func stop() {
        self.player.stop()
    }
    
    public func close() {
        self.player.stop()
        self.swipeView.close()
    }
    
    func showOverlay() {
        self.overlay?.showOverlay()
    }
    
    func hideOverlay() {
        self.overlay?.hideOverlay()
    }
    
    deinit {
        self.player.stop()
        self.overlay = nil
        self.miniPlayerView = nil
        self.detailView = nil
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}


