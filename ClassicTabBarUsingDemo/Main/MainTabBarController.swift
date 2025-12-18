//
//  MainTabBarController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class MainTabBarController: UITabBarController {
    private var isSetuped = false
    private let videoHubVC = HomeViewController(.videoHub)
    private let channelVC = HomeViewController(.channel)
    private let liveVC = HomeViewController(.live)
    private let mineVC = HomeViewController(.mine)
    private let customTabBar = WLTabBar()
    
    /// 自定义TabBar的展示容器 --- 📌 iOS 26: Custom TabBar
    private var tabBarContainer: TabBarContainer? = nil
    
    /// 挪动TabBar到当前子VC的回调 --- 📌 iOS 26: Custom TabBar
    private var moveTabBarWorkItem: DispatchWorkItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var config = UIBackgroundConfiguration.listCell()
        config.backgroundColor = .clear
        config.visualEffect = UIBlurEffect(style: .systemThinMaterialLight)
        UITableViewCell.appearance().backgroundConfiguration = config
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 📌 iOS 26: Custom TabBar
        guard Env.isUsingLiquidGlassUI else { return }
        setTabBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 📌 iOS 26: Custom TabBar
        guard let tabBarContainer else { return }
        view.bringSubviewToFront(tabBarContainer)
    }
    
    override var selectedIndex: Int {
        willSet {
            guard customTabBar.selectedIndex != newValue else { return }
            guard newValue < customTabBar.tabBarItems.count else { return }
            customTabBar.selectedIndex = newValue
        }
    }
    
    // 📌 iOS 26: Custom TabBar
    func addTabBar(_ tabBar: UIView) {
        guard let tabBarContainer else { return }
        tabBar.superview?.isUserInteractionEnabled = false
        tabBarContainer.addSubview(tabBar)
        tabBarContainer.isUserInteractionEnabled = true
    }
}

// MARK: - 初始化配置
extension MainTabBarController {
    func setup() {
        guard !isSetuped else { return }
        isSetuped = true
        
        // -------- 子VC --------
        viewControllers = [
            BaseNavigationController(rootViewController: videoHubVC),
            BaseNavigationController(rootViewController: channelVC),
            BaseNavigationController(rootViewController: liveVC),
            BaseNavigationController(rootViewController: mineVC)
        ]
        
        // -------- 自定义TabBar --------
        customTabBar.addItem(for: videoHubVC)
        customTabBar.addItem(for: channelVC)
        customTabBar.addItem(for: liveVC)
        customTabBar.addItem(for: mineVC)
        customTabBar.delegate = self
        
        // -------- TabBar容器 --------
        guard Env.isUsingLiquidGlassUI else {
            tabBar.addSubview(customTabBar)
            return
        }
        
        // 📌 iOS 26: Custom TabBar
        let container = TabBarContainer()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: Env.tabBarFullH)
        ])
        tabBarContainer = container
        
        moveTabBar(from: 0, to: selectedIndex)
    }
}

// MARK: - <WLTabBarDelegate>
extension MainTabBarController: WLTabBarDelegate {
    func tabBar(_ tabBar: WLTabBar!, didSelectItemAt index: Int) {
        moveTabBar(from: selectedIndex, to: index)
        selectedIndex = index
        // 想移除系统自带的切换动画就👇🏻
//        UIView.performWithoutAnimation {
//            self.selectedIndex = index
//        }
    }
}

// MARK: - 挪动TabBar到目标子VC --- 📌 iOS 26: Custom TabBar
private extension MainTabBarController {
    func moveTabBar(from sourceIdx: Int, to targetIdx: Int) {
        guard Env.isUsingLiquidGlassUI else { return }
        
        // #1 取消上一次的延时操作
        moveTabBarWorkItem?.cancel()
        moveTabBarWorkItem = nil
        
        guard let viewControllers, viewControllers.count > 0 else {
            addTabBar(customTabBar)
            return
        }
        
        guard sourceIdx != targetIdx else {
            _moveTabBar(to: targetIdx)
            return
        }
        
        // #2 如果「当前子VC」现在不是处于栈顶，就把tabBar直接挪到「目标子VC」
        let sourceNavCtr = viewControllers[sourceIdx] as? UINavigationController
        if (sourceNavCtr?.viewControllers.count ?? 0) > 1 {
            _moveTabBar(to: targetIdx)
            return
        }
        
        // #3 能来这里说明「当前子VC」正处于栈顶，如果「目标子VC」此时也处于栈顶，就把tabBar放到层级顶部（不受系统切换动画的影响）
        let targetNavCtr = viewControllers[targetIdx] as? UINavigationController
        if (targetNavCtr?.viewControllers.count ?? 0) == 1 {
            addTabBar(customTabBar)
        } else {
            _moveTabBar(to: sourceIdx)
        }
        
        // #3.1 延迟0.5s后再放入到「目标子VC」，给VC有足够时间去初始化和显示（可完美实现旧UI的效果；中途切换会取消这个延时操作#1）
        moveTabBarWorkItem = Asyncs.mainDelay(0.5) { [weak self] in
            guard let self, self.selectedIndex == targetIdx else { return }
            self.moveTabBarWorkItem = nil
            self._moveTabBar(to: targetIdx)
        }
    }
    
    func _moveTabBar(to index: Int) {
        let tab = MainTab(index: index)
        switch tab {
        case .videoHub:
            videoHubVC.addTabBar(customTabBar)
        case .channel:
            channelVC.addTabBar(customTabBar)
        case .live:
            liveVC.addTabBar(customTabBar)
        case .mine:
            mineVC.addTabBar(customTabBar)
        }
    }
}
