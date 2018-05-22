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

/// - invalidURL:                        当遵循`URLConvertible`协议的类型不能转化为一个合法的`URL`时, 抛出该异常
/// - parameterEncodingFailed:           参数编码失败
/// - multipartEncodingFailed:           组件部分编码失败
/// - responseValidationFailed:          返回值验证失败
/// - responseSerializationFailed:       返回值序列化失败
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
        case unacceptableContentType(acceptableContentTypes: [String], responseContentTypes: String)
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

extension Error {
    var underlyingAdaptError: Error? { return (self as? AdaptError)?.error }
}

// MARK: - Error Booleans

extension AFError {
    /// whether `AFError` is an invalid URL error.
    public var isInvalidURLError: Bool {
        if case .invalidURL = self { return true }
        return false
    }

    /// whether `AFError` is parameterEncoding error.
    /// contain the associated value
    public var isParameterEncodingError: Bool {
        if case .parameterEncodingFailed = self { return true }
        return false
    }

    /// whether `AFError` is multipartEncoding error.
    /// will contain the associated value
    public var isMultipartEncodingError: Bool {
        if case .multipartEncodingFailed = self { return true }
        return false
    }

    /// whether `AFError` is responseValidation error.
    /// will contain the associated value
    public var isResponseValidationError: Bool {
        if case .responseValidationFailed = self { return true }
        return false
    }

    /// whether `AFError` is responseSerialization error.
    /// will contain the associated value
    public var isResponseSerializationError: Bool {
        if case .responseSerializationFailed = self { return true }
        return false
    }
}

// MARK: - Convenience Properties

extension AFError {

    /// The `URLConvertible` associated with the Error
    public var urlConvertible: URLConvertible? {
        switch self {
        case .invalidURL(let url):
            return url
        default:
            return nil
        }
    }

    /// The `URL` associated with the error
    public var url: URL? {
        switch self {
        case .multipartEncodingFailed(let reason):
            return reason.url
        default:
            return nil
        }
    }

    /// the `Error` returned by a system framework asssoicated with a
    /// `.parameterEncodingFailed`, `.multipartEncodingFailed`, `.responseSerializationFailed` error.
    public var underlyingError: Error? {
        switch self {
        case .parameterEncodingFailed(let reason):
            return reason.underlyingError
        case .multipartEncodingFailed(let reason):
            return reason.underlyingError
        case .responseSerializationFailed(let reason):
            return reason.underlyingError
        default:
            return nil
        }
    }

    /// `acceptableContentTypes` of a `.responseValidationFailed` error
    public var acceptableContentTypes: [String]? {
        switch self {
        case .responseValidationFailed(let reason):
            return reason.acceptableContentTypes
        default:
            return nil
        }
    }

    /// `responseContentType` of a `.responseValidationFailed` error
    public var responseContentType: String? {
        switch self {
        case .responseValidationFailed(let reason):
            return reason.responseContentType
        default:
            return nil
        }
    }

    /// `responseCode` of a `.responseValidationFailed` error
    public var responseCode: Int? {
        switch self {
        case .responseValidationFailed(let reason):
            return reason.responseCode
        default:
            return nil
        }
    }

    public var failedStringEncoding: String.Encoding? {
        switch self {
        case .responseSerializationFailed(let reason):
            return reason.failedStringEncoding
        default:
            return nil
        }
    }
}

// MARK: - AFError.MultipartEncodingFailureReason

extension AFError.MultipartEncodingFailureReason {

    var url: URL? {
        switch self {
        case .bodyPartURLInvalid(let url), .bodyPartFilenameInvalid(let url),
             .bodyPartFileNotReachable(let url), .bodyPartFileNotReachableWithError(let url, _),
             .bodyPartFileIsDirectory(let url), .bodyPartFileSizeNotAvailable(let url),
             .bodyPartFileSizeQueryFailedWithError(let url, _), .bodyPartInputStreamCreateFailed(let url),
             .outPutStreamCreationFailed(let url), .outPutStreamFileAlreadyExists(let url),
             .outPutStreamURLInvalid(let url):
        return url
        default:
            return nil
        }
    }

    var underlyingError: Error? {
        switch self {
        case .bodyPartFileNotReachableWithError(_ , let error), .bodyPartFileSizeQueryFailedWithError(_, let error),
             .outPutStreamWriteFailed(let error), .inputStreamReadFailed(let error):
            return error
        default:
            return nil
        }
    }
}

// MARK: - AFError.ParameterEncodingFailureReason

extension AFError.ParameterEncodingFailureReason {

    var underlyingError: Error? {
        switch self {
        case .jsonEncodingFailed(let error), .propertyListEncodingFailued(let error):
            return error
        default:
            return nil
        }
    }
}

// MARK: - AFError.ResponseSerializationFailureReason

extension AFError.ResponseSerializationFailureReason {

    public var failedStringEncoding: String.Encoding? {
        switch self {
        case .stringSerializationFailed(let encoding):
            return encoding
        default:
            return nil
        }
    }

    public var underlyingError: Error? {
        switch self {
        case .jsonSerializaitonFailed(let error), .propertyListSerialization(let error):
            return error
        default:
            return nil
        }
    }
}

// MARK: - AFError.ResponseValidationFailureReason

extension AFError.ResponseValidationFailureReason {

    /// acceptableContentTypes
     var acceptableContentTypes: [String]? {
        switch self {
        case .missingContentType(let types), .unacceptableContentType(let types, _):
            return types
        default:
            return nil
        }
    }
    /// responseContentType
     var responseContentType: String? {
        switch self {
        case .unacceptableContentType(_, let responseType):
            return responseType
        default:
            return nil
        }
    }
    /// responseCode
    var responseCode: Int? {
        switch self {
        case .unacceptableStatusCode(let code):
            return code
        default:
            return nil
        }
    }
}

// MARK: - Error Descriptions

extension AFError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "URL is not valid: \(url)"
        case .parameterEncodingFailed(let reason):
            return reason.localizedDescription
        case .multipartEncodingFailed(let reason):
            return reason.localizedDescription
        case .responseValidationFailed(let reason):
            return reason.localizedDescription
        case .responseSerializationFailed(let reason):
            return reason.localizedDescription
        }
    }
}

extension AFError.ParameterEncodingFailureReason {
    var localizedDescription: String {
        switch self {
        case .missingURL:
            return "eros-> URL Request to encode was missing a `URL`"
        case .jsonEncodingFailed(let error):
            return "eros-> Json could not be encoded because of error:\n \(error.localizedDescription)"
        case .propertyListEncodingFailued(let error):
            return "eros-> PropertyList could not be encoded because of error:\n \(error.localizedDescription)"
        }
    }
}

extension AFError.MultipartEncodingFailureReason {
    var localizedDescription: String {
        switch self {
        case .bodyPartURLInvalid(let url):
            return "eros-> The URL provided is not a file URL: \(url)"
        case .bodyPartFilenameInvalid(let url):
            return "eros-> The URL provided does not have a valid fileName: \(url)"
        case .bodyPartFileNotReachable(let url):
            return "eros-> The URL provided is not reachable: \(url)"
        case .bodyPartFileNotReachableWithError(let url, let error):
            return "eros-> The system returned an error while checking the provided URL for" +
            "reachablity.\nURL:\(url)\nError:\(error)"
        case .bodyPartFileIsDirectory(let url):
            return "eros-> The URL provided is a directory: \(url)"
        case .bodyPartFileSizeNotAvailable(let url):
            return "eros-> Could not fetch the file size from the provided URL: \(url)"
        case .bodyPartFileSizeQueryFailedWithError(let url, let error):
            return (
                "eros-> The system returned an error while attempting to fetch the file size from the " + "provided URL.\nURL:\(url)\n Error:\(error)"
            )
        case .bodyPartInputStreamCreateFailed(let url):
            return "eros-> Failed to create an InputStream for the provided URL: \(url)"
        case .outPutStreamCreationFailed(let url):
            return "eros-> Failed to create an OutputStream for the provided URL: \(url)"
        case .outPutStreamFileAlreadyExists(let url):
            return "eros-> A file already exists at the provided URL: \(url)"
        case .outPutStreamWriteFailed(let error):
            return "eros-> OutputStream write failed with the error: \(error)"
        case .inputStreamReadFailed(let error):
            return "eros-> InputStream read failed with the error: \(error)"
        case .outPutStreamURLInvalid(let url):
            return "eros-> The provided OutputStream URL is invalid: \(url)"
       }
    }
}

extension AFError.ResponseSerializationFailureReason {
    var localizedDescription: String {
        switch self {
        case .inputDataNil:
            return "eros-> Response could not be serialized, input data was nil."
        case .inputDataNilOrZeroLength:
            return "eros-> Response could not be serialized, input data was nil or zero length."
        case .inputFileNil:
            return "eros-> Response could not be serialized, input file was nil."
        case .inputFileReadFailed(let url):
            return "eros-> Response could not be serialized, input file could not be read at: \(url)."
        case .stringSerializationFailed(let encoding):
            return "eros-> String could not be serialized with encoding: \(encoding)."
        case .jsonSerializaitonFailed(let error):
            return "eros-> JSON could not be serialized with error: \(error.localizedDescription)"
        case .propertyListSerialization(let error):
            return "eros-> Property list serialized with error: \(error.localizedDescription)"
        }
    }
}

extension AFError.ResponseValidationFailureReason {
    var localizedDescription: String {
        switch self {
        case .dataFileNil:
            return "eros-> Response could not be validated, data file was nil."
        case .dataFileReadFailed(let url):
            return "eros-> Response could not be validated, data file could not be read at: \(url)"
        case .missingContentType(let types):
            return (
                "eros-> Response Content-Type was missing and acceptable content types " +
                "(\(types.joined(separator: ","))) do not match \"*/*\"."
            )
        case .unacceptableContentType(let acceptableContentTypes, let responseContentTypes):
            return (
                "eros-> Response Content-Type\"(\(responseContentTypes))\" does not suitable for any acceptable Content-Type:" +
                "\(acceptableContentTypes.joined(separator: ","))."
            )
        case .unacceptableStatusCode(let code):
            return "eros-> Response status code was unacceptable: \(code)."
        }
    }
}




