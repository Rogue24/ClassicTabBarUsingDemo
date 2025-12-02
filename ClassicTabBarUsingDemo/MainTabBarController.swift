//
//  MainTabBarController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        
        JPrint("safeAreaInsets", Env.safeAreaInsets)
        JPrint("statusBarH", Env.statusBarH)
        JPrint("screenSize", Env.screenSize)
        
        Asyncs.mainDelay(3) {
            JPrint("safeAreaInsets", Env.safeAreaInsets)
            JPrint("statusBarH", Env.statusBarH)
            JPrint("screenSize", Env.screenSize)
        }
    }
    
}

private extension MainTabBarController {
    func setupViewControllers() {
        let home = UINavigationController(rootViewController: UIViewController())
        let profile = UINavigationController(rootViewController: UIViewController())

        home.tabBarItem = UITabBarItem(
            title: "首页",
            image: UIImage(named: "icon_home"),
            selectedImage: UIImage(named: "icon_home_sel")
        )
        home.view.backgroundColor = .systemPink

        profile.tabBarItem = UITabBarItem(
            title: "我的",
            image: UIImage(named: "icon_profile"),
            selectedImage: UIImage(named: "icon_profile_sel")
        )
        profile.view.backgroundColor = .systemBrown

        viewControllers = [home, profile]
    }
}
