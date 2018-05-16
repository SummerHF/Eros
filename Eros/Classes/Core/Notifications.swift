//  Notifications.swift
//  Pods
//
//  Created by SummerHF on 16/05/2018.
//
//
//  Copyright (c) 2018 SummerHF(https://github.com/summerhf)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// 通知别名
extension NSNotification.Name {

    /// 与`URLSessionTask`相关通知的命名空间
    public struct Task {
        /// 当一个`URLSessionTask`任务恢复的时候发送`didResume`通知. 通知对象会包含这个`URLSessionTask`.
        public static let DidResume = NSNotification.Name(rawValue: "org.eros.notification.name.task.didResume")
        /// 当一个`URLSessionTask`任务挂起的时候发送`didSuspend`通知. 通知对象会包含这个`URLSessionTask`.
        public static let DidSuspend = NSNotification.Name(rawValue: "org.eros.notification.name.task.didSuspend")
        /// 当一个`URLSessionTask`任务取消的时候发送`didCancel`通知. 通知对象会包含这个`URLSessionTask`.
        public static let DidCancel = NSNotification.Name(rawValue: "org.eros.notification.name.task.didCancel")
        /// 当一个`URLSessionTask`任务完成的时候发送`didComplete`通知. 通知对象会包含这个`URLSessionTask`.
        public static let DidComplete = NSNotification.Name(rawValue: "org.eros.notification.name.task.didComplete")
    }
}

extension Notification {
    /// 所有通知用户消息相关字典的`key`的命名空间
    public struct Key {
        /// 通知相关,对应于`URLSessionTask`的键
        public static let Task = "org.eros.notification.key.task"
        /// 通知相关,对应于`responseData`的键
        public static let ResponseData = "org.eros.notification.key.responseData"
    }
}
