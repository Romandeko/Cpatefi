//
//  PlaybackPresenter.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 3.02.23.
//
import AVFoundation
import Foundation
import UIKit

protocol PlayerDataSource : AnyObject{
    var songName : String? { get }
    var artistName : String? { get }
    var imageURL : URL? { get }
}

final class PlayerPresenter {
    
    // MARK: - Static  Properties
    static let shared = PlayerPresenter()
    
    // MARK: - Weak  Properties
    weak var currentTimer : Timer? = nil
    
    // MARK: - Private  Properties
    private var track : AudioTrack?
    private var tracks = [AudioTrack]()
    
    // MARK: -   Properties
    var index = 0
    var playerVC : PlayerViewController?
    var player =  AVPlayer()
    var maxTime = 0
    var currentTime = 0
    var currentTrack : AudioTrack?
    
    
    // MARK: - Methods
    func startPlayback(from  viewController: UIViewController,tracks : [AudioTrack],index : Int) {
        guard let url = URL(string: tracks[index].preview_url ?? "") else { return }
        
        currentTrack = tracks[index]
        player = AVPlayer(url: url)
        self.tracks = tracks
        self.index = index
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(songEnded),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        viewController.present(UINavigationController(rootViewController: vc),animated: true ) { [weak self] in
            self?.player.play()
        }
        
        self.playerVC = vc
        
        currentTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        
        playerVC?.controllsView.maxTimeLabel.text = "0:30"
        
    }
    
    @objc func songEnded() {
       didTapForward()
    }
    
    func playNext(){
        currentTime = -1
        guard let url = URL(string: tracks[index].preview_url ?? "") else { return }
        player = AVPlayer(url: url)
        player.play()
        currentTrack = tracks[index]
        playerVC?.changeImage()
    }
    
    // MARK: - Timers
    private func startTimer(){
        stopTimer()
        guard self.currentTimer == nil else { return }
        self.currentTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
    }
    
    private func stopTimer(){
        guard currentTimer != nil else { return }
        currentTimer?.invalidate()
        currentTimer = nil
    }
    
    @objc private func updateCurrentTime(){
        currentTime += 1
        if currentTime < 10 {
            playerVC?.controllsView.currentTimeLabel.text = "0:0\(currentTime)"
        } else{
            playerVC?.controllsView.currentTimeLabel.text = "0:\(currentTime)"
        }
        playerVC?.controllsView.timeSlider.value = Float(Float(currentTime) / 30.0)
    }
}

// MARK: - Extensions
extension PlayerPresenter : PlayerViewControllerDelegate{
    
    func didTapPlayPause() {
        if  player == player {
            if player.timeControlStatus == .playing{
                player.pause()
                stopTimer()
            } else  if player.timeControlStatus == .paused{
                player.play()
                startTimer()
            }
        }
    }
    
    func didTapForward() {
        if  playerVC?.controllsView.shuffleButton.isSelected == true {
            index = Int.random(in: 0...tracks.count-1)
        } else {
            index += 1
        }
        
        if index == tracks.count{
            index = 0
        }
        
        if index <= tracks.count - 1 && tracks.count > 1 {
            playerVC?.nextImageURL =  URL(string: tracks[index].album?.images.first?.url ?? "")
            print(index)
        
        } else  if tracks.count > 1{
            playerVC?.nextImageURL =  URL(string: tracks[0].album?.images.first?.url ?? "")
        } else { playerVC?.nextImageURL =  URL(string: currentTrack?.album?.images.first?.url ?? "")}
        playerVC?.isForward = true
        playerVC?.refreshUI()
        playNext()
        
    }
    
    func didTapBackward() {
        index -= 1
        if index == -1{
            index = tracks.count - 1
        }

        playerVC?.nextImageURL =  URL(string: tracks[index].album?.images.first?.url ?? "")
        playerVC?.isForward = false
        playerVC?.refreshUI()
        playNext()
    }
    
    func didSlide(_ value: Float) {
        let myTime = CMTime(seconds: Double(value) * 30 , preferredTimescale: 60000)
        player.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = Int(Double(value) * 30)
        if currentTime < 10 {
            playerVC?.controllsView.currentTimeLabel.text = "0:0\(currentTime)"
        } else{
            playerVC?.controllsView.currentTimeLabel.text = "0:\(currentTime)"
        }
    }
}

// MARK: - Extensions
extension PlayerPresenter : PlayerDataSource{
    
    var songName: String? {
        return currentTrack?.name
    }
    
    var artistName: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: tracks[index].album?.images.first?.url ?? "")
    }
    
}
