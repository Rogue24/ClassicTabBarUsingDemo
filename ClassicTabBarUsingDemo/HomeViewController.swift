//
//  HomeViewController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class HomeViewController: BaseViewController {
    let index: Int
    
    private let bgImgView = UIImageView()
    
    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
        switch index {
        case 0: title = "视频云"
        case 1: title = "频道"
        case 2: title = "直播间"
        default: title = "我的"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // -------- 设置大标题及普通标题 --------
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .shadow: {
                let shadow = NSShadow()
                shadow.shadowColor = UIColor(white: 0, alpha: 0.5)
                shadow.shadowOffset = .zero
                shadow.shadowBlurRadius = 5
                return shadow
            }(),
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
        ]
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.standardAppearance = appearance
        navigationItem.largeTitleDisplayMode = .always
        
        /// **联动要点1** 允许导航栏使用大标题
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // -------- 设置tableView --------
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        /// **联动要点2** 内边距调整行为是自动的
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            /// **联动要点3**  top约束通常需要设置为superview.top (也就是 view.top)，而不是 safeArea.top
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // -------- 设置背景图片 --------
        let randowIdx = Int.random(in: 0..<AllBgImgs.count)
        let image = AllBgImgs[randowIdx]
        AllBgImgs.remove(at: randowIdx)
        bgImgView.image = image
        bgImgView.contentMode = .scaleAspectFill
        /// **联动要点4** 关于导航栏联动机制的潜规则：
        /// 触发联动的`scrollView`必须是父视图中的【第一个】子视图。
        /// - 如果在`tableView`后面（底层）或者上面（顶层）加了其他子视图，联动就会失效！
//        view.insertSubview(bgImgView, at: 0)
        /// 因此将背景图放到 tableView 里面展示
        tableView.insertSubview(bgImgView, at: 0)
        
        /// ⚠️ 系统Bug：需要强制布局一下，否则`tableView.frame`一直都是0，并且可能联动失效。
        view.layoutIfNeeded()
    }
}

extension HomeViewController {
    var normalIcon: String {
        switch index {
        case 0:
            return "com_videocloud_unselect_icon"
        case 1:
            return "com_channel_unselect_icon"
        case 2:
            return "com_direct_unselect_icon"
        default:
            return "com_my_unselect_icon"
        }
    }
    
    var selectIcon: String {
        switch index {
        case 0:
            return "com_videocloud_select_icon"
        case 1:
            return "com_channel_select_icon"
        case 2:
            return "com_direct_select_icon"
        default:
            return "com_my_select_icon"
        }
    }
}

// MARK: - <UITableViewDataSource, UITableViewDelegate>
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textColor = .black
        if indexPath.row == 0 {
            cell.textLabel?.text = "Push VC"
        } else {
            cell.textLabel?.text = "Present VC"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(TempViewController(), animated: true)
        } else {
            present(TempViewController(), animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        bgImgView.frame = scrollView.bounds
    }
}
