//
//  PlayerViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate : AnyObject {
    func didTapPlayPause()
    func didTapBackward()
    func didTapForward()
    func didSlide(_ value : Float)
}

class PlayerViewController: UIViewController {
    
    // MARK: - Properties
    var isForward = false
    let controllsView = Cpatefi.PlayerControllsView()
    var nextImageURL : URL?
    
    // MARK: - Weak Properties
    weak var dataSource : PlayerDataSource?
    weak var delegate  : PlayerViewControllerDelegate?
    
    // MARK: - Private properties
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nextImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()    

    private var backgroundView = UIView()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        viewsSetUp()
        controllsView.delegate = self
        configure()
        
        guard let averageColor =  imageView.image?.averageColor?.cgColor else { return  }
        addGradient(withcolor: averageColor)
      
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 50, width: view.width - 40, height: view.width/1.2)
        nextImageView.frame = CGRect(x: 520, y: view.safeAreaInsets.top + 50, width: view.width - 40, height: view.width/1.2)
        controllsView.frame = CGRect(x: 20, y: imageView.bottom + 50, width: view.width - 40, height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15)
    }
    
   
    // MARK: - Methods
       func viewsSetUp(){
       view.backgroundColor = .systemBackground
       view.addSubview(imageView)
       view.addSubview(nextImageView)
       view.addSubview(controllsView)
       backgroundView.makeBlur()
       backgroundView.frame.size = view.frame.size
       backgroundView.bounds = view.bounds
       view.addSubview(backgroundView)
       view.insertSubview(backgroundView, belowSubview: imageView)
    }
    
    func configure(){
        imageView.sd_setImage(with: dataSource?.imageURL)
        controllsView.configure(with: PlayerControlsViewModel(title: dataSource?.songName, artist: dataSource?.artistName))
    }
    
    func refreshUI(){
        nextImageView.sd_setImage(with:nextImageURL)
    }
    
    func changeImage(){
        if isForward{
            controllsView.configure(with: PlayerControlsViewModel(title: dataSource?.songName, artist: dataSource?.artistName))
            if nextImageView.frame.origin.x != 520 {
                nextImageView.frame.origin.x = 520
            }
            UIView.animate(withDuration: 0.35){[weak self] in
                self?.imageView.frame.origin.x -= 500
                self?.nextImageView.frame.origin.x -= 500
            }completion: { [weak self] _ in
                var averageColor : CGColor?
                
                self?.imageView.image = self?.nextImageView.image
                self?.imageView.frame.origin.x = self?.nextImageView.frame.origin.x ?? 0
                self?.nextImageView.frame.origin.x = 520
                

                    averageColor =  self?.nextImageView.image?.averageColor?.cgColor


                self?.addGradient(withcolor: averageColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                
                self?.controllsView.playPauseButton.setImage(UIImage(named: "playMusic"), for: .normal)
                
            }
        } else{
            controllsView.configure(with: PlayerControlsViewModel(title: dataSource?.songName, artist: dataSource?.artistName))
            if nextImageView.frame.origin.x != -480 {
                nextImageView.frame.origin.x = -480
            }
            UIView.animate(withDuration: 0.35){[weak self] in
                self?.imageView.frame.origin.x += 500
                self?.nextImageView.frame.origin.x += 500
            }completion: { [weak self] _ in
                var averageColor : CGColor?
                
                self?.imageView.image = self?.nextImageView.image
                self?.imageView.frame.origin.x = self?.nextImageView.frame.origin.x ?? 0
                self?.nextImageView.frame.origin.x = -480
                

                    averageColor =  self?.nextImageView.image?.averageColor?.cgColor


                self?.addGradient(withcolor: averageColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                
                self?.controllsView.playPauseButton.setImage(UIImage(named: "playMusic"), for: .normal)
                
            }
        }
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
    
}

// MARK: - Extensions
extension PlayerViewController : PlayerControllsViewDelegate {
    func PlayerControllsViewDidTapPlayPauseButton(_ playersCpntrollsView: PlayerControllsView) {
        delegate?.didTapPlayPause()
    }
    
    func PlayerControllsViewDidTapForwardButton(_ playersCpntrollsView: PlayerControllsView) {
        delegate?.didTapForward()
    }
    func PlayerControllsViewDidTapBackwardButton(_ playersCpntrollsView: PlayerControllsView) {
        delegate?.didTapBackward()
    }
    func PlayerControllsView(_ playersCpntrollsView: PlayerControllsView, didSlideTime value: Float) {
        delegate?.didSlide(value)
    }
    
    
}
