//
//  WelcomeViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import UIKit

class WelcomeViewController: UIViewController {
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Sign In with Cpatefi", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cpatefi"
        view.backgroundColor = .white
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(tapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.center.x = 20
        signInButton.center.y = view.center.y
        signInButton.frame.size = CGSize(width: view.width - 40, height: 50)
        signInButton.layer.cornerRadius = 25
    }
    
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
