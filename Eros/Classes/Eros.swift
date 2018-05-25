//  Eros.swift
//  Pods
//
//  Created by SummerHF on 21/05/2018.
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

// MARK: - Is valid `URL`

/// 遵循该协议的类型需要构造URLs
public protocol URLConvertible {
    /// 返回一个遵循`RFC 2396`的`URL`或者抛出一个`Error`.
    ///
    /// - throws: 如果该类型不能转换为`URL`就抛出一个异常.
    ///
    /// - returns: a url or an `Error`.
    func asURL() throws -> URL
}

extension String: URLConvertible {

    /// 为普通的String拓展转化为`URL`的方法
    /// - throws: is not a valid `URL` then throw a `AFError.invalidURL` error.
    /// - returns: a url or throw a Error
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw AFError.invalidURL(url: self)}
        return url
    }
}

extension URL: URLConvertible {
    /// return self
    public func asURL() throws -> URL { return self }
}

extension URLComponents: URLConvertible {
    /// Return a URL if `url` is not nil, otherwise throw a error.
    ///
    /// - throws: a invalid url
    /// - returns: a url or throw a error
    public func asURL() throws -> URL {
        guard let url = url else { throw AFError.invalidURL(url: self)}
        return url
    }
}


// MARK: - URLRequestConvertible

/// 遵循该协议的类型可以转化为`URLRequest`或者抛出一个异常
public protocol URLRequestConvertible {

    /// 返回一个 URL Request 或者抛出异常当遇到错误的时候
    ///
    /// - throws: 如果`URLRequest` 是 `nil`, 抛出异常
    /// - returns: A URL Request
    func asURLRequest() throws -> URLRequest
}

extension URLRequestConvertible {
    /// the URL request
    public var urlRequest: URLRequest? { return try? asURLRequest()}
}

extension URLRequest: URLRequestConvertible {
    /// Returns a URL request or throw
    public func asURLRequest() throws -> URLRequest { return self }
}

// MARK: - URLRequest Extension

/// 构造URLRequest
extension URLRequest {

    public init(url: URLConvertible, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()
        self.init(url: url)
        httpMethod = method.rawValue
        if let headers = headers {
            for (headerField, headerValue) in headers {
                setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
    }
    
}

