//
//  SwipeView.swift
//  YoutubePlayer
//
//  Created by Serkan Kayaduman on 23.02.2023.
//

import UIKit
import AVFoundation

class SwipeView: UIView, UIGestureRecognizerDelegate {
    
    private var headerArea = UIView()
    private var playerArea = UIView()
    private var detailArea = UIView()
    
    private var maximizedPlayerFrame : CGRect!
    private var minimizedPlayerFrame: CGRect!
    private var direction = Direction.none
    
    var minimizeView: UIView? {
        didSet {
            guard let mv = self.minimizeView else { return }
            mv.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.swipeGesture)))
            self.insertSubview(mv, at: 1)
        }
    }
    var videoPlayer : UIView? {
        didSet {
            guard let pl = self.videoPlayer else { return }
            self.playerArea.addSubview(pl)
        }
    }
    var headerView : UIView? {
        didSet {
            guard let header = self.headerView else { return }
            self.headerArea.addSubview(header)
        }
    }
    var detailView : UIView? {
        didSet {
            guard let detail = self.detailView else { return }
            detail.frame = self.detailArea.bounds
            detail.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
            self.detailArea.addSubview(detail)
        }
    }
    var state = PlayerViewState.hidden
    var swipeViewEvent : ((PlayerViewState)->Void)?
    
    @available(*, unavailable)
    init() {
        super.init(frame:CGRect.zero)
    }
    @available(*, unavailable)
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame:CGRect, maximizePlayerHeight:CGFloat? = nil) {
        self.init(frame: frame)
        guard let h = maximizePlayerHeight else { return }
        self.maximizedPlayerFrame.size = CGSize(width: self.maximizedPlayerFrame.width, height: h)
    }
    
    override init(frame: CGRect) {
        let screen = UIScreen.main.bounds
        super.init(frame: CGRect(x: -screen.width, y: 0, width: screen.width, height: screen.height))
        
        self.maximizedPlayerFrame = CGRect(x: 0, y: 0, width: screen.width, height: screen.width * frame.height / frame.width)
        self.minimizedPlayerFrame = frame
        
        self.initialSettings()
    }
    
    override var backgroundColor: UIColor? {
        get { return self.headerArea.backgroundColor }
        set {
            self.headerArea.backgroundColor = newValue
            self.detailArea.backgroundColor = newValue
        }
    }
    
    private func initialSettings() {
        self.addSubview(self.headerArea)
        
        self.playerArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.maximize)))
        self.playerArea.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.swipeGesture)))
        
        self.addSubview(self.playerArea)
        self.insertSubview(self.detailArea, at: 0)
    }
    
    @objc
    func maximize() {
        self.state = .maximized
        self.finalizeViews(toState: .maximized)
    }
    
    func minimize() {
        self.state = .minimized
        self.finalizeViews(toState: .minimized)
    }
    
    func open() {
        if self.state == .hidden {
            guard let superView = self.superview else { return }
            
            let safeArea = superView.safeAreaInsets.top
            let screen = UIScreen.main.bounds
            
            if let header = self.headerView {
                let headerHeight = header.frame.height
                self.headerArea.frame = CGRectMake(0, 0, screen.width, safeArea + header.frame.height)
                header.frame = CGRect(x: header.frame.origin.x, y: safeArea, width: header.frame.width, height: headerHeight)
            } else {
                self.headerArea.frame = CGRectMake(0, 0, screen.width, safeArea)
            }
            let headerSpace = self.headerArea.frame.origin.y + self.headerArea.frame.height
            self.maximizedPlayerFrame.origin = CGPoint(x: self.maximizedPlayerFrame.origin.x, y: headerSpace)
            self.playerArea.frame = self.maximizedPlayerFrame
            
            let detailViewFrame = CGRectMake(0, self.playerArea.frame.origin.y + self.playerArea.frame.height, self.frame.width,
                                             self.frame.height - (self.playerArea.frame.origin.y + self.playerArea.frame.height))
            
            self.detailArea.frame = detailViewFrame
        }
        self.maximize()
    }
    
    func close() {
        self.finalizeViews(toState: .hidden)
    }
    
    //MARK: swipe delegate
    @objc
    private func swipeGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {

            self.headerArea.isHidden = true
            
            let velocity = sender.velocity(in: nil)
            if abs(velocity.x) < abs(velocity.y) {
                self.direction = .vertical
                self.frame.size = CGSize(width: self.frame.size.width, height: UIScreen.main.bounds.height)
            } else {
                self.direction = .horizontal
            }
            if self.state == .minimized {
                self.swipeViewEvent?(.willMaximize)
            } else if self.state == .maximized {
                self.swipeViewEvent?(.willMinimize)
                self.playerArea.backgroundColor = .clear
            }
        }
        var finalState : PlayerViewState!
        switch self.state {
        case .maximized:
            let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
            self.swipeTo(factor: factor, toState: .minimized)
            finalState = factor > 0.05 ? .minimized : .maximized
        case .minimized:
            if self.direction == .vertical {
                let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
                self.swipeTo(factor: factor, toState: .maximized)
                finalState = .maximized
            } else {
                let factor: CGFloat = sender.translation(in: nil).x / UIScreen.main.bounds.width
                self.swipeTo(factor: factor, toState: .hidden)
                finalState = .hidden
            }
            
        default: break
        }
        if sender.state == .ended {
            self.state = finalState
            self.finalizeViews(toState: self.state)
        }
    }
    
    private func swipeTo(factor: CGFloat, toState: PlayerViewState) {
        
        switch toState {
        case .maximized:
            let headerMargin = self.headerArea.frame.height + self.headerArea.frame.origin.y
            self.calculateViews(to: self.minimizedPlayerFrame, from: self.maximizedPlayerFrame, margin: headerMargin, factor: factor, alpha: 1 - factor)
        case .minimized:
            self.calculateViews(to: self.maximizedPlayerFrame, from: self.minimizedPlayerFrame, margin: 0, factor: factor, alpha: factor)
        case .hidden:
            self.calculateViews(to: self.minimizedPlayerFrame, from: self.minimizedPlayerFrame, margin: 0, factor: factor, alpha: 1 - factor * 4)
        default: break
        }
    }
    
    private func calculateViews(to:CGRect, from:CGRect, margin:CGFloat, factor: CGFloat, alpha: CGFloat) {
        
        if self.direction == .vertical {
            let x = to.origin.x + (from.origin.x - to.origin.x) * factor
            let y = to.origin.y + (from.origin.y - to.origin.y) * factor
            let width = to.size.width + (from.size.width - to.size.width) * factor
            let height = to.size.height + (from.size.height - to.size.height) * factor
            
            self.playerArea.frame = CGRect(x: x, y: margin * factor, width: width, height: height)
            
            self.videoPlayer?.frame = self.playerArea.bounds
            
            self.detailArea.frame.origin = CGPoint(x: 0, y:self.playerArea.frame.origin.y + self.playerArea.frame.height)
            
            let colorAlpha = 1 - alpha
            self.detailArea.alpha = colorAlpha
            
            if let mv = self.minimizeView {
                let mvFrame = CGRect(x: 0, y: margin * factor, width: self.maximizedPlayerFrame.width, height: height)
                mv.frame = mvFrame
                mv.alpha = alpha
            }
            self.frame.origin = CGPoint(x: 0, y: y)
        } else {
            if let mv = self.minimizeView {
                mv.alpha = alpha
            }
            self.playerArea.frame.origin = CGPoint(x: self.frame.width * factor, y: self.playerArea.frame.origin.y)
        }
        
    }
    
    private func finalizeViews(toState: PlayerViewState) {
        
        switch toState {
        case .maximized:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
                self.frame = CGRect(x:0, y:0, width: self.frame.size.width, height: UIScreen.main.bounds.height)
                
                self.playerArea.frame =  self.maximizedPlayerFrame
                self.videoPlayer?.frame = self.playerArea.bounds
                
                self.detailArea.alpha = 1
                
                self.detailArea.frame.origin = CGPoint(x: 0, y: self.playerArea.frame.origin.y + self.playerArea.frame.height)
                self.detailArea.frame.size = CGSize(width: self.frame.width, height: self.frame.size.height - (self.detailArea.frame.origin.y))
                
                if let mv = self.minimizeView {
                    mv.frame = self.maximizedPlayerFrame
                    mv.alpha = 0
                }
                self.headerArea.isHidden = false
            })
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                self.frame = CGRect(x:0, y:self.minimizedPlayerFrame.origin.y, width: self.frame.size.width, height: self.minimizedPlayerFrame.height)
                
                self.playerArea.frame = CGRect(origin: CGPoint(x: self.minimizedPlayerFrame.origin.x, y: 0),
                                               size: self.minimizedPlayerFrame.size)
                self.videoPlayer?.frame = self.playerArea.bounds
                
                self.detailArea.alpha = 0
                self.detailArea.frame.origin = CGPoint(x: 0, y: self.playerArea.frame.height)
                
                if let mv = self.minimizeView {
                    let mvFrame = CGRect(x: 0, y: 0, width: self.maximizedPlayerFrame.width, height: self.minimizedPlayerFrame.height)
                    mv.frame = mvFrame
                    mv.alpha = 1
                }
                self.playerArea.backgroundColor = self.backgroundColor
            })
        case .hidden:
            self.frame.origin.x =  -self.frame.width
            self.playerArea.frame.origin = CGPoint(x: self.minimizedPlayerFrame.origin.x, y: 0)
        default: break
        }
        self.swipeViewEvent?(toState)
    }
}

public enum PlayerViewState {
    case willMinimize
    case minimized
    
    case willMaximize
    case maximized
    
    case hidden
}

public enum Direction {
    case vertical
    case horizontal
    case none
}
