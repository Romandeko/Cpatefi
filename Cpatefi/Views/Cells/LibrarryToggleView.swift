//
//  LibrarryToggleView.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 16.02.23.
//

import UIKit

enum State {
    case playlist
    case album
}

protocol LibraryToggleViewDelegate : AnyObject {
    func librarryToggleViewDidTapPlaylists(_ toggleView : LibrarryToggleView)
    func librarryToggleViewDidTapAlbums(_ toggleView : LibrarryToggleView)
}

class LibrarryToggleView: UIView {
    // MARK: - Properties
    var state : State = .playlist
    weak var delegate : LibraryToggleViewDelegate?
    
    // MARK: - Private  Properties
    private let playlistButton : UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()
    
    private let albumstButton : UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    private let indicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: - Override  Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumstButton)
        addSubview(indicatorView)
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumstButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    required  init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumstButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
        
    }
    
    // MARK: - Methods
    func update(for state : State){
        self.state = state
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
    }
    
    // MARK: - Private Methods
    private func  layoutIndicator(){
        switch state {
        case .playlist :
            indicatorView.frame = CGRect(x: 0, y: Int(playlistButton.bottom), width: 100, height: 3)
        case . album:
            indicatorView.frame = CGRect(x: 100, y: Int(playlistButton.bottom), width: 100, height: 3)
        }
    }
    
    @objc private func didTapPlaylists(){
        state = .playlist
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
        delegate?.librarryToggleViewDidTapPlaylists(
            self)
    }
    
    @objc private func didTapAlbums(){
        state = .album
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
        delegate?.librarryToggleViewDidTapAlbums(self)
    }
}
