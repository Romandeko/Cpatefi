//
//  GenreCollectionViewCell.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 31.01.23.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static  Properties
    static let identifier = "GenreCollectionViewCell"
    
    // MARK: - Private  Properties
    private let imageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "music.quarternote.3",withConfiguration:  UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        return imageView
    }()
    
    private let label : UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22,weight: .semibold)
        return label
    }()
    
    private let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemPurple,
        .systemOrange,
        .systemGreen,
        .systemBrown,
        .systemYellow,
        .darkGray,
        .systemTeal,
        .systemRed]

    // MARK: - Override Methods
    override init(frame :CGRect){
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = UIImage(systemName: "music.quarternote.3",withConfiguration:  UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: 0, width: contentView.width - 20, height: contentView.height/2)
        imageView.frame = CGRect(x: contentView.width/2, y: contentView.height/2 - 10, width: contentView.width/2, height: contentView.height/2)
    }
    
    // MARK: - Methods
    func configure(with viewModel : CategoryCollectionViewCellViewModel,index : Int){
        let index = colors.index(colors.startIndex,offsetBy: index)
        label.text = viewModel.title
        imageView.sd_setImage(with: viewModel.artworkURL, completed:  nil)
        contentView.backgroundColor = colors[index]
    }
}

