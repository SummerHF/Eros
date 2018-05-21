//  Timeline.swift
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

/// 负责计算“请求”的完整生命周期的时间指标
public struct Timeline {
    /// 请求发起的时间(absolute reference date of 1 Jan 2001 00:00:00 GMT)
    public let requestStartTime: CFAbsoluteTime
    /// 当发送或者接受到第一个字节的时候的时间
    public let initialResponseTime: CFAbsoluteTime
    /// 当请求结束的时候的时间
    public let requestCompletedTime: CFAbsoluteTime
    /// 当请求序列化解析完毕的时候的时间
    public let serializationCompletedTime: CFAbsoluteTime
    /// 请求发起到服务器第一次响应所花费的时间(s)
    public let latency: TimeInterval
    /// 请求发起到请求结束所花费的时间
    public let requestDuration: TimeInterval
    /// 请求结束后序列化解析所花费的时间
    public let serializationDuration: TimeInterval
    /// 整个过程所花费的时间(包括序列化解析)
    public let totalDuration: TimeInterval


    public init(
        requestStartTime: CFAbsoluteTime = 0.0,
        initialResponseTime: CFAbsoluteTime = 0.0,
        requestCompletedTime: CFAbsoluteTime = 0.0,
        serializationCompletedTime: CFAbsoluteTime = 0.0
        ) {
        self.requestStartTime = requestStartTime
        self.initialResponseTime = initialResponseTime
        self.requestCompletedTime = requestCompletedTime
        self.serializationCompletedTime = serializationCompletedTime

        /// 潜伏的时间 = 收到第一个字节的时间减去请求发起的时间
        self.latency = initialResponseTime - requestStartTime
        /// 请求花费的时间 = 请求发起 - 请求结束
        self.requestDuration = requestCompletedTime - requestStartTime
        /// 序列化话费的时间 = 序列化完成时候的时间 - 请求结束的时候的时间
        self.serializationDuration = serializationCompletedTime - requestCompletedTime
        /// 整个过程花费的时间 = 序列化完成时候的时间 - 请求发起的时候的时间
        self.totalDuration = serializationCompletedTime - requestStartTime
    }
}


/**
 推荐在类方法当中都实现这两个协议`CustomStringConvertible`, `CustomDebugStringConvertible`协议, 都调试大有裨益
 */

// MARK: - CustomStringConvertible

extension Timeline: CustomStringConvertible {
    /// 描述信息包含一条请求的每个过程所花费的时间：`潜伏期过程时间`, `请求过程时间`, `序列化过程时间`, `整个过程时间`
    public var description: String {
        let latency = String(format: "%.3f", self.latency)
        let requestDuration = String(format: "%.3f", self.requestDuration)
        let serializationDuration = String(format: "%.3f", self.serializationDuration)
        let totalDuration = String(format: "%.3f", self.totalDuration)

        let timings = [
            "\"Latency\": " + latency + " secs",
            "\"RequestDuration\": " + requestDuration + " secs",
            "\"SerializationDuration\": " + serializationDuration + " secs",
            "\"TotalDuration\": " + totalDuration + " secs",
        ]
        return "Timeline: {" + timings.joined(separator: ",") + "}"
    }
}

// MARK: - CustomDebugStringConvertible

extension Timeline: CustomDebugStringConvertible {
    /// 描述信息包含一条请求的每个结点所花费的时间：`请求开始时间`, `第一次收到响应时间`, `请求结束时间`,`序列化解析结束时间`,`潜伏期过程时间`, `请求过程时间`, `序列化过程时间`, `整个过程时间`, 不推荐直接调用该方法.
    /// Calling this property directly is discouraged. Instead, convert an instance of any type to a string by using the `String(reflecting:)` initializer.

    public var debugDescription: String {
        let requestStartTime = String(format: "%.3f", self.requestStartTime)
        let initialResponseTime = String(format: "%.3f", self.initialResponseTime)
        let requestCompletedTime = String(format: "%.3f", self.requestCompletedTime)
        let serializationCompletedTime = String(format: "%.3f", self.serializationCompletedTime)
        let latency = String(format: "%.3f", self.latency)
        let requestDuration = String(format: "%.3f", self.requestDuration)
        let serializationDuration = String(format: "%.3f", self.serializationDuration)
        let totalDuration = String(format: "%.3f", self.totalDuration)

        let timings = [
            "\"Request Start Time\": " + requestStartTime + " secs",
            "\"Initial Response Time\": " + initialResponseTime + " secs",
            "\"Request Completed Time\": " + requestCompletedTime + " secs",
            "\"Serialization Completed Time\": " + serializationCompletedTime + " secs",
            "\"Latency\": " + latency + " secs",
            "\"RequestDuration\": " + requestDuration + " secs",
            "\"SerializationDuration\": " + serializationDuration + " secs",
            "\"TotalDuration\": " + totalDuration + " secs",
            ]
        return "Timeline: {" + timings.joined(separator: ",") + "}"
    }
}

