//
//  Copyright (c) 2015 Algolia
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

class ExpiringCacheItem {
    let expiringCacheItemDate: Date
    let content: [String: AnyObject]
    
    init(content: [String: AnyObject]) {
        self.content = content
        self.expiringCacheItemDate = Date()
    }
}

class ExpiringCache {
    private let cache = Cache()
    private let expiringTimeInterval: TimeInterval
    
    private var cacheKeys = [String]()
    private var timer: Timer? = nil
    
    init(expiringTimeInterval: TimeInterval) {
        self.expiringTimeInterval = expiringTimeInterval
        
        // Garbage collector like, for the expired cache
        timer = Timer(timeInterval: 2 * expiringTimeInterval, target: self, selector: #selector(ExpiringCache.clearExpiredCache), userInfo: nil, repeats: true)
        timer!.tolerance = expiringTimeInterval * 0.5
        RunLoop.main().add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    deinit {
        timer!.invalidate()
    }
    
    func objectForKey(_ key: String) -> [String: AnyObject]? {
        if let object = cache.object(forKey: key) as? ExpiringCacheItem {
            let timeSinceCache = abs(object.expiringCacheItemDate.timeIntervalSinceNow)
            if timeSinceCache > expiringTimeInterval {
                cache.removeObject(forKey: key)
            } else {
                return object.content
            }
        }
        
        return nil
    }
    
    func setObject(_ obj: [String: AnyObject], forKey key: String) {
        cache.setObject(ExpiringCacheItem(content: obj), forKey: key)
        cacheKeys.append(key)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        cacheKeys.removeAll(keepingCapacity: true)
    }
    
    @objc func clearExpiredCache() {
        var tmp = [String]()
        
        for key in cacheKeys {
            if let object = cache.object(forKey: key) as? ExpiringCacheItem {
                let timeSinceCache = abs(object.expiringCacheItemDate.timeIntervalSinceNow)
                if timeSinceCache > expiringTimeInterval {
                    cache.removeObject(forKey: key)
                } else {
                    tmp.append(key)
                }
            }
        }
        
        cacheKeys = tmp
    }
}
