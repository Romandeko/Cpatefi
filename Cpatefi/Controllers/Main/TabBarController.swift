//
//  TabBarController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 15.12.22.
//

import UIKit
import SDWebImage


protocol ConfigureSongViewDelegate: AnyObject {
    func configureSongView(_ url: URL, name : String, artist : String)
    func changeButtonImage()
    func changeProgress(time: Float)
}
class TabBarController: UITabBarController{
    
    // MARK: - Properties
     let songView  = SongView()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        songViewSetUp()
        PlayerPresenter.shared.delegate = self
        
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = LibraryViewController()
        
        vc1.title = "Home"
        vc2.title = "Search"
        vc3.title = "Library"
        
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 1)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1,nav2,nav3], animated: true)
    }
    
    // MARK: - Methods methods
    private func songViewSetUp(){
        songView.frame.size.height = 60
        songView.frame.size.width = view.frame.width - 20
        songView.layer.cornerRadius = 10
        songView.frame.origin.x = 10
        songView.frame.origin.y = view.frame.height - 145
        songView.isHidden = true
        view.addSubview(songView)
        songView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPlayer)))
    }
 
    @objc private func openPlayer(){
        guard let vc = PlayerPresenter.shared.playerVC else { return }
        present( (vc ) ,animated: true )
    }
}

extension TabBarController : ConfigureSongViewDelegate {
    
    func configureSongView(_ url: URL, name: String, artist: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){[weak self] in
            self?.songView.isHidden = false
        }
        
        songView.albumCoverImageView.sd_setImage(with: url)
        songView.trackNameLabel.text = name
        songView.atristNameLabel.text = artist
        guard let averageColor =   songView.albumCoverImageView.image?.averageColor else { return  }
        songView.backgroundColor = averageColor
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = songView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.8
        songView.addSubview(blurEffectView)
        songView.insertSubview(blurEffectView, belowSubview: songView.albumCoverImageView)
    }
    
    func changeButtonImage() {
        songView.changeImage()
    }
    func changeProgress(time : Float) {
        songView.progressView.setProgress(Float(time/30.0), animated: true)
    }
}
