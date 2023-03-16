//
//  SongView.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 6.03.23.
//

import Foundation
import UIKit

protocol SongViewDelegate : AnyObject{
    func SongViewDidTapPlayPauseButton(_ playersCpntrollsView : SongViewDelegate)

}
class SongView: UIView{
 
    weak var delegate : SongViewDelegate?
    
    // MARK: - Private  Properties
     let albumCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
         imageView.clipsToBounds = true
         imageView.layer.cornerRadius = 5
        return imageView
    }()
    
     let trackNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15,weight: .regular)
        return label
    }()
    
     let atristNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12,weight: .medium)
        return label
    }()
    
    let playPauseButton : UIButton = {
      let button = UIButton()
       button.tintColor = .label
        button.setImage(UIImage(systemName: "pause.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22,weight: .regular)), for: .normal)
       return button
   }()
    let progressView : UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = .gray
        progressView.progressTintColor = .white
        return progressView
    }()
    
    private var isPlaying = true
    
    // MARK: - Overirde  Methods
    override init(frame:CGRect){
        super.init(frame: frame)
        addSubview(albumCoverImageView)
        addSubview(trackNameLabel)
        addSubview(atristNameLabel)
        addSubview(playPauseButton)
        addSubview(progressView)
        clipsToBounds = true
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCoverImageView.frame = CGRect(
            x: 10,
            y: 6,
            width: height - 16,
            height:height - 16)
        trackNameLabel.frame = CGRect(
            x: albumCoverImageView.right + 10,
            y: 13,
            width: width-albumCoverImageView.right-45,
            height: 17)
        atristNameLabel.frame = CGRect(
            x: albumCoverImageView.right + 10,
            y: trackNameLabel.bottom,
            width: width-albumCoverImageView.right-15,
            height: 14)
        
        playPauseButton.frame = CGRect(x: width - 45, y: 13, width: height - 25, height: height - 25)
        
        progressView.frame = CGRect(x: 8, y: albumCoverImageView.bottom + 2, width: width - 16, height: 4)
    }
    
    
    // MARK: - Methods
    @objc  func didTapPlayPause(){
        PlayerPresenter.shared.didTapPlayPause()
        PlayerPresenter.shared.playerVC?.controllsView.changeButtonImage()
    }
    
    func changeImage(){
        self.isPlaying.toggle()
        let play = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22,weight: .regular))
        let pause = UIImage(systemName: "pause.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22,weight: .regular))
        playPauseButton.setImage(isPlaying ? pause : play , for: .normal)
    }
    
    func configure(with viewModel : RecommendedTrackCellViewModel){
        trackNameLabel.text = viewModel.name
        atristNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL,completed: nil)
    }
}
