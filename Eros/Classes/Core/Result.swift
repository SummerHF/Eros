//  Result.swift
//  Pods
//
//  Created by SummerHF on 24/05/2018.
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

/// 表示一个`Request`是成功还是遇到问题
///
/// - success: The request and all post processing operation were successful resulting in the
///            serialization of the provided associated value.
///
/// - failure: The request encountered an error resulting in a error.
public enum Result<Value> {
    case success(Value)
    case failure(Error)

    /// Return `true` if the result is `success`
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure :
            return false
        }
    }

    /// Return `true` if the result is `failure`
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Return the associated value if the result is `success`, nil otherwise.
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Return the associated error value if the result is `failure`, nil otherwise.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - CustomStringConvertible

extension Result: CustomStringConvertible {

    /// The textual representation used when written to an outPut stream, which include whether the result is `success` or `fallure`.
    public var description: String {
        switch self {
        case .success:
             return "SUCCESS"
        case .failure:
             return "FAILURE"
        }
    }
}

extension Result: CustomDebugStringConvertible {

   /// The debug textual representation used when written to an outPut stream, which include whether the result is `success` or `fallure`.
    public var debugDescription: String {
        switch self {
        case .success(let value):
            return "Success: \(value)"
        case .failure(let error):
            return "Error: \(error)"
        }
    }
}

// MARK: - Function APIs

extension Result {

    /// Create a `Result` instance from the result of value closure
    ///
    /// A failure result is created when the closure throws, and success result is created when the closure succeeds without throwing an error
    ///
    ///   func someString() throws -> String { ... }
    ///
    ///   let result = Result(value: {
    ///       return try someString()
    ///   })
    ///
    ///   // The type of result is Result<String>
    ///
    ///   The trailing closure syntax is also supported:
    ///
    ///   let result = Result { try someString() }
    /// - parameter value: a closure like a anonymous function which return value is a `Value`
    public init(value: () throws -> Value) {
        do {
            self = try .success(value())
        } catch {
            self = .failure(error)
        }
    }

    /// Return the success value and throw the failure error
    ///
    ///     let possibleString: Result<String> = .failure(AFError.description(title: "failure"))
    ///     do {
    ///         try print(possibleString.unwrap())
    ///     } catch AFError.description(let title) {
    ///          print(title)
    ///     }
    ///
    public func unwrap() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    /// Evaluates the specified closure when the `Result` is a success, passing the unwrapped value as a parameter
    ///
    /// let possibleData: Result<Data> = .success(Data())
    /// let possibleInt = possibleData.map{$0.count}
    /// try print(possibleInt.unwrap())
    ///
    /// - parameter transform: a closure that takes the success value of the `Result` instance
    /// - returns: A `Result` containing the result of the giving closure. if the instance is failure, return the same failure.
    public func map<T>(_ transform: (Value) -> T) -> Result<T> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Evaluates the specified closure when the `Result` is a success, passing the unwrapped value as a parameter
    ///
    /// Use the `flatMap` method with a closure that may throw an error: For example:
    ///
    /// let possibleData: Result<Data> = .success(Data())
    /// let possibleObject = possibleData.flatMap{
    ///       try JSONSerialization.jsonObject(with: $0, options: .allowFragments)
    /// }
    ///
    /// - parameter transform: a closure that takes the success value of the `Result` instance
    /// - returns: A `Result` containing the result of the giving closure. if the instance is failure, return the same failure.
    public func flatMap<T>(_ transform: (Value) throws -> T) -> Result<T> {
        switch self {
        case .success(let value):
            do {
                return try .success(transform(value))
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }


    /// Evaluates the specified closure when the `Result` is a failure, passing the unwrapped error as a parameter.
    ///
    /// Use the `mapError` function with a closure that does not throw. For example:
    ///
    /// let possibleData: Result<Data> = .failure(AFError.description(title: "test"))
    /// let myError: Result<Data> = possibleData.mapError{ error in
    ///     return AFError.error(error: error)
    /// }
    ///
    /// - Parameter transform: A closure that takes the error of the instance.
    /// - Returns: A `Result` instance containing the result of the transform. If this instance is a success,
    ///   returns same instance.
    public func mapError<T: Error>(_ transform: (Error) -> T) -> Result {
        switch self {
        case .failure(let error):
            return .failure(transform(error))
        case .success:
            return self
        }
    }


    /// Evaluates the specified closure when the `Result` is a failure, passing the unwrapped error as a parameter.
    ///
    /// Use the `flatMapError` function with a closure that may throw an error. For example:
    ///
    ///     let possibleData: Result<Data> = .success(Data(...))
    ///     let possibleObject = possibleData.flatMapError {
    ///         try someFailableFunction(taking: $0)
    ///     }
    ///
    /// - Parameter transform: A throwing closure that takes the error of the instance.
    ///
    /// - Returns: A `Result` instance containing the result of the transform. If this instance is a success, returns
    ///            the same instance.
    public func flatMapError<T: Error>(_ transform: (Error) throws -> T) ->Result {
        switch self {
        case .success:
            return self
        case .failure(let error):
            do {
                return try .failure(transform(error))
            } catch {
                return .failure(error)
            }
        }
    }

    /// Evaluates the specified closure when the `Result` is a success, passing the unwrapped value as a parameter.
    ///
    /// Use the `withValue` function to evaluate the passed closure without modifying the `Result` instance.
    ///
    /// - Parameter closure: A closure that takes the success value of this instance.
    /// - Returns: This `Result` instance, unmodified.
    @discardableResult
    public func withValue(_ closure: (Value) -> Void) -> Result {
        if case let .success(value) = self { closure(value)}
        return self
    }

    /// Evaluates the specified closure when the `Result` is a success.
    ///
    /// Use the `ifSuccess` function to evaluate the passed closure without modifying the `Result` instance.
    ///
    /// - Parameter closure: A `Void` closure.
    /// - Returns: This `Result` instance, unmodified.
    @discardableResult
    public func ifSuccess(_ closure: () -> Void) -> Result {
        if isSuccess { closure() }
        return self
    }

    /// Evaluates the specified closure when the `Result` is a failure.
    ///
    /// Use the `ifFailure` function to evaluate the passed closure without modifying the `Result` instance.
    ///
    /// - Parameter closure: A `Void` closure.
    /// - Returns: This `Result` instance, unmodified.
    @discardableResult
    public func isFailure(_ closure: () -> Void) -> Result {
        if isFailure { closure() }
        return self
    }
}
