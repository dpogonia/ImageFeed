//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 26.05.2026.
//

import Foundation

enum NetworkError: Error {
    
    // MARK: - Network Errors
    
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

// MARK: - URLSession API

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[data(for:)]: NetworkError.httpStatusCode - код ошибки \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[data(for:)]: NetworkError.urlRequestError - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[data(for:)]: NetworkError.urlSessionError")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        return data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    print(
                        "Ошибка декодирования: \(error.localizedDescription), " +
                        "Данные: \(String(data: data, encoding: .utf8) ?? "")"
                    )
                    let dataString = String(data: data, encoding: .utf8) ?? ""
                    print("[objectTask]: DecodingError - \(error), data: \(dataString)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[objectTask]: \(error)")
                completion(.failure(error))
            }
        }
    }
}
