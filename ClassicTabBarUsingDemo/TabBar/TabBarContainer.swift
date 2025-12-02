//
//  TabBarContainer.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import UIKit

class TabBarContainer: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    // MARK: 拦截点击 => 自己不响应，触碰的子视图响应。
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 子视图从【顶层】开始遍历
        for subview in subviews.reversed() {
            // 转换为相对于子视图上的触碰点
            let subPoint = convert(point, to: subview)
            guard let rspView = subview.hitTest(subPoint, with: event) else { continue }
            return rspView
        }
        
        // 自身不响应
        return nil
    }
}
