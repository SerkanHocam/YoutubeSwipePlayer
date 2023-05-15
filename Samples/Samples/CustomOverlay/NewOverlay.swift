//
//  PlayerOverlay.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 24.02.2023.

import UIKit
import SwipePlayer

class NewOverlay:UIView, IOverlayView {
    
    var player: SwipePlayer!
    
    @IBOutlet weak var vwLoading: UIActivityIndicatorView!
    @IBOutlet weak var vwControls: UIView!
    @IBOutlet weak var vwFligran: UIView!
    
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnFullScreen: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    @IBOutlet weak var seekBar: UISlider!
    
    @IBOutlet weak var vwPlayer: UIView!
    
    private var timerForOverlay: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vwControls.isHidden = true
        self.vwLoading.isHidden = true
        self.seekBar.value = 0
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundView_click)))
        self.seekBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.seekbar_click(organizer:))))
    }
    
    @objc
    func backgroundView_click() {
        if self.player.swipeViewState == .maximized {
            if self.vwControls.isHidden {
                self.showOverlay()
            } else {
                self.hideOverlay()
            }
        }
    }
    
    private var startSeeking = false
    private var totalTime: Float64 = 0
    
    @objc
    func seekbar_click(organizer:UITapGestureRecognizer) {
        let touchPoint = organizer.location(in: organizer.view)
        let seekValue = Float(touchPoint.x / self.seekBar.bounds.width)
        
        self.seekBar.value = seekValue
        let seetTime = self.totalTime * Float64(seekValue)
        
        self.player.seekToTime(time: seetTime) {[weak self] in
            self?.hideOverlayByTime()
        }
    }
    
    @IBAction func seekBar_start() {
        self.totalTime = self.player.totalTime
        if self.totalTime > 0 {
            self.startSeeking = true
            self.timerForOverlay?.invalidate()
        }
    }
    
    @IBAction func seekBar_end() {
        if self.startSeeking {
            self.startSeeking = false
            self.showLoading()
            let seetTime = self.totalTime * Float64(self.seekBar.value)
            
            self.player.seekToTime(time: seetTime) {[weak self] in
                self?.hideLoading()
                self?.hideOverlayByTime()
            }
        }
    }
    
    @IBAction func seekBar_progress() {
        let currentTime = self.totalTime * Float64(self.seekBar.value)
        self.updateTextForTime(currentTime: currentTime, totalTime: self.totalTime)
    }
    
    func hideOverlayByTime() {
        self.timerForOverlay?.invalidate()
        self.timerForOverlay = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] timer in
            self?.hideOverlay()
        })
    }
    
    @IBAction
    func btnPlayPause_click(_ sender: Any) {
        self.player.toggle()
    }
    
    @IBAction
    func btnFullScreen_click(_ sender: Any) {
        self.player.toggleFullScreen()
    }
    
    @IBAction
    func btnClose_click(_ sender: Any) {
        self.player.exitFullScreen(animated: false)
        self.player.close()
    }
    
    private func updateTextForTime(currentTime:Float64, totalTime:Float64) {
        let txtCurrent = self.formatTime(videoTime: Int(currentTime))
        let txtTotal = self.formatTime(videoTime: Int(totalTime))
        self.lblTime.text = "\(txtCurrent)"
        self.lblDuration.text = "\(txtTotal)"
    }
    
    private func formatTime(videoTime: Int) -> String {
        let seconds = videoTime % 60
        let minutes = (videoTime / 60) % 60
        let hours   = videoTime / 3600
        
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d",hours, minutes, seconds)
        }
    }
    
    func updateUI(status: PlayerStatus) {
        switch status {
        case .ReadyToPlay:
            break
        case .Playing:
            self.btnPlayPause.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.hideOverlayByTime()
            break
        case .Paused:
            self.btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.timerForOverlay?.invalidate()
            break
        case .Stoped:
            self.btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
            break
        case .Finished:
            self.btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
            break
        case .Buffering:
            self.showLoading()
        }
    }
    func updateSeekbar(currentTime: Float64, totalTime: Float64) {
        if !self.startSeeking {
            let seekBarValue = Float(currentTime / totalTime)
            self.seekBar.value = seekBarValue
            
            self.updateTextForTime(currentTime: currentTime, totalTime: totalTime)
        }
    }
    func showOverlay() {
        if self.player.swipeViewState == .maximized {
            self.vwControls.isHidden = false
            self.seekBar.isHidden = false
            self.vwFligran.isHidden = false
        }
    }
    func hideOverlay() {
        self.vwControls.isHidden = true
        self.seekBar.isHidden = true
        self.vwFligran.isHidden = true
        self.timerForOverlay?.invalidate()
    }
    func showLoading() {
        self.vwLoading.startAnimating()
        self.vwLoading.isHidden = false
        self.hideOverlay()
    }
    func hideLoading() {
        self.vwLoading.stopAnimating()
        self.vwLoading.isHidden = true
        self.showOverlay()
    }
    func getPlayerView() -> UIView {
        return self.vwPlayer
    }
    func orientationChange(current:UIInterfaceOrientationMask) {
        var controlsFrame = self.vwFligran.frame
        if current == .portrait {
            controlsFrame.size = CGSize(width: self.frame.width - 30, height: controlsFrame.height)
        } else {
            let width = self.frame.width - (self.safeAreaInsets.left + self.safeAreaInsets.right)
            controlsFrame.size = CGSize(width: width - 30, height: controlsFrame.height)
            
        }
        controlsFrame.origin = CGPoint(x: self.frame.width / 2 - controlsFrame.width / 2, y: controlsFrame.origin.y)
        
        self.vwControls.frame = controlsFrame
        self.vwFligran.frame = controlsFrame
    }
}
