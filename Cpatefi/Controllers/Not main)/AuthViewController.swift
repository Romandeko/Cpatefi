//
//  AuthViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import UIKit
import WebKit
class AuthViewController: UIViewController,WKNavigationDelegate {
    
    // MARK: - Public Properties
    public var completionHandler : ((Bool) -> Void)?
    
    // MARK: - Private Properties
    private let webView : WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero,configuration: config)
        return webView
        
    }()
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Sign In"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        guard let url  = AuthManager.shared.signInURL else { return }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    // MARK: - Extension Methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        guard  let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: {$0.name == "code"})?.value else { return }
        
        print("Code: \(code)")
        webView.isHidden = true
        AuthManager.shared.exchangeCodeForToken(code: code){ [weak self] success in
            DispatchQueue.main.async {
                
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}
