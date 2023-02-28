//
//  NewReleasesCell.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 20.12.22.
//

import UIKit
import SDWebImage

class NewReleasesCell: UICollectionViewCell {
    
    // MARK: - Static  Properties
    static let identifier = "NewReleases"
    
    // MARK: - Private  Properties
    private let albumCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let albumNameLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20,weight: .semibold)
        return label
    }()
    
    private let numberOfTracksLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22,weight: .thin)
        return label
    }()
    
    private let artistNameLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22,weight: .light)
        return label
    }()
    
    // MARK: - Override Methods
    override init(frame:CGRect){
        super.init(frame: frame)
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
            super.layoutSubviews()
        let imageSize : CGFloat = contentView.height - 10
        let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width-imageSize, height: contentView.height-10))
        albumNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
       
        albumCoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        let albumLabelHeight = min(60,albumLabelSize.height)
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                           y: 5,
                                      width: albumLabelSize.width,
                                      height: albumLabelHeight)
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                       y: albumNameLabel.bottom,
                                       width: contentView.width-albumCoverImageView.right-10,
                                       height:25)
        
        numberOfTracksLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                           y: contentView.bottom - 44,
                                           width: numberOfTracksLabel.width + 20,
                                           height: 44)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    // MARK: - Methods
    func configure(with viewModel : NewReleasesCellViewModel){
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks : \(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL,completed: nil)
    }
}
