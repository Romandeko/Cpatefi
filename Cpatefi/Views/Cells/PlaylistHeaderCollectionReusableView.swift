//
//  PlaylistHeaderCollectionReusableView.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 9.01.23.
//

import UIKit

protocol PlaylistHeaderCollectionReusableViewDelegate : AnyObject{
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll ( header : PlaylistHeaderCollectionReusableView)
}

class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Static  Properties
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    // MARK: - Weak  Properties
    weak var delegate :  PlaylistHeaderCollectionReusableViewDelegate?
    
    // MARK: - Private  Properties
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22,weight: .semibold)
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18,weight: .light)
        return label
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "note")
        return imageView
        
    }()
    
    private let playAllButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        let image = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    private var backgroundView = UIView()
    
    // MARK: - Override Methods
    override init(frame : CGRect){
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(backgroundView)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func  layoutSubviews() {
        super.layoutSubviews()
        let imageSize : CGFloat = height/1.5
        imageView.frame = CGRect(x:(width-imageSize)/2,
                                 y: 20,
                                 width: imageSize,
                                 height: imageSize)
        
        nameLabel.frame = CGRect(x: 10, y: width-70, width: width-20, height: 20)
        ownerLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width-20, height: 44)
        playAllButton.frame = CGRect(x: width - 80, y: height - 65, width: 60, height: 60)
        backgroundView.frame = bounds
    }
    
    // MARK: - Private Methods
    @objc private func didTapPlayAll(){
        delegate?.PlaylistHeaderCollectionReusableViewDidTapPlayAll(header: self)
    }
    
    private func addGradient(withcolor color: CGColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [color, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        backgroundView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Methods
    func configure(with viewModel: PlaylistHeaderViewModel){
        nameLabel.text = viewModel.playlistName
        ownerLabel.text = viewModel.ownerName
        imageView.sd_setImage(with: viewModel.artworkURL,placeholderImage: UIImage(named: "note"),completed:  nil)
        guard let averageColor =  imageView.image?.averageColor?.cgColor else { return  }
        addGradient(withcolor: averageColor)
    }
}
