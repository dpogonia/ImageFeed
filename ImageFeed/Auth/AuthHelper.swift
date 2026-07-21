//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

nonisolated final class AuthHelper: AuthHelperProtocol {
    private enum AuthQuery {
        static let clientId = "client_id"
        static let redirectURI = "redirect_uri"
        static let responseType = "response_type"
        static let scope = "scope"
        static let code = "code"
        static let responseTypeCode = "code"
        static let nativePath = "/oauth/authorize/native"
    }

    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            return nil
        }

        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            assertionFailure("Invalid authorization URL string: \(configuration.authURLString)")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: AuthQuery.clientId, value: configuration.accessKey),
            URLQueryItem(name: AuthQuery.redirectURI, value: configuration.redirectURI),
            URLQueryItem(name: AuthQuery.responseType, value: AuthQuery.responseTypeCode),
            URLQueryItem(name: AuthQuery.scope, value: configuration.accessScope)
        ]

        return urlComponents.url
    }

    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == AuthQuery.nativePath,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == AuthQuery.code })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
