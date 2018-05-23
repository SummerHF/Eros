//  MultipartFormData.swift
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

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif

/// 作为HTTP或者HTTPS请求的请求体, `multipart/form-data`结构的数据有两种编码方式. 一种方式是直接在内存中进行编码, 这很高效，但是对于体积较大的数据而言会导致内存问题.
/// 第二种方式是专门为那些体积较大的数据准备的. 通过边界分隔的方式将数据进行切分并存储到硬盘.
///
/// - https://www.ietf.org/rfc/rfc2388.txt
/// - https://www.ietf.org/rfc/rfc2045.txt
/// - https://www.w3.org/TR/html401/interact/forms.html#h-17.13
open class MultipartFormData {

    // MARK: - Helper Types
    /// 回车换行 标志着结束 就像字符串都会默认拼接一个NUL一样
    struct EncodingCharacters {
        static let crlf = "\r\n"
    }

    /// 边界分隔
    struct BoundaryGenerator {
        /// 边界类型
        enum BoundaryType {
            /// 头
            case initial
            /// 包裹
            case encapsulated
            /// 尾
            case final
        }

        /// 随机产生边界值 不重复 否则会导致数据错乱
        static func randomBoundary() -> String {
            /// %08x为整型以16进制方式输出的格式字符串，会把后续对应参数的整型数字，以16进制输出。08的含义为，输出的16进制值占8位，不足部分左侧补0
            return String(format: "eros.boundary.%08x%08x", arc4random(), arc4random())
        }

        /// 边界data
        /// 根据`type`和`boundary`构造``
        static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) ->Data {
            let boundaryText: String
            switch boundaryType {
            case .initial:
                boundaryText = "--\(boundary)\(EncodingCharacters.crlf)"
            case .encapsulated:
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
            case .final:
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
            }
            return boundaryText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        }
    }

    class BodyPart {
        let headers: HTTPHeaders
        let bodyStream: InputStream
        let bodyContentLength: UInt64
        var hasInitialBoundary = false
        var hasFinalBoundary = false
        init(headers: HTTPHeaders, bodyStream: InputStream, bodyContentLength: UInt64) {
            self.headers = headers
            self.bodyStream = bodyStream
            self.bodyContentLength = bodyContentLength
        }
    }

    // MARK: - Properties

    /// The `Content-Type` header value containing the boundary to generate the `multipart/form-data`
    open lazy var contentType: String = "multipart/form-data; boundary=\(self.boundary)"
    /// The content lenght of all body parts used to generate `multipart/form-data` not including `boundaries`
    public var contentLength: UInt64 { return bodyParts.reduce(0){ $0 + $1.bodyContentLength} }
    /// The boundary used to seperate the body parts in the encoded form data
    public  let boundary: String
    private var bodyParts: [BodyPart]
    private var bodyPartError: AFError?
    private let streamBufferSize: Int

    /// 创建一个`multipart/form-data`对象
    public init() {
        self.boundary = BoundaryGenerator.randomBoundary()
        self.bodyParts = []
        ///
        /// The optimal read/write buffer size in bytes for input and output streams is 1024 (1KB). For more
        /// information, please refer to the following article:
        ///   - https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Streams/Articles/ReadingInputStreams.html
        ///
        self.streamBufferSize = 1024
    }

    // MARK: - Body Parts

    /// Create a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter data: The data to encode into the multipart form data
    /// - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header
    public func append(_ data: Data, withName name: String) {
        let headers = contentHeaders(withName: name)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)
        append(stream, withLength: length, headers: headers)
    }

    /// Create a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter data: The data to encode into the multipart form data
    /// - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header
    /// - parameter mimeType: The MiME type to associated with the data content type in the `Content-type` HTTP header
    public func append(_ data: Data, withName name: String, mimeType: String) {
        let headers = contentHeaders(withName: name, mimeType: mimeType)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)
        append(stream, withLength: length, headers: headers)
    }

    /// Create a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter data: The data to encode into the multipart form data
    /// - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header
    /// - parameter fileName: The fileName to associate with the data in the `Content-Disposition` HTTP header
    /// - parameter mimeType: The MiME type to associated with the data content type in the `Content-type` HTTP header
    public func append(_ data: Data, withName name: String, fileName: String, mimeType: String) {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)
        append(stream, withLength: length, headers: headers)
    }

    /// Create a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter fileURL: The URL of data whose content will be encode into the multipart form data
    /// - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header
    public func append(_ fileURL: URL, withName name: String) {
        let fileName = fileURL.lastPathComponent
        let pathExtension = fileURL.pathExtension
        if !fileName.isEmpty && !pathExtension.isEmpty{
            let mime = mimeType(forPathExtension: pathExtension)
            append(fileURL, withName: name, fileName: fileName, mimeType: mime)
        } else {
            setBodyParhError(withReason: .bodyPartFilenameInvalid(in: fileURL))
        }
    }

    public func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String) {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
        //============================================================
        //                 Check 1 - is file URL?
        //============================================================
        /// 是否是合法路径
        guard fileURL.isFileURL else {
            setBodyParhError(withReason: .bodyPartURLInvalid(url: fileURL))
            return
        }
        //============================================================
        //                 Check 2 - is file URL reachable?
        //============================================================
        /// 路径是否可达
        do {
            let isReachable = try fileURL.checkPromisedItemIsReachable()
            guard isReachable else {
                setBodyParhError(withReason: .bodyPartFileNotReachable(at: fileURL))
                return
            }
        } catch {
            setBodyParhError(withReason: .bodyPartFileNotReachable(at: fileURL))
            return
        }
        //============================================================
        //            Check 3 - is file URL a directory?
        //============================================================
        /// 是否是目录路径
        var isDirectory: ObjCBool = false
        let path = fileURL.path
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue else {
            setBodyParhError(withReason: .bodyPartFileIsDirectory(at: fileURL))
            return
        }
        //============================================================
        //          Check 4 - can the file size be extracted?
        //============================================================
        let bodyContentLength: UInt64
        do {
            guard let fileSize = try FileManager.default.attributesOfFileSystem(forPath: path)[.size] as? NSNumber else {
                setBodyParhError(withReason: .bodyPartFileSizeNotAvailable(at: fileURL))
                return
            }
            bodyContentLength = fileSize.uint64Value
        } catch {
            setBodyParhError(withReason: .bodyPartFileSizeQueryFailedWithError(forURL: fileURL, error: error))
            return
        }
        //============================================================
        //       Check 5 - can a stream be created from file URL?
        //============================================================
        guard let stream = InputStream(url: fileURL) else {
            setBodyParhError(withReason: .bodyPartInputStreamCreateFailed(for: fileURL))
            return
        }
        append(stream, withLength: bodyContentLength, headers: headers)
    }

    /// Create a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter stream: The stream to encode into the multipart form data
    /// - parameter length: The content length of the stream
    /// - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header
    /// - parameter fileName: The fileName to associate with the data in the `Content-Disposition` HTTP header
    /// - parameter mimeType: The MiME type to associated with the data content type in the `Content-type` HTTP header
    public func append(_ stream: InputStream, withLength length: UInt64, name: String, fileName: String, mimeType: String) {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
        append(stream, withLength: length, headers: headers)
    }
    /// Creates a body part with the `headers`, `stream`, and `length` and appends it to the multipart form data object
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - HTTP headers
    /// - Encoded stream data
    /// - Multipart form boundary
    ///
    /// - parameter stream: input stream to encoded in the multipart form data
    /// - parameter length: stream length
    /// - parameter headers: the `HTTP` headers for the body part
    public func append(_ stream: InputStream, withLength length: UInt64, headers: HTTPHeaders) {
        let bodyPart = BodyPart(headers: headers, bodyStream: stream, bodyContentLength: length)
        bodyParts.append(bodyPart)
    }

    // MARK: - Data Encoding

    /// Encodes all the append body parts into a singal `Data` value.
    ///
    /// 该方法会同时将分隔的数据加载进入到内存, 仅适用于体量较小的数据`encoded`.
    /// 对于体量较大的数据, 使用`writeEncodedDataToDisk(fileURL:completionHandler:)` method.
    ///
    /// - throws : An `AFError` if encoding encounters a error
    ///
    /// - returns: The encoded `Data`
    public func encode() throws -> Data {
        if let bodyPartError = bodyPartError {
            throw bodyPartError
        }
        var encoded = Data()
        bodyParts.first?.hasInitialBoundary = true
        bodyParts.last?.hasFinalBoundary = true
        for bodyPart in bodyParts {
            let encodedData = try encode(bodyPart)
            encoded.append(encodedData)
        }
        return encoded
    }

    // MARK: - Private - Body Part Encoding

    private func encode(_ bodyPart: BodyPart) throws -> Data {
        var encoded = Data()
        /// initialData
        let initialData = bodyPart.hasInitialBoundary ? initalBoundaryData() : encapsulatedBoundaryData()
        encoded.append(initialData)
        /// headerData
        let headerData = encodeHeaders(for: bodyPart)
        encoded.append(headerData)
        /// bodyStreamData
        let bodyStreamData = try encodeBodyStream(for: bodyPart)
        encoded.append(bodyStreamData)
        /// finalBoundaryData
        if bodyPart.hasFinalBoundary {
            encoded.append(finalBoundaryData())
        }
        return encoded
    }

    private func encodeHeaders(for bodyPart: BodyPart) -> Data {
        var headerText = ""
        for (key, value) in bodyPart.headers {
            headerText += "\(key): \(value)\(EncodingCharacters.crlf)"
        }
        headerText += EncodingCharacters.crlf
        return headerText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }

    private func encodeBodyStream(for bodyPart: BodyPart) throws -> Data {
        let inputStream = bodyPart.bodyStream
        inputStream.open()
        defer { inputStream.close() }
        var encoded = Data()
        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: streamBufferSize)
            if  let error = inputStream.streamError {
                throw AFError.multipartEncodingFailed(reason: .inputStreamReadFailed(error: error))
            }
            if bytesRead > 0 {
                encoded.append(buffer, count: bytesRead)
            } else {
                break
            }
        }
        return encoded
    }
    
    // MARK: - Private - Writing Body Part To Output Stream
    
    private func write(_ bodyPary: BodyPart, to outPutStream: OutputStream) throws {
        try writeInitialBoundaryData(for: bodyPary, to: outPutStream)
        try writeHeaderData(for: bodyPary, to: outPutStream)
        try writeBodyStream(for: bodyPary, to: outPutStream)
        try writeFinalBoundaryData(for: bodyPary, to: outPutStream)
    }
    
    private func writeInitialBoundaryData(for bodyPart: BodyPart, to outPutStream: OutputStream) throws {
        let initialData = bodyPart.hasInitialBoundary ? initalBoundaryData() : encapsulatedBoundaryData()
        return try write(initialData, to: outPutStream)
    }
    
    private func writeHeaderData(for bodyPart: BodyPart, to outPutStream: OutputStream) throws {
        let headerData = encodeHeaders(for: bodyPart)
        return try write(headerData, to: outPutStream)
    }
    
    private func writeBodyStream(for bodyPart: BodyPart, to outPutStream: OutputStream) throws {
        let inputStream = bodyPart.bodyStream
        inputStream.open()
        defer { inputStream.close() }
        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: streamBufferSize)
            if  let error = inputStream.streamError {
                throw AFError.multipartEncodingFailed(reason: .inputStreamReadFailed(error: error))
            }
            if bytesRead > 0 {
                if buffer.count != bytesRead {
                    buffer = Array(buffer[0..<bytesRead])
                    try write(&buffer, to: outPutStream)
                }
            } else {
                break
            }
        }
    }
    
    private func writeFinalBoundaryData(for bodyPart: BodyPart, to outPutStream: OutputStream) throws {
        if bodyPart.hasFinalBoundary {
            return try write(finalBoundaryData(), to: outPutStream)
        }
    }
    
    // MARK: - Private - Write Buffered Data to OutPutStream
    
    private func write(_ data: Data, to outPutStream: OutputStream) throws {
        var buffer = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)
        return try write(&buffer, to: outPutStream)
    }
    
    private func write(_ buffer: inout [UInt8], to outPutStream: OutputStream) throws {
        var bytesToWrite = buffer.count
        while bytesToWrite > 0, outPutStream.hasSpaceAvailable {
            let bytesWritten = outPutStream.write(buffer, maxLength: bytesToWrite)
            if let error = outPutStream.streamError {
                throw AFError.multipartEncodingFailed(reason: .outPutStreamWriteFailed(error: error))
            }
            bytesToWrite -= bytesWritten
            if bytesToWrite > 0 {
                buffer = Array(buffer[bytesWritten..<buffer.count])
            }
        }
    }

    // MARK: - Private - Boundary Encoding

    private func initalBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .initial, boundary: boundary)
    }

    private func encapsulatedBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .encapsulated, boundary: boundary)
    }

    private func finalBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .final, boundary: boundary)
    }

    // MARK: - Private - Mime Type
    ///
    /// - parameter pathExtension: 文件的后缀名
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        return "application/octet-stream"
    }

    // MARK: - Private - Content headers

    private func contentHeaders(withName name: String, fileName: String? = nil, mimeType: String? = nil) -> [String: String] {
        var disposition = "form-data; name=\"\(name)\""
        if let fileName = fileName { disposition += "; filename=\"\(fileName)\"" }
        var headers = ["Content-Disposition": disposition]
        if let mimeType = mimeType { headers["Content-Type"] = mimeType }
        return headers
    }

    // MARK: - Private - Errors

    private func setBodyParhError(withReason reason: AFError.MultipartEncodingFailureReason) {
        guard bodyPartError == nil else { return }
        bodyPartError = AFError.multipartEncodingFailed(reason: reason)
    }
}
