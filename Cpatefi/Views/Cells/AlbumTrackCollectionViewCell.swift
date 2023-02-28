//
//  AlbumTrackCollectionViewCell.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 30.01.23.
//

import Foundation
import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static  Properties
    static let identifier = "AlbumTrackCollectionViewCell"
    
    // MARK: - Private  Properties
    private let trackNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18,weight: .regular)
        return label
    }()
    
    private let atristNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15,weight: .medium)
        return label
    }()
    
    private let albumCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "note")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: - Override Methods
    override init(frame:CGRect){
        super.init(frame: frame)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(atristNameLabel)
        contentView.addSubview(albumCoverImageView)
        contentView.clipsToBounds = true
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCoverImageView.frame = CGRect(
            x: 5,
            y: 2,
            width: contentView.height - 8,
            height: contentView.height - 8)
        trackNameLabel.frame = CGRect(
            x: albumCoverImageView.right + 10,
            y: 0,
            width: contentView.width-albumCoverImageView.right-15,
            height: (contentView.height)/3)
        atristNameLabel.frame = CGRect(
            x: albumCoverImageView.right + 10,
            y: trackNameLabel.bottom,
            width: contentView.width-albumCoverImageView.right-15,
            height: (contentView.height)/2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        atristNameLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    // MARK: - Methods
    func configure(with viewModel : AlbumCollectionViewCellViewViewModel,url : URL){
        trackNameLabel.text = viewModel.name
        atristNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: url)
    }
}
