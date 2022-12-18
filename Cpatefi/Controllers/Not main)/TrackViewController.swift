//
//  ViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 12.12.22.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit

class TrackViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var shuffleMusicButton: UIButton!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var circleMusicButton: UIButton!
    @IBOutlet weak var playMusicButton: UIButton!
    //MARK: - Properties
    private var tracklist = [URL]()
    private var currentTrack = 0
    private var player = AVAudioPlayer()
    private var backgroundView = UIView()
    private var songDuration = 0
    private var minutesDuration = 0
    private var secondsDuration = 0
    private var secondsString = ""
    private var currentMinutes = 0
    private var currentSeconds = 0
    private var nowPlayingInfo = [String : Any]()
    private var artistName = "Unknown Artist"
    private var musicTitle = "Unknown Title"
    private var musicImage = UIImage(named: "placeholder")
    weak var currentTimer : Timer? = nil
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackground()
        fillPlaylist()
        startTimer()
        setupNowPlaying()
        setupRemoteTransportControls()
        try? AVAudioSession.sharedInstance().setActive(true)
        player.play()
    }
    //MARK: - Background Player methods
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            if !self.player.isPlaying {
                play()
                return .success
            }
            return .commandFailed
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            
            if self.player.isPlaying {
                stop()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget{ [unowned self] event in
            currentTrack += 1
            updateTrackInfo()
            playSomeTrack()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget{ [unowned self] event in
            currentTrack -= 1
            updateTrackInfo()
            playSomeTrack()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget {[unowned self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                player.currentTime = event.positionTime
            }
            return .success
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    private  func setupNowPlaying() {
        nowPlayingInfo[MPMediaItemPropertyTitle] = musicTitle
        nowPlayingInfo[MPMediaItemPropertyArtist] = artistName
        if let image = musicImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    private  func updateNowPlaying(isPause: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 0 : 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    //MARK: - Timers
    private func startTimer(){
        stopTimer()
        guard self.currentTimer == nil else { return }
        self.currentTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
    }
    private func stopTimer(){
        guard currentTimer != nil else { return }
        currentTimer?.invalidate()
        currentTimer = nil
    }
    
    @objc func updateCurrentTime(){
        
        let time = Int(player.currentTime)
        currentMinutes = Int(time/60)
        currentSeconds = time % 60
        if currentSeconds < 10{ secondsString = "0\(String(currentSeconds))" }
        else{ secondsString = String(currentSeconds) }
        currentTime.text = "\(currentMinutes):\(secondsString)"
        
        slider.value = Float(player.currentTime)
        
        if time >= Int(player.duration){
            chooseSongToPlay()
        }
    }
    
    //MARK: - Choosing Track Methods
 
    private func updateSomeInfo(){
        setupNowPlaying()
        playMusic(self)
        slider.value = 0
    }
    private func chooseSongToPlay(){
        if circleMusicButton.isSelected {
            playCurrentTrack()
        } else if shuffleMusicButton.isSelected{
            playRandomTrack()
        } else {nextMusic(self)}
    }
    
    private func playSomeTrack(){
        guard !shuffleMusicButton.isSelected == true else {playRandomTrack()
            return
        }
        updateSomeInfo()
    }
    private func playCurrentTrack(){
        updateTrackInfo()
        updateSomeInfo()
    }
    private func playRandomTrack(){
        currentTrack = Int.random(in: 1...tracklist.count)
        updateTrackInfo()
        updateSomeInfo()
    }
    private func stop(){
        playMusicButton.setImage(UIImage(named: "stopMusic"), for: .normal)
        player.pause()
        updateNowPlaying(isPause: true)
        stopTimer()
    }
    private func play(){
        try? AVAudioSession.sharedInstance().setActive(true)
        playMusicButton.setImage(UIImage(named: "playMusic"), for: .normal)
        updateNowPlaying(isPause: false)
        player.play()
        startTimer()
    }
    private func fillPlaylist() {
        for track in 1...10 {
            guard let path = Bundle.main.path(forResource: "\(track).mp3", ofType:nil) else { continue }
            let url = URL(fileURLWithPath: path)
            tracklist.append(url)
        }
        try? AVAudioSession.sharedInstance().setCategory(
            AVAudioSession.Category.playback)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        updateTrackInfo()
    }
    private func updateTrackInfo() {
        guard tracklist.count > 0 else { return }
        currentTrack += tracklist.count
        currentTrack %= tracklist.count
        
        do {
            player = try AVAudioPlayer(contentsOf: tracklist[currentTrack])
        } catch { return }
        
        let asset = getAsset()
        let cmDuration = CMTimeGetSeconds(asset.duration)
        let stringDuration = String(cmDuration)
        guard let songDurationDouble = Double(stringDuration) else { return }
        songDuration = Int(songDurationDouble)
        minutesDuration = Int(songDuration/60)
        secondsDuration = songDuration % 60
        secondsString = ""
        
        let metaData = asset.metadata
        if let artist = metaData.first(where: {$0.commonKey == .commonKeyArtist}),
           let value = artist.value as? String {
            artistName = value
        }
        artistLabel.text = "\(artistName)"
        
        if let song = metaData.first(where: {$0.commonKey == .commonKeyTitle}),
           let value = song.value as? String {
            musicTitle = value
        }
        songLabel.text = "\(musicTitle)"
        
        if let albumImage = metaData.first(where: {$0.commonKey == .commonKeyArtwork}),
           let value = albumImage.value as? Data {
            musicImage = UIImage(data: value)
        }
        guard let averageColor =  musicImage?.averageColor?.cgColor else { return  }
        addGradient(withcolor: averageColor)
        imageView.image = musicImage
        
        if secondsDuration < 10{ secondsString = "0\(String(secondsDuration))" }
        else{ secondsString = String(secondsDuration) }
        timeLeft.text = "\(minutesDuration):\(secondsString)"
        currentTime.text = "0:00"
        slider.maximumValue = Float(songDuration)
    }
    private func getAsset() -> AVAsset {
        AVAsset(url: tracklist[currentTrack])
    }
    //MARK: - Views Setup
    private func addBackground(){
        backgroundView.makeBlur()
        backgroundView.frame.size = view.frame.size
        view.addSubview(backgroundView)
        view.insertSubview(backgroundView, belowSubview: imageView)
    }
    private func addGradient(withcolor color: CGColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [color, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        backgroundView.layer.addSublayer(gradientLayer)
    }
    
    //MARK: - IBActions methods
    
    @IBAction func playMusic(_ sender: Any) {
        if player.isPlaying{
            stop()
        } else {
            play()
        }
    }
    
    @IBAction func nextMusic(_ sender: Any) {
        currentTrack += 1
        updateTrackInfo()
        playSomeTrack()
    }
    
    @IBAction func prevMusic(_ sender: Any) {
        currentTrack -= 1
        updateTrackInfo()
        playSomeTrack()
        
    }
    
    @IBAction func shuffleMusic(_ sender: Any) {
        if shuffleMusicButton.isSelected {
            shuffleMusicButton.isSelected.toggle()
        } else {
            shuffleMusicButton.isSelected.toggle()
        }
    }
    
    @IBAction func circleMusic(_ sender: Any) {
        if circleMusicButton.isSelected {
            circleMusicButton.isSelected.toggle()
            circleMusicButton.setImage(UIImage(systemName:  "repeat"), for: .normal)
        } else {
            circleMusicButton.isSelected.toggle()
            circleMusicButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        }
    }
    
    @IBAction func changeTime(_ sender: UISlider) {
        if !slider.isTracking{
            player.currentTime = TimeInterval(slider.value)
        }
    }
}
