//
//  HomeViewController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class HomeViewController: BaseViewController {
    
    let index: Int
    
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
    
    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
        switch index {
        case 0:
            title = "视频云"
        case 1:
            title = "频道"
        case 2:
            title = "直播间"
        default:
            title = "我的"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = title
        
        let randowIdx = Int.random(in: 0..<AllBgImgs.count)
        let image = AllBgImgs[randowIdx]
        AllBgImgs.remove(at: randowIdx)
        
        let bgImgView = UIImageView(image: image)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgImgView)
        NSLayoutConstraint.activate([
            bgImgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
}
