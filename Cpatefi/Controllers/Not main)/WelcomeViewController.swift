//
//  WelcomeViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - Private Properties
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Cpatefi", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let imageView : UIImageView = {
      let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "back")
        return imageView
    }()
    
    private let blurView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    private let logoView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "newLogo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32,weight: .semibold)
        label.text = "Listen to Millions\n of Songs"
     return label
    }()
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cpatefi"
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(blurView)
        view.addSubview(signInButton)
        view.addSubview(label)
        view.addSubview(logoView)
      
        signInButton.addTarget(self, action: #selector(tapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.center.x = 20
        signInButton.center.y = view.height-50-view.safeAreaInsets.bottom
        signInButton.frame.size = CGSize(width: view.width - 40, height: 50)
        signInButton.layer.cornerRadius = 25
        imageView.frame = view.bounds
        blurView.frame = view.bounds
        logoView.frame = CGRect(x: (view.width-120)/2, y: (view.height-200)/2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoView.bottom+30, width: view.width-60, height: 150)
    }
    
    // MARK: - Private Methods
    @objc private func tapSignIn(){
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success: Bool){
        guard success else {
            let alert = UIAlertController(title: "Zakrito", message: "WRONG", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel))
            present(alert,animated: true)
            return
        }
        let mainAppTabBarVC = TabBarController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC,animated: true)
    }
}
