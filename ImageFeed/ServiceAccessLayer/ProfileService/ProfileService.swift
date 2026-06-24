//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 23.06.2026.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    
    private(set) var profile: Profile?
    
    private var task: URLSessionTask?
    private var activeRequestID: UUID?
    
    private init() { }
    
    func clearProfileCache() {
        task?.cancel()
        task = nil
        activeRequestID = nil
        profile = nil
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[fetchProfile]: NetworkError.invalidRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let requestID = UUID()
        activeRequestID = requestID
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            defer {
                if self.activeRequestID == requestID {
                    self.task = nil
                    self.activeRequestID = nil
                }
            }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: Self.makeName(
                        firstName: profileResult.firstName,
                        lastName: profileResult.lastName
                    ),
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[fetchProfile]: \(error)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private helpers
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private static func makeName(firstName: String?, lastName: String?) -> String {
        [firstName, lastName]
            .compactMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
