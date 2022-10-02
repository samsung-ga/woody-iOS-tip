//
//  SceneDelegate.swift
//  ReactorKitSample
//
//  Created by Woody on 2022/08/04.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let root = PulseViewController()
        root.reactor = PulseReactor()
        window.rootViewController = root

        self.window = window
        window.makeKeyAndVisible()
    }
}
