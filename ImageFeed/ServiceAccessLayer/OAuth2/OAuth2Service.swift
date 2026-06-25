//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 26.05.2026.
//

import Foundation

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Private properties
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private var activeRequestID: UUID?
    
    // MARK: - Private init
    
    private init() { }
    
    // MARK: - Public API
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            lastCode = nil
            print("[fetchOAuthToken]: NetworkError.invalidRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let requestID = UUID()
        activeRequestID = requestID
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            guard self.activeRequestID == requestID else { return }
            
            defer {
                if self.activeRequestID == requestID {
                    self.task = nil
                    self.lastCode = nil
                    self.activeRequestID = nil
                }
            }
            
            switch result {
            case .success(let body):
                self.tokenStorage.token = body.accessToken
                completion(.success(body.accessToken))
            case .failure(let error):
                print("[fetchOAuthToken]: \(error)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private helpers
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

private struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
