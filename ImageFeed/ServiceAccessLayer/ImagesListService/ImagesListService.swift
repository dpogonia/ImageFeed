//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 25.06.2026.
//

import CoreGraphics
import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    
    private init() { }
    
    func clearPhotosCache() {
        task?.cancel()
        task = nil
        likeTask?.cancel()
        likeTask = nil
        photos = []
        lastLoadedPage = nil
    }
    
    func setPhotoSize(at index: Int, size: CGSize) {
        assert(Thread.isMainThread)
        guard photos.indices.contains(index) else { return }
        photos = photos.withReplaced(itemAt: index, newValue: photos[index].withSize(size))
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[fetchPhotosNextPage]: NetworkError.invalidRequest - token is missing")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            print("[fetchPhotosNextPage]: NetworkError.invalidRequest")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            defer { self.task = nil }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Self.makePhoto(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            case .failure(let error):
                print("[fetchPhotosNextPage]: \(error)")
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        guard likeTask == nil else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[changeLike]: NetworkError.invalidRequest - token is missing")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            print("[changeLike]: NetworkError.invalidRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            defer { self?.likeTask = nil }
            
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            switch result {
            case .success(let likeResult):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = photo.withIsLiked(likeResult.photo.likedByUser)
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                print("[changeLike]: \(error)")
                completion(.failure(error))
            }
        }
        
        likeTask = task
        task.resume()
    }
    
    // MARK: - Private helpers
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        var components = URLComponents(string: "\(Constants.defaultBaseURLString)/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeChangeLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/photos/\(photoId)/like") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = (isLike ? HTTPMethod.post : HTTPMethod.delete).rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private static func makePhoto(from result: PhotoResult) -> Photo {
        Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: date(from: result.createdAt),
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.regular,
            fullImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
    
    private static func date(from string: String?) -> Date? {
        guard let string else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}
