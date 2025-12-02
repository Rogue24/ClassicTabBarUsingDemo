//
//  BaseNavigationController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

}
