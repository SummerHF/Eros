//  AFError.swift
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

///`AFError` 是`Eros`的错误类型集合, 包含一系列的错误信息以及错误原因.

/// - invalidURL:         当遵循`URLConvertible`协议的类型不能转化为一个合法的`URL`时, 抛出该异常

public enum AFError: Error {

    /// 参数编码错误时抛出下列异常
    ///
    /// - missingURL: 没有url
    /// - jsonEncodingFailed: json序列化错误
    /// - propertyListEncodingFailued: 参数列表序列化错误
    ///
    public enum ParameterEncodingFailureReason {
        case missingURL
        case jsonEncodingFailed(error: Error)
        case propertyListEncodingFailued(error: Error)
    }

    /// 多种可能的编码错误
    ///
    /// - bodyPartURLInvalid: `URL` for `encoding body part` is not invalidate.
    ///
    /// - bodyPartFilenameInvalid: `Filename` of `fileURL` has empty `lastPathComponent` or `pathExtension`.
    ///
    /// - bodyPartFileNotReachable: `File` in `fileURL` not reachable.
    ///
    /// - bodyPartFileNotReachableWithError: Attempt check file with `fileURL` throw an error
    ///
    /// - bodyPartFileIsDirectory: 根据`fileURL`得到的是一个目录
    ///
    /// - bodyPartFileSizeNotAvailable: 根据`fileURL`得到的文件的大小系统并未返回
    ///
    /// - bodyPartFileSizeQueryFailedWithError: 根据`fileURL`计算文件的大小抛出错误
    ///
    /// - bodyPartInputStreamCreateFailed: an `InputStream` couldn't create by `fileURL`
    ///
    /// - outPutStreamCreationFailed: an `OutputStream` couldn't create by `fileURL`
    ///
    /// - outPutStreamFileAlreadyExists: an `OutputStream` already exits in `fileURL`
    ///
    /// - outPutStreamURLInvalid: a `filrURL` provided for writing data to disk is invalidate
    ///
    /// - outPutStreamWriteFailed: write encoded data to disk failure and throw an error
    ///
    /// - inputStreamReadFailed: read an encoded data part `InputStream` failed with underlying system error
    public enum MultipartEncodingFailureReason {
        case bodyPartURLInvalid(url: URL)
        case bodyPartFilenameInvalid(in: URL)
        case bodyPartFileNotReachable(at: URL)
        case bodyPartFileNotReachableWithError(atURL: URL, error: Error)
        case bodyPartFileIsDirectory(at: URL)
        case bodyPartFileSizeNotAvailable(at: URL)
        case bodyPartFileSizeQueryFailedWithError(forURL: URL, error: Error)
        case bodyPartInputStreamCreateFailed(for: URL)
        case outPutStreamCreationFailed(for: URL)
        case outPutStreamFileAlreadyExists(at: URL)
        case outPutStreamURLInvalid(url: URL)
        case outPutStreamWriteFailed(error: Error)
        case inputStreamReadFailed(error: Error)
    }

    /// 潜在的返回验证错误
    /// - dataFileNil: the data file contain server response doesn't exit
    ///
    /// - dataFileReadFailed: the data file contain server response read failure
    ///
    /// - missingContentType: 没有包含`ContentType`
    ///
    /// - unacceptableContentType: 不能被处理的`ContentType`
    ///
    /// - unacceptableStatusCode: 错误的`StatusCode`
    public enum ResponseValidationFailureReason {
        case dataFileNil
        case dataFileReadFailed(at: URL)
        case missingContentType(acceptableContentTypes: [String])
        case unacceptableContentType(acceptableContentTypes: [String], responseContentTypes: [String])
        case unacceptableStatusCode(code: Int)
    }

    public enum ResponseSerializationFailureReason {
        case inputDataNil
        case inputDataNilOrZeroLength
        case inputFileNil
        case inputFileReadFailed(at: URL)
        case stringSerializationFailed(encoding: String.Encoding)
        case jsonSerializaitonFailed(error: Error)
        case propertyListSerialization(error: Error)
    }

    case invalidURL(url: URLConvertible)
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    case multipartEncodingFailed(reason: MultipartEncodingFailureReason)
    case responseValidationFailed(reason: ResponseValidationFailureReason)
    case responseSerializationFailed(reason: ResponseSerializationFailureReason)
}

// MARK: - Adapt Error

struct AdaptError: Error {
    let error: Error
}

// MARK: - Error Booleans

extension Error {
    var underlyingAdaptError: Error? { return (self as? AdaptError)?.error }
}
