//
//  JPrint.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import Foundation

#if DEBUG
import os

private let logger_subsystem = "com.zhoujianping.logger"
private let logger_category = "JPDebug"
private let logger = OSLog(subsystem: logger_subsystem, category: logger_category)

private let hhmmssSSFormatter: DateFormatter = {
    var formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = "hh:mm:ss:SS"
    return formatter
}()

private let JPrintQueue = DispatchQueue(label: "com.zhoujianping.JPrintQueue")
#endif

/// 自定义日志
func JPrint(_ msg: Any..., file: NSString = #file, line: Int = #line, fn: String = #function) {
    JPrint(msg, file: file, line: line, fn: fn)
}
private func JPrint(_ msg: [Any], file: NSString = #file, line: Int = #line, fn: String = #function) {
#if DEBUG
    guard msg.count > 0 else { return }
    
    // 时间+文件位置+行数
    let date = hhmmssSSFormatter.string(from: Date()).utf8
    let prefix = "jpjpjp [\(date)]:"
    JPrintQueue.sync {
        let fullMsg = ([prefix] + msg).map { "\($0)" }.joined(separator: " ")
        os_log(.debug, log: logger, "%{public}@", fullMsg)
    }
#endif
}
