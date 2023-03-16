//
//  PlayerControllsView.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 6.02.23.
//

import Foundation
import UIKit

protocol PlayerControllsViewDelegate : AnyObject{
    func PlayerControllsViewDidTapPlayPauseButton(_ playersCpntrollsView : PlayerControllsView)
    func PlayerControllsViewDidTapForwardButton(_ playersCpntrollsView : PlayerControllsView)
    func PlayerControllsViewDidTapBackwardButton(_ playersCpntrollsView : PlayerControllsView)
    func PlayerControllsView(_ playersCpntrollsView : PlayerControllsView,didSlideTime value : Float)
}

struct PlayerControlsViewModel{
    let title : String?
    let artist : String?
}

final class PlayerControllsView : UIView {
    
    // MARK: -   Properties
    weak var delegate : PlayerControllsViewDelegate?
    
    let timeSlider : UISlider = {
        let slider = UISlider()
        slider.tintColor = .white
        return slider
    }()
    
    let playPauseButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(named: "playMusic"), for: .normal)
        
        return button
    }()
    
    let currentTimeLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "0:00"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor  = .white
        return label
    }()
    
    let maxTimeLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "3:55"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor  = .white
        return label
    }()
    
    let shuffleButton : UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "shuffle",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    let repeatButton : UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "repeat",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        button.setImage(image, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Private  Properties
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "Rockstar"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let artistsLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "Post Malone"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor  = .secondaryLabel
        return label
    }()
    
    private let backButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        
        button.setImage(UIImage(named: "prevMusic"), for: .normal)
        return button
    }()
    
    private let nextButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(named: "nextMusic"), for: .normal)
        return button
    }()
    
    private var isPlaying = true
    
    // MARK: - Override Methods
    override init(frame : CGRect ){
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(nameLabel)
        addSubview(artistsLabel)
        addSubview(timeSlider)
        addSubview(backButton)
        addSubview(playPauseButton)
        addSubview(nextButton)
        addSubview(currentTimeLabel)
        addSubview(maxTimeLabel)
        addSubview(repeatButton)
        addSubview(shuffleButton)
        clipsToBounds = true
        
        timeSlider.addTarget(self, action: #selector(didSlide), for: .valueChanged)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(didTapRepeat), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.frame = CGRect(x: 0, y: 10, width: width, height: 25)
        artistsLabel.frame = CGRect(x: 0, y: nameLabel.bottom, width: width, height: 25)
        timeSlider.frame = CGRect(x: 0, y: artistsLabel.bottom + 20, width: width, height: 44)
        currentTimeLabel.frame = CGRect(x: 2, y: timeSlider.bottom, width: 40, height: 16)
        
        maxTimeLabel.frame = CGRect(x: timeSlider.width - 36, y: timeSlider.bottom, width: 40, height: 16)
        
        let buttonSize : CGFloat = 55
        
        playPauseButton.frame = CGRect(x: (width-buttonSize)/2 , y: timeSlider.bottom + 50, width: buttonSize, height: buttonSize)
        backButton.frame = CGRect(x: playPauseButton.left - 70, y: playPauseButton.top, width: buttonSize / 1.8, height: buttonSize / 1.8)
        nextButton.frame = CGRect(x: playPauseButton.right  + 70 - buttonSize / 1.8 , y: playPauseButton.top, width: buttonSize / 1.8, height: buttonSize / 1.8)
        
        shuffleButton.frame = CGRect(x: 0 , y: 0, width: buttonSize / 1.4, height: buttonSize / 1.4)
        repeatButton.frame = CGRect(x: timeSlider.width - buttonSize/1.4, y: 0, width: buttonSize / 1.4, height: buttonSize / 1.4)
        
        backButton.center.y = playPauseButton.center.y
        nextButton.center.y = playPauseButton.center.y
        shuffleButton.center.y = playPauseButton.center.y
        repeatButton.center.y = playPauseButton.center.y
    }
    
    // MARK: - Private Methods
    @objc private func didTapBack(){
        delegate?.PlayerControllsViewDidTapBackwardButton(self)
    }
    
    @objc private func didTapNext(){
        delegate?.PlayerControllsViewDidTapForwardButton(self)
    }
    
    @objc private func didTapPlayPause(){
        changeButtonImage()
        delegate?.PlayerControllsViewDidTapPlayPauseButton(self)
    }
    
    @objc private func didTapShuffle(){
        if shuffleButton.isSelected {
            shuffleButton.backgroundColor = .clear
            shuffleButton.tintColor = .white
        } else {
            shuffleButton.backgroundColor = .white
            shuffleButton.tintColor = .black
            
        }
        shuffleButton.isSelected.toggle()
        
    }
    
    @objc private func didTapRepeat(){
        if repeatButton.isSelected {
            repeatButton.setImage( UIImage(systemName: "repeat",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)), for: .normal)
            repeatButton.backgroundColor = .clear
            repeatButton.tintColor = .white
        } else {
            repeatButton.setImage( UIImage(systemName: "repeat.1",withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)), for: .normal)
            repeatButton.backgroundColor = .white
            repeatButton.tintColor = .black
        }
        repeatButton.isSelected.toggle()
    }
    
    @objc private func didSlide(_ slider : UISlider){
        let value = slider.value
        delegate?.PlayerControllsView(self, didSlideTime: value)
    }
   
    // MARK: - Methods
    func changeButtonImage(){
        self.isPlaying.toggle()
        let play = UIImage(named: "playMusic")
        let pause = UIImage(named: "stopMusic")
        playPauseButton.setImage(isPlaying ? play : pause, for: .normal)
    }
    
    func configure( with viewModel : PlayerControlsViewModel){
        nameLabel.text = viewModel.title
        artistsLabel.text = viewModel.artist
        
    }
}
