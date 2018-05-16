//  DispatchQueue+Eros.swift
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
import Dispatch

/// QoS : service quality

/**
 QoS can be applied all over iOS as well. One can prioritize queues, thread objects, dispatches queues, and POSIX threads. This is important, since asynchronous work is typically spread out across all of these techniques. By assigning the correct priority for the work these methods perform, iOS apps remain quick, snappy, and responsive...
 All is about prority
 https://medium.com/the-traveled-ios-developers-guide/quality-of-service-849cd6dee1e
 */

extension DispatchQueue {
    /// Work that happens on the main thread, such as animations or drawing operations
    static var userInteractive: DispatchQueue { return DispatchQueue.global(qos: .userInteractive)}
    /// Work that the user kicks off and should yield immediate results. This work must be completed for the user to continue
    static var userInitiated: DispatchQueue { return DispatchQueue.global(qos: .userInitiated)}
    /// Work that may take a bit and doesn’t need to finish right away. Analogous to progress bars and importing data
    static var utility: DispatchQueue { return DispatchQueue.global(qos: .utility)}
    /// This work isn’t visible to the user. Backups, syncs, indexing, etc.
    static var background: DispatchQueue { return DispatchQueue.global(qos: .background)}

    /// delay function
    func after(_ delay: TimeInterval, execute closure: @escaping ()-> Void) {
         asyncAfter(deadline: .now() + delay, execute: closure)
    }
}
