//
//  WLTabBar+.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/15.
//

import UIKit

extension WLTabBar {
    func addItem(for homeVC: HomeViewController) {
        let tab = homeVC.myTab
        addItem(withTitle: tab.title,
                normalIcon: tab.normalIcon,
                selectIcon: tab.selectIcon,
                index: tab.index)
    }
}
