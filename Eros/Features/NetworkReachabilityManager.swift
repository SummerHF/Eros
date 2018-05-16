//  NetworkReachabilityManager.swift
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

#if !os(watchOS)

/// 网络状况处理

import Foundation
import SystemConfiguration

/// `NetworkReachablityManager`类监听WWAN和WiFi网络接口的主机和地址的可达性变更。
/// `Reachablity`可以用来辅助判断网络失败的原因(是否没网,etc...), 或者当网络重连的时候重发请求
///  它不应该用于阻止用户发起网络请求，因为可能需要一个初始请求来建立可达性。
open class NetworkReachablityManager {

    /// 网络可达性的各种状态

    /// - unknown: 不清楚网络是否可以访问
    /// - notReachable: 网络不可以访问
    /// - reachable: 网络可以访问
    public enum NetworkReachabilityStatus {
        case unknown
        case notReachable
        case reachable(ConnectionType)
    }

    /// 根据可达性标示来判断网络连接类型

    /// - ethernetOrWifi: 光纤或者WiFi
    /// - wwan: 无线广域网（蜂窝流量）
    public enum ConnectionType {
        case ethernetOrWifi
        case wwan
    }

    /// 参数为网络可达性状态的block, 该block在网络状态发生改变的时候执行
    public typealias Listener = (NetworkReachabilityStatus) -> Void

    // MARK: - Properties

//    open var isReachable: Bool { return }
//    open var isReachableOnWWAN: Bool { return networkReachabilityStatus == .reachable(.wwan)}

//    open var isReachableOnEthernetOrWifi: Bool

    /// 当前网络状态
    open var networkReachabilityStatus: NetworkReachabilityStatus {
        guard let flags = self.flags else { return .unknown }
        return networkReachabilityStatusForFlags(flags)
    }

    /// 执行`Listener`闭包的队列, 默认`main`
    open var listenerQueue: DispatchQueue = DispatchQueue.main

    /// allows an application to determine the status of a system's current network configuration and the reachability of a target host
    private let reachability: SCNetworkReachability
    open var previousFlags: SCNetworkReachabilityFlags

    open var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            return flags
        }
        return nil
    }

    // MARK: - init

    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil}
        self.init(reachability: reachability)
    }

    public convenience init?() {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        guard let reachability = withUnsafePointer(to: &address, { pointer in
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                return SCNetworkReachabilityCreateWithAddress(nil, &0)
            }
        }) else {
            return nil
        }
        self.init(reachability: reachability)
    }

    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
        self.previousFlags = SCNetworkReachabilityFlags()
    }

    /// 网络状态 `.notReachable`, `.ethernetOrWifi`, `.wwan`
    func networkReachabilityStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkReachabilityStatus {
        guard isNetworkReachable(with: flags) else { return .notReachable }
        var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWifi)
        #if os(iOS)
        if flags.contains(.isWWAN) { networkStatus = .reachable(.wwan)}
        #endif
        return networkStatus
    }

    /// 网络是否可达
    func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
}

#endif
