//
//  Copyright (c) 2015-2016 Algolia
//  http://www.algolia.com/
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


/// Status codes.
/// NOTE: Only those likely to be used by Algolia's servers and SDK are listed here.
///
public enum StatusCode: Int {
    // MARK: Regular HTTP status codes
    
    case ok                                                     = 200
    case badRequest                                             = 400
    case unauthorized                                           = 401
    case forbidden                                              = 403
    case methodNotAllowed                                       = 405
    case internalServerError                                    = 500
    case serviceUnavailable                                     = 503
    
    // MARK: Custom status codes
    
    case unknown                                                = -1
    
    /// The server replied ill-formed JSON (syntax error).
    case illFormedResponse                                      = 600
    
    /// The server replied an invalid response (grammar error).
    case invalidResponse                                        = 601
    
    public static func isSuccess(_ statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    public static func isClientError(_ statusCode: Int) -> Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    public static func isServerError(_ statusCode: Int) -> Bool {
        return statusCode >= 500 && statusCode < 600
    }
}

extension NSError {
    /// Determine if this error is transient or not.
    /// "Transient" means retrying an identical request at a later time might lead to a different result.
    ///
    func isTransient() -> Bool {
        if (domain == Client.ErrorDomain) {
            return StatusCode.isServerError(code)
        } else if (domain == NSURLErrorDomain) {
            return true
        } else {
            return false
        }
    }
}

