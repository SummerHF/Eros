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

        var certificates = [SecCertificate]()
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

    
}

/// 负责管理`ServerTrustPolicy`对象到给定主机的映射
open class ServerTrustPolicyManager {

}
