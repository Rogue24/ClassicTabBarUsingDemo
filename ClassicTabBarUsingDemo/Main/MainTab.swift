//
//  MainTab.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/15.
//

import Foundation

enum MainTab: Int, CaseIterable {
    case videoHub = 0
    case channel = 1
    case live = 2
    case mine = 3
    
    init(index: Int) {
        switch index {
        case 0: self = .videoHub
        case 1: self = .channel
        case 2: self = .live
        case 3: self = .mine
        default:
            if index < 0 {
                self = .videoHub
            } else {
                self = .mine
            }
        }
    }
    
    var index: Int { rawValue }
    
    var title: String {
        switch self {
        case .videoHub:
            return "视频云"
        case .channel:
            return "频道"
        case .live:
            return "直播间"
        case .mine:
            return "我的"
        }
    }
    
    var normalIcon: String {
        switch self {
        case .videoHub:
            return "com_videocloud_unselect_icon"
        case .channel:
            return "com_channel_unselect_icon"
        case .live:
            return "com_direct_unselect_icon"
        case .mine:
            return "com_my_unselect_icon"
        }
    }
    
    var selectIcon: String {
        switch self {
        case .videoHub:
            return "com_videocloud_select_icon"
        case .channel:
            return "com_channel_select_icon"
        case .live:
            return "com_direct_select_icon"
        case .mine:
            return "com_my_select_icon"
        }
    }
}
