//
//  Asyncs.swift
//  ClassicTabBarUsingDemo
//
//  Created by aa on 2025/12/2.
//

import Foundation

struct Asyncs {
    public typealias BaseTask = () -> Void
    public typealias DelayTask = (_ isCancelled: Bool) -> Void
    
    /// 异步执行
    public static func async(_ task: @escaping BaseTask) {
        _async(task)
    }
    
    /// 异步执行+主队列回调
    public static func async(_ task: @escaping BaseTask, mainTask: @escaping BaseTask) {
        _async(task, mainTask)
    }
    
    /// 返回主队列执行
    public static func main(_ task: @escaping BaseTask) {
        DispatchQueue.main.async(execute: task)
    }
    
    /// 主队列延时执行
    @discardableResult
    public static func mainDelay(
        _ seconds: Double,
        _ task: @escaping BaseTask
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        return item
    }
    
    /// 异步延时执行
    @discardableResult
    public static func asyncDelay(
        _ seconds: Double,
        _ task: @escaping BaseTask
    ) -> DispatchWorkItem {
        _asyncDelay(seconds, task)
    }
    
    /// 异步延时执行+主队列回调（不管任务是否中途被取消，都会【主队列回调】）
    @discardableResult
    public static func asyncDelay(
        _ seconds: Double,
        _ task: @escaping BaseTask,
        mainTask: @escaping BaseTask
    ) -> DispatchWorkItem {
        _asyncDelay(seconds, task, mainTask)
    }
    
    /// 异步延时执行+主队列回调（不管任务是否中途被取消都会【主队列回调】，带 isCancelled 参数）
    @discardableResult
    public static func asyncDelay(
        _ seconds: Double,
        _ task: @escaping BaseTask,
        mainTask: @escaping DelayTask
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        item.notify(queue: DispatchQueue.main) {
            mainTask(item.isCancelled)
        }
        return item
    }
}

private extension Asyncs {
    static func _async(_ task: @escaping BaseTask, _ mainTask: BaseTask? = nil) {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().async(execute: item)
        if let mainTask {
            item.notify(queue: DispatchQueue.main, execute: mainTask)
        }
    }
    
    static func _asyncDelay(
        _ seconds: Double,
        _ task: @escaping BaseTask,
        _ mainTask: BaseTask? = nil
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        if let mainTask {
            item.notify(queue: DispatchQueue.main, execute: mainTask)
        }
        return item
    }
}
