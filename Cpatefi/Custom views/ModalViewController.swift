//
//  ModalViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 22.02.23.
import UIKit

final class ModalViewController: UIViewController {
    
    var tapCloseButtonActionHandler : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
    }
    
    @IBAction func tapCloseButton() {
        self.tapCloseButtonActionHandler?()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ModalViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ModalViewController viewWillDisappear")
    }
}
