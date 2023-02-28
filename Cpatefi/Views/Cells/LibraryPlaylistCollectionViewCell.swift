//
//  LibraryPlaylistCollectionViewCell.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 19.02.23.
//



import UIKit
import SDWebImage

class LibraryPlaylistCollectionViewCell: UICollectionViewCell {
    // MARK: - Static  Properties
    static let identitier = "LibraryPlaylistCollectionViewCell"
    
    // MARK: - Private  Properties
    private let playlistCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "music.note")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    private let playlistNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18,weight: .regular)
        return label
    }()
    
    // MARK: - Override Methods
    override init(frame:CGRect){
        super.init(frame: frame)
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.height-30
        playlistCoverImageView.frame = CGRect(x: (contentView.width-imageSize)/2,
                                              y: 3,
                                              width: imageSize,
                                              height: imageSize)
        playlistNameLabel.frame = CGRect(x: 3,
                                         y: playlistCoverImageView.bottom,
                                         width: contentView.width-6,
                                         height: 30)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        playlistCoverImageView.image = nil
    }
    
    // MARK: - Methods
    func configure(with viewModel : SearchResultSubtitleTableViewCellViewModel){
        playlistNameLabel.text = viewModel.title
        playlistCoverImageView.sd_setImage(with: viewModel.imageURL,placeholderImage: UIImage(named: "note"))
    }
}


