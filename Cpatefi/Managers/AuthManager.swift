//
//  AuthManager.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import Foundation

struct Constants{
    static let ClientID = "dfeec063d1d14414991e6b4c0cf2fab8"
    static let ClientSecret = "9baf3204133545a1bc5ed2aa694fc8c9"
    static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    static let redirectURI = "http://localhost:8888/callback"
    static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20%20playlist-modify-public%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
}

final class AuthManager{
    
    // MARK: - Properties
    static let shared = AuthManager()
    
    public var signInURL : URL?{
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.ClientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
        
    }
    
    
    var isSignedIn : Bool {
        return accessToken != nil
    }
    
    private var onRefreshBlocks = [((String) -> Void)]()
    
    private var refreshingToken = false
    
    private var accessToken : String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken : String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate : Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken : Bool{
        guard let expirationDate = tokenExpirationDate else { return false }
        let currentDate = Date()
        let fiveMinutes : TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    private init() { }
    
    // MARK: - Public Methods
    public func exchangeCodeForToken( code : String, completion: @escaping (Bool) -> Void){
        guard let url = URL(string: Constants.tokenAPIURL) else { return }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.ClientID+":"+Constants.ClientSecret
        guard  let data = basicToken.data(using: .utf8) else {
            completion(false)
            return
        }
        
        let base64string = data.base64EncodedString()
        request.setValue("Basic \(base64string)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){[weak self] data,_,error in
            guard let data = data, error == nil else{
                print("base63")
                completion(false)
                return
            }
            
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result:result)
                completion(true)
                print("SUCCESS \(result)")
            }
            catch{
                print(error)
                print("catch")
                completion(false)
            }
            
        }
        task.resume()
    }
    
    public func withValidToken(completion: @escaping ( String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken{
            refreshAccessToken{[weak self] success in
                
                if let token = self?.accessToken,success{
                    completion(token)
                }
                
            }
        }
        
        else if let token = accessToken{
            completion(token)
        }
    }
    
    public func refreshAccessToken(completion : @escaping(Bool) -> Void){
        guard !refreshingToken else { return }
        guard shouldRefreshToken else {
            completion(true)
            return
        }
        guard let refreshToken = self.refreshToken else { return }
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
            
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.ClientID+":"+Constants.ClientSecret
        guard  let data = basicToken.data(using: .utf8) else {
            completion(false)
            return
            
        }
        let base64string = data.base64EncodedString()
        request.setValue("Basic \(base64string)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){[weak self] data,_,error in
            self?.refreshingToken = false
            guard let data = data, error == nil else{
                print("base63")
                completion(false)
                return
            }
            
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach{$0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result:result)
                completion(true)
                print("REFRESHED")
            }
            catch{
                print(error.localizedDescription)
                print("catch")
                completion(false)
            }
            
        }
        task.resume()
        
    }

    public func signOut(completion: (Bool) -> Void){
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expirationDate")
        
        completion(true)
    }
    
    // MARK: - Private Methods
    private func cacheToken(result : AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token{
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
}
