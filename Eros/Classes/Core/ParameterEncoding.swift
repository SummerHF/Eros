//  ParameterEncoding.swift
//  Pods
//
//  Created by SummerHF on 23/05/2018.
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

/// 参数编码
import Foundation

/// HTTP method 定义
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
public enum HTTPMethod: String {
    /// Describe the communication options for the target resource
    case options = "OPTIONS"
    /// Transfer a current representation of the target resource.
    case get     = "GET"
    /// Same as GET, but only transfer the status line and header section.
    case head    = "HEAD"
    /// Perform resource-specific processing on the request payload.
    case post    = "POST"
    /// Replace all current representations of the target resource with the request payload.(更新)
    case put     = "PUT"
    /// 部分更新
    case patch   = "PATCH"
    /// Remove all current representations of the target resource.
    case delete  = "DELETE"
    /// Perform a message loop-back test along the path to the target resource
    case trace   = "TRACE"
    /// Establish a tunnel to the server identified by the target resource.
    case connect = "CONNECT"
}

// MARK: - 构造URLRequest

/// 应用到`URLRequest`上的参数字典
public typealias Parameters = [String: Any]

/// 用于定义如何将一组参数应用于“URLRequest”的类型
public protocol ParameterEncoding {

    /// 通过参数构建URL request
    ///
    /// - parameter urlRequest: the url request
    /// - parameter parameters: 
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest
}


