
# Youtube Swipe Player

It is a open source framework to create player seems youtube for IOS.

<p float="left">
  <img src="https://www.serkanhocam.com/github/youtube_player/anim.gif" width="300" />
</p>

## Usage:

Add fallowing code in cocapods file and run "pod update" on Terminal.

<p>
  pod 'SwipePlayer', :git => "https://github.com/SerkanHocam/YoutubeSwipePlayer.git"
</p>

Create an instance and show it.

####Javascript　

```swift
    let player = SwipePlayer(viewController: self)
    player.detailView = YourOwnDetailView()
    guard let url = URL(string: "https://yourVideoUrl.m3u8") else { return }
    player.start(videoUrl: url)
```

It start fallowing image.

<p float="left">
  <img src="https://www.serkanhocam.com/github/youtube_player/default.png" width="300" />
</p>

It is convenient to customize Overlay, Header, Minimize View.
The sample project can help how to customize views.

<p float="left">
  <img src="https://www.serkanhocam.com/github/youtube_player/overlay.png" width="300" />
  <img src="https://www.serkanhocam.com/github/youtube_player/header.png" width="300" />
</p>

## Supported versions & requirements:

- Swift 5+
- iOS 13+
- Xcode 14+

## Features

- Customizable views and player 
- Sample player applications & code samples
- Fullscreen playback management
- Support orientation to change full screen mode



