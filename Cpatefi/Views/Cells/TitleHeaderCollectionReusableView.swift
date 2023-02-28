//
//  TitleHeaderCollectionReusableView.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 29.01.23.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Static  Properties
    static let identifier = "TitleHeaderCollectionReusableView"
    
    // MARK: - Private  Properties
    private let label : UILabel  = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    // MARK: - Override Methods
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: width - 30, height: height)
    }
    
    // MARK: - Methods
    func configure(with title: String){
        label.text = title
    }
    
}
