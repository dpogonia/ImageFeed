//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private enum AccessibilityIdentifier {
        static let authenticateButton = "Authenticate"
        static let unsplashWebView = "UnsplashWebView"
        static let loginButton = "Login"
        static let likeButtonOff = "like button off"
        static let likeButtonOn = "like button on"
        static let navBackButtonWhite = "nav back button white"
        static let logoutButton = "logout button"
    }

    private enum Alert {
        static let logoutTitle = "Выход"
        static let confirmButton = "Да"
    }

    private let app = XCUIApplication()
    private let login = ""
    private let password = ""
    private let profileName = "Dmitrii Pogonia"
    private let profileLogin = "@dpogonia"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        app.buttons[AccessibilityIdentifier.authenticateButton].tap()

        let webView = app.webViews[AccessibilityIdentifier.unsplashWebView]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText(login)
        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText(password)
        webView.swipeUp()

        webView.buttons[AccessibilityIdentifier.loginButton].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        let tablesQuery = app.tables

        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        cell.swipeUp()

        sleep(2)

        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)

        cellToLike.buttons[AccessibilityIdentifier.likeButtonOff].tap()
        cellToLike.buttons[AccessibilityIdentifier.likeButtonOn].tap()

        sleep(2)

        cellToLike.tap()

        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons[AccessibilityIdentifier.navBackButtonWhite]
        navBackButtonWhiteButton.tap()
    }

    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()

        XCTAssertTrue(app.staticTexts[profileName].exists)
        XCTAssertTrue(app.staticTexts[profileLogin].exists)

        app.buttons[AccessibilityIdentifier.logoutButton].tap()

        app.alerts[Alert.logoutTitle].scrollViews.otherElements.buttons[Alert.confirmButton].tap()

        XCTAssertTrue(app.buttons[AccessibilityIdentifier.authenticateButton].waitForExistence(timeout: 5))
    }
}
