//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

import Foundation

nonisolated public protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

nonisolated final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol

    private enum Progress {
        static let completedValue: Float = 1.0
        static let epsilon: Float = 0.0001
    }

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            print("Failed to construct authorization URLRequest")
            return
        }

        view?.load(request: request)
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - Progress.completedValue) <= Progress.epsilon
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
