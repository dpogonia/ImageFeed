//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 23.06.2026.
//

import Foundation

struct ProfileImage: Codable {
    let small: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var activeRequestID: UUID?
    
    private init() { }
    
    func clearAvatarCache() {
        task?.cancel()
        task = nil
        activeRequestID = nil
        avatarURL = nil
    }
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[fetchProfileImageURL]: NetworkError.invalidRequest - token is missing")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[fetchProfileImageURL]: NetworkError.invalidRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let requestID = UUID()
        activeRequestID = requestID
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            guard self.activeRequestID == requestID else { return }
            
            defer {
                if self.activeRequestID == requestID {
                    self.task = nil
                    self.activeRequestID = nil
                }
            }
            
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.small
                completion(.success(userResult.profileImage.small))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": userResult.profileImage.small]
                )
            case .failure(let error):
                print("[fetchProfileImageURL]: \(error)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private helpers
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
