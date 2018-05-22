//  ServerTrustPolicy.swift
//  Pods
//
//  Created by SummerHF on 18/05/2018.
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

// MARK: - 服务器信任策略

/// 通过`HTTPS`安全协议与服务器建立连接的时候, `NSURLAuthenticationChallenge`通常会提供服务器信任校验.然后策略配置使用给定的一组标准来评估服务器信任，以确定服务器信任是否有效，是否应该建立连接.
///
/// 使用证书或者公钥校验连接信任可以有效的避免中间人攻击和一些其他的缺陷, 对于那些敏感的用户数据或者金融信息强烈使用`HTTPS`来与服务器交互.
///
/// - performDefaultEvaluation: 使用默认的信任策略校验连接, 同时允许你控制是否校验由`challenge`提供的主机.
///                             鼓励应用程序在生产环境中始终验证主机，
///                             以保证服务器证书链的有效性
///
/// - performRevokedEvaluation: 使用默认和撤销的服务器信任评估，允许你控制是否验证`challenge`提供的主机，
///                             以及指定用于测试撤销证书的撤销标志。 在我们的TLS
///                             测试中演示的iOS 10.1，macOS 10.12和tvOS 10.1之前，Apple平台不会
///                             自动开始对撤销的证书进行测试。 鼓励应用程序始终
///                             在生产环境中验证主机，以保证服务器证书链的有效性。
///
/// - pinCertificates:          使用固定的证书来验证服务器信任。 服务器信任是
///                             如果其中一个固定证书与其中一个服务器证书匹配，则认为该证书有效。
///                             通过验证证书链和主机，证书锁定提供了一个非常有用的方法
///                             安全的服务器信任验证形式可以减少大部分MITM攻击。
///                             鼓励应用程序始终验证主机并需要有效的证书
///                             链在生产环境中。
///
/// - pinPublicKeys:            使用固定的公钥验证服务器信任。 如果其中一个固定公钥与服务器证书公钥之一匹配，
///                             则服务器信任被认为是有效的。 通过验证证书链和主机，公钥锁定提供了一种非常安全的
///                             服务器信任验证形式，可以减少大多数MITM攻击。应用程序被鼓励始终
///                             验证主机并需要有效的证书链在生产环境中。
///
/// - disableEvaluation:        禁用所有评估，将任何服务器信任视为有效。
///
/// - customEvaluation:         使用关联的闭包来评估服务器信任的有效性
public enum ServerTrustPolicy {

    case performDefaultEvaluation(validateHost: Bool)
    case performRevokedEvaluation(validateHost: Bool, revocationFlags: CFOptionFlags)
    case pinCertificates(certificates: [SecCertificate], validateCertificateChain: Bool, validateHost: Bool)
    case pinPublicKeys(publicKeys: [SecKey], validateCertificationChain: Bool, validateHost: Bool)
    case disableEvaluation
    case customEvaluation((_ serverTrust: SecTrust, _ host: String) -> Bool)

    // MARK: - Bundle location

    /// 返回bundle中所有以`.cer`结尾的证书

    /// - parameter bundle: 包含`.cer`的bundle
    ///
    /// - return: `bundle`中所有的证书文件
    public static func certificates(in bundle: Bundle = Bundle.main) -> [SecCertificate] {

//        let ranges = [0..<3, 8..<10, 15..<17]
//        A for-in loop over 'ranges' accesses each range:
//        for range in ranges {
//            print(range)
//        }
//        Prints "0..<3"
//        Prints "8..<10"
//        Prints "15..<17"
//        Use 'joined()' to access each element of each range:
//        for index in ranges.joined() {
//            print(index, terminator: " ")
//        }
//        Prints: "0 1 2 8 9 15 16"

        var certificates: [SecCertificate] = []
        let paths = Set([".cer", ".CER", ".crt", ".CRT", ".der", ".DER"].map { fileExtension in
            bundle.paths(forResourcesOfType: fileExtension, inDirectory: nil)
        }.joined())
        for path in paths {
            if let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) as CFData ,
               let certificate = SecCertificateCreateWithData(nil, certificateData) {
                certificates.append(certificate)
            }
        }
        return certificates
    }

    // MARK: - Bundle location

    /// 通过搜索以`.cer`结尾的文件, 返回bundle中所有公钥

    /// - parameter bundle: 包含`.cer`的bundle
    ///
    /// - return: `bundle`中的公钥
    public static func publicKeys(in bundle: Bundle = Bundle.main) -> [SecKey] {
        var publicKeys: [SecKey] = []
        for certificate in certificates(in: bundle) {
            if let publicKey = publicKey(for: certificate) {
                publicKeys.append(publicKey)
            }
        }
        return publicKeys
    }


    // MARK: - Evaluation

    /// 验证给定域名的服务器信任情况

    /// - parameter serverTrust: 鉴定信任情况
    /// - parameter forHost: 域名
    public func evaluate(_ serverTrust: SecTrust, forHost host: String) -> Bool {
        var serverTrustIsValid = false
        switch self {
        case let .performDefaultEvaluation(validateHost):
            let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
            SecTrustSetPolicies(serverTrust, policy)
            serverTrustIsValid = trustIsValid(serverTrust)
        case let .performRevokedEvaluation(validateHost, revocationFlags):
            let defaultPolicy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
            let revokedPolicy = SecPolicyCreateRevocation(revocationFlags)
            SecTrustSetPolicies(serverTrust, [defaultPolicy, revokedPolicy] as CFTypeRef)
            serverTrustIsValid = trustIsValid(serverTrust)
        case let .pinCertificates(certificates, validateCertificateChain, validateHost):
            if validateCertificateChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, policy)
                SecTrustSetAnchorCertificates(serverTrust, certificates as CFArray)
                SecTrustSetAnchorCertificatesOnly(serverTrust, true)
                serverTrustIsValid = trustIsValid(serverTrust)
            } else {
                let serverCertificationesDataArray = certificateData(for: serverTrust)
                let pinnedCertificationesDataArray = certificateData(for: certificates)
                /// 验证证书合法性
                outerLoop: for serverCertificateData in serverCertificationesDataArray {
                    for pinnedCertificateData in pinnedCertificationesDataArray {
                        if serverCertificateData == pinnedCertificateData {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case let .pinPublicKeys(publicKeys, validateCertificationChain, validateHost):
            var certificateChainEvaluationPassed = true
            if validateCertificationChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, policy)
                certificateChainEvaluationPassed = trustIsValid(serverTrust)
            }
            if certificateChainEvaluationPassed {
                outerLoop: for serverPublicKey in ServerTrustPolicy.publicKey(for: serverTrust) as [AnyObject] {
                    for publicKey in publicKeys as [AnyObject] {
                        if serverPublicKey.isEqual(publicKey) {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case .disableEvaluation:
            serverTrustIsValid = true
        case let .customEvaluation(closure):
            serverTrustIsValid = closure(serverTrust, host)
        }
        return serverTrustIsValid
    }


    // MARK: - Certificate Data

    private func certificateData(for trust: SecTrust) -> [Data] {
        var certificates: [SecCertificate] = []
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }
        return certificateData(for: certificates)
    }

    private func certificateData(for certificates: [SecCertificate]) -> [Data] {
        return certificates.map { SecCertificateCopyData($0) as Data}
    }

    // MARK: - Private trust validation

    /// 信任是否有效
    private func trustIsValid(_ trust: SecTrust) -> Bool {
        var isValid = false
        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(trust, &result)
        if status == errSecSuccess {
            let unspecified = SecTrustResultType.unspecified
            let proceed = SecTrustResultType.proceed
            isValid = result == unspecified || result == proceed
        }
        return isValid
    }

    // MARK: - Private publicKey Extension

    /// `SecCertificate` to `SecKey`
    /// 通过证书获取公钥
    private static func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        /// Returns a policy object for the default X.509 policy
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        if  let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        return publicKey
    }

    private static func publicKey(for trust: SecTrust) -> [SecKey] {
        var publicKeys: [SecKey] = []
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index),
            let publicKey = publicKey(for: certificate) {
                publicKeys.append(publicKey)
            }
        }
        return publicKeys
    }
}

/// 负责管理`ServerTrustPolicy`对象到给定主机的映射
open class ServerTrustPolicyManager {
    /// 指定域名的信任管理映射
    open let politicis: [String: ServerTrustPolicy]

    /// 初始化方法

    /// 通过指定的信任策略实例化`ServerTrustPolicyManager`
    /// - parameter politicis: 信任策略字典
    /// - returns: `ServerTrustPolicyManager` 实例
    public init(politicis: [String: ServerTrustPolicy]) {
        self.politicis = politicis
    }

    /// 通过指定域名返回信任策略
    /// - parameter host: 域名
    /// - returns: 服务器信任策略
    open func serverTrustPolicy(forhost host: String) -> ServerTrustPolicy? {
        return politicis[host]
    }
}

// MARK: - URLSession Extensions

/// 为`URLSession`拓展一个`serverTrustPolicyManager`属性
extension URLSession {
    private struct AssociatedKeys {
        static var managerKey = "URLSession.ServerTrustPolicyManager"
    }

    var serverTrustPolicyManager: ServerTrustPolicyManager? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.managerKey) as? ServerTrustPolicyManager
        }
        set (manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.managerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
