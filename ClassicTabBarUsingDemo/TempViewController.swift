//
//  TempViewController.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class TempViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Temp"
        
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
        
        let image = AllBgImgs.randomElement()
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
        
        let backBtn = UIButton(type: .system)
        backBtn.setTitle("点我返回", for: .normal)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
        backBtn.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backBtn)
        NSLayoutConstraint.activate([
            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        backBtn.layer.shadowColor = UIColor.black.cgColor
        backBtn.layer.shadowOpacity = 1
        backBtn.layer.shadowRadius = 5
        backBtn.layer.shadowOffset = .zero
    }
    
    @objc private func goBackAction() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
