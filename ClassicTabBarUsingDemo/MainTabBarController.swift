//
//  MainTabBarController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class MainTabBarController: UITabBarController {
    let vc0 = BaseViewController()
    let vc1 = BaseViewController()
    let vc2 = BaseViewController()
    let vc3 = BaseViewController()
    
    private let customTabBar = WLTabBar()
    
    /// 自定义TabBar的展示容器
    private var tabBarContainer: TabBarContainer? = nil
    
    /// 挪动TabBar到当前子VC的回调
    private var moveTabBarWorkItem: DispatchWorkItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard Env.isUsingLiquidGlassUI else { return }
        setTabBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    func addTabBar(_ tabBar: UIView) {
        guard let tabBarContainer else { return }
        tabBar.superview?.isUserInteractionEnabled = false
        tabBarContainer.addSubview(tabBar)
        tabBarContainer.isUserInteractionEnabled = true
    }
}

// MARK: - 初始化配置
private extension MainTabBarController {
    func setupViewControllers() {
        vc0.title = "视频云"
        vc1.title = "频道"
        vc2.title = "直播间"
        vc3.title = "我的"
        
        let navCtr0 = BaseNavigationController(rootViewController: vc0)
        let navCtr1 = BaseNavigationController(rootViewController: vc1)
        let navCtr2 = BaseNavigationController(rootViewController: vc2)
        let navCtr3 = BaseNavigationController(rootViewController: vc3)
        viewControllers = [navCtr0, navCtr1, navCtr2, navCtr3]
    }
    
    func setupTabBar() {
        customTabBar.addItem(
            withTitle: vc0.title,
            normalIcon: "com_videocloud_unselect_icon",
            selectIcon: "com_videocloud_select_icon",
            index: 0
        )
        
        customTabBar.addItem(
            withTitle: vc1.title,
            normalIcon: "com_channel_unselect_icon",
            selectIcon: "com_channel_select_icon",
            index: 1
        )
        
        customTabBar.addItem(
            withTitle: vc2.title,
            normalIcon: "com_direct_unselect_icon",
            selectIcon: "com_direct_select_icon",
            index: 2
        )
        
        customTabBar.addItem(
            withTitle: vc3.title,
            normalIcon: "com_my_unselect_icon",
            selectIcon: "com_my_select_icon",
            index: 3
        )
        
        customTabBar.delegate = self
        
        guard Env.isUsingLiquidGlassUI else {
            tabBar.addSubview(customTabBar)
            return
        }
        
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
    }
}

// MARK: - 挪动TabBar到目标子VC（for iOS 26）
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
        switch index {
        case 0:
            vc0.addTabBar(customTabBar)
        case 1:
            vc1.addTabBar(customTabBar)
        case 2:
            vc2.addTabBar(customTabBar)
        default:
            vc3.addTabBar(customTabBar)
        }
    }
}


