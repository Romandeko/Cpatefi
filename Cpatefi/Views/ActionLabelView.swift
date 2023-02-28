//
//  ActionLabelView.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 17.02.23.
//

import UIKit

struct ActionLabelViewModel {
    let text : String
    let actionTitel : String
}

 protocol ActionLabelViewDelegate : AnyObject {
    func actionLabelViewDidTapButton( _ actionView : ActionLabelView)
}

class ActionLabelView: UIView {

    // MARK: - Properties
    weak var delegeate : ActionLabelViewDelegate?
    
    // MARK: - Private Properties
    private let label : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button : UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    // MARK: - Override Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isHidden = true
        addSubview(button)
        addSubview(label)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0, y: height-40, width: width, height: 40)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height-45)
    }
    
    // MARK: - Methods
    func configure(with viewModel : ActionLabelViewModel){
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitel, for: .normal)
    }
    
    @objc private func didTapButton(){
        delegeate?.actionLabelViewDidTapButton(self)
    }
}
