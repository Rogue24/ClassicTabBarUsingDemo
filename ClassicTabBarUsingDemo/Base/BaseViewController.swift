//
//  BaseViewController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class BaseViewController: UIViewController {
    
    /// 自定义TabBar的展示容器
    private let tabBarContainer: TabBarContainer? = {
        guard Env.isUsingLiquidGlassUI else { return nil }
        return TabBarContainer()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tabBarContainer else { return }
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarContainer)
        NSLayoutConstraint.activate([
            tabBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarContainer.heightAnchor.constraint(equalToConstant: Env.tabBarFullH)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let tabBarContainer else { return }
        view.bringSubviewToFront(tabBarContainer)
    }
    
    func addTabBar(_ tabBar: UIView) {
        guard let tabBarContainer else { return }
        tabBar.superview?.isUserInteractionEnabled = false
        tabBarContainer.addSubview(tabBar)
        tabBarContainer.isUserInteractionEnabled = true
    }
    
}
