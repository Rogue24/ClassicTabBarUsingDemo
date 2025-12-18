# ClassicTabBarUsingDemo

该Demo主要演示如何在 **iOS 26** 的`UITabBarController`中使用**自定义TabBar**实现以往的显示效果（主要实现代码可搜索“📌”查看）。

<img src="https://github.com/Rogue24/JPCover/raw/master/ClassicTabBarUsingDemo/explain1.gif" width="25%">
<img src="https://github.com/Rogue24/JPCover/raw/master/ClassicTabBarUsingDemo/explain2.gif" width="25%">

***

苹果自 iOS 26 起就使用全新的UI --- Liquid Glass，导致很多系统组件也被迫强制使用，首当其冲就是`UITabBarController`，对于很多喜欢使用自定义TabBar的开发者来说，这很是无奈：

<img src="https://github.com/Rogue24/JPCover/raw/master/ClassicTabBarUsingDemo/image0.jpg" width="50%">

- *强行给你套个玻璃罩子*

那如何在 **iOS 26** 的`UITabBarController`继续使用自定义`TabBar`呢？这里介绍一下我的方案。

## 实现方案

经观察，以往`TabBar`的显示效果，个人猜测系统是把`TabBar`放到**当前子VC**的view上：

<img src="https://github.com/Rogue24/JPCover/raw/master/ClassicTabBarUsingDemo/image1.jpg" width="50%">

按照这个思路可以这么实现：

1. 首先**自定义TabBar**要使用`UIView`（如果使用的是私自改造的`UITabBar`，得换成`UIView`了），并且隐藏系统TabBar。

```swift
class MainTabBarController: UITabBarController {
    ......
    
    /// 自定义TabBar
    private let customTabBar = WLTabBar()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏系统TabBar
        setTabBarHidden(true, animated: false)
    }
    
    ......
}

```

2. 在`TabBarController`及其子VC都创建一个专门存放自定义TabBar的容器，且层级必须是**最顶层**（之后添加的子视图都得插到**TabBar容器**的下面）。

```swift
class BaseViewController: UIViewController {
    /// 专门存放自定义TabBar的容器
    private let tabBarContainer = TabBarContainer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tabBarContainer else { return }
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarContainer)
        NSLayoutConstraint.activate([
            tabBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarContainer.heightAnchor.constraint(equalToConstant: Env.tabBarFullH) // 下巴+TabBar高度
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 层级必须是最顶层
        view.bringSubviewToFront(tabBarContainer)
    }
    
    // 将自定义TabBar放到自己的TabBar容器上
    func addTabBar(_ tabBar: UIView) {
        tabBar.superview?.isUserInteractionEnabled = false
        tabBarContainer.addSubview(tabBar)
        tabBarContainer.isUserInteractionEnabled = true
    }
}
```

3. 最后，`TabBarController`当前显示哪个子VC，就把**自定义TabBar**放到对应子VC的**TabBar容器**上，这样则不会影响`push`或`present`其他VC。

OK，完事了。

## 注意点

核心实现就是以上3点，接下来讲一下注意点。

上面说到，`TabBarController`也得创建一个**TabBar容器**，这主要是用来切换子VC的：

**在切换子VC前，自定义TabBar必须先放到TabBarController的TabBar容器上，切换后再放到目标子VC的TabBar容器上。**

为什么？

一般子VC的内容都是懒加载（看到才构建），如果是很复杂的界面，不免会有卡顿的情况，如果直接把自定义TabBar丢过去，TabBar会闪烁一下，效果不太好；另外自 iOS 18 起切换子VC会带有默认的系统动画，其动画作用于子VC的view上，即便该子VC早就构建好，立马转移TabBar也会闪烁一下。

因此个人建议先把**自定义TabBar**放`TabBarController`的**TabBar容器**上（层级在所有子VC的view之上），延时一下（确保子VC完全构建好且已完全显示，同时避免被系统动画影响）再放到目标子VC的**TabBar容器**上，这样就能完美实现切换效果了。

核心代码如下：

```swift
// MARK: - 挪动TabBar到目标子VC
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
```

如果想移除系统切换动画可以这么做：

```swift
// MARK: - <WLTabBarDelegate>
extension MainTabBarController: WLTabBarDelegate {
    func tabBar(_ tabBar: WLTabBar!, didSelectItemAt index: Int) {
        moveTabBar(from: selectedIndex, to: index)
        // 想移除系统自带的切换动画就👇🏻
        UIView.performWithoutAnimation {
            self.selectedIndex = index
        }
    }
}
```

以上就是我的方案了，起码不用自定义`UITabBarController`，更加简单粗暴，更多细节可以参考Demo。

个人感觉能应付80%的应用场景吧，除非你有非常特殊的过场动画需要挪动TabBar的。当然希望苹果以后能推出兼容自定义TabBar的API，那就不用这样魔改了。
  
## Author

Rogue24, zhoujianping24@hotmail.com
