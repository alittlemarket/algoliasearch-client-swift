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

import XCTest
import AlgoliaSearch

class ClientTests: XCTestCase {
    let expectationTimeout: TimeInterval = 100
    
    var alogClient: AlgoliaSearch.Client!
    var algoIndex: AlgoliaSearch.Index!
    
    override func setUp() {
        super.setUp()
        let appID = ProcessInfo.processInfo.environment["ALGOLIA_APPLICATION_ID"] ?? APP_ID
        let apiKey = ProcessInfo.processInfo.environment["ALGOLIA_API_KEY"] ?? API_KEY
        alogClient = AlgoliaSearch.Client(appID: appID, apiKey: apiKey)
        algoIndex = alogClient.getIndex(safeIndexName("algol?à-swift"))
        
        let expectation = self.expectation(description: "Delete index")
        alogClient.deleteIndex(algoIndex.indexName, completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let expectation = self.expectation(description: "Delete index")
        alogClient.deleteIndex(algoIndex.indexName, completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testListIndexes() {
        let expectation = self.expectation(description: "testListIndexes")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        self.algoIndex.addObject(object as [String : AnyObject], completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.algoIndex.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        self.alogClient.listIndexes({ (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during listIndexes: \(error)")
                            } else {
                                let items = content!["items"] as! [[String: AnyObject]]
                                
                                var found = false
                                for item in items {
                                    if (item["name"] as! String) == self.algoIndex.indexName {
                                        found = true
                                        break
                                    }
                                }
                                
                                XCTAssertTrue(found, "List indexes failed")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testMoveIndex() {
        let expecation = expectation(description: "testMoveIndex")
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        self.algoIndex.addObject(object as [String : AnyObject], completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.algoIndex.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        XCTAssertEqual((content!["status"] as! String), "published", "Wait task failed")
                        
                        self.alogClient.moveIndex(self.algoIndex.indexName, to: safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during moveIndex: \(error)")
                                expecation.fulfill()
                            } else {
                                self.algoIndex.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during waitTask: \(error)")
                                        expecation.fulfill()
                                    } else {
                                        let dstIndex = self.alogClient.getIndex(safeIndexName("algol?à-swift2"))
                                        dstIndex.search(Query(), completionHandler: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during search: \(error)")
                                            } else {
                                                let nbHits = content!["nbHits"] as! Int
                                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                                            }
                                            
                                            expecation.fulfill()
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
        
        let deleteExpectation = expectation(description: "Delete index")
        alogClient.deleteIndex(safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            deleteExpectation.fulfill()
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testCopyIndex() {
        let expecation = expectation(description: "testCopyIndex")
        let srcIndexExpectation = expectation(description: "srcIndex")
        let dstIndexExpectation = expectation(description: "dstIndex")
        
        let object = ["city": "San Francisco", "objectID": "a/go/?à"]
        
        self.algoIndex.addObject(object as [String : AnyObject], completionHandler: { (content, error) -> Void in
            guard let taskID = content?["taskID"] as? Int else {
                XCTFail("Error fetching taskID")
                expecation.fulfill()
                return
            }

            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expecation.fulfill()
            } else {
                self.algoIndex.waitTask(taskID, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expecation.fulfill()
                    } else {
                        XCTAssertEqual((content!["status"] as! String), "published", "Wait task failed")
                        
                        self.alogClient.copyIndex(self.algoIndex.indexName, to: safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during copyIndex: \(error)")
                                expecation.fulfill()
                            } else {
                                self.algoIndex.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                                    if let error = error {
                                        XCTFail("Error during waitTask: \(error)")
                                    } else {
                                        self.algoIndex.search(Query(), completionHandler: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during search: \(error)")
                                            } else {
                                                let nbHits = content!["nbHits"] as! Int
                                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                                            }
                                            
                                            srcIndexExpectation.fulfill()
                                        })
                                        
                                        let dstIndex = self.alogClient.getIndex(safeIndexName("algol?à-swift2"))
                                        dstIndex.search(Query(), completionHandler: { (content, error) -> Void in
                                            if let error = error {
                                                XCTFail("Error during search: \(error)")
                                            } else {
                                                let nbHits = content!["nbHits"] as! Int
                                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                                            }
                                            
                                            dstIndexExpectation.fulfill()
                                        })
                                    }
                                    
                                    expecation.fulfill()
                                })
                            }
                        })
                    }
                })
            }
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
        
        let deleteExpectation = expectation(description: "Delete index")
        alogClient.deleteIndex(safeIndexName("algol?à-swift2"), completionHandler: { (content, error) -> Void in
            XCTAssertNil(error, "Error during deleteIndex: \(error?.description)")
            deleteExpectation.fulfill()
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testMultipleQueries() {
        let expectation = self.expectation(description: "testMultipleQueries")
        let object = ["city": "San Francisco"]
        
        self.algoIndex.addObject(object as [String : AnyObject], completionHandler: { (content, error) -> Void in
            if let error = error {
                XCTFail("Error during addObject: \(error)")
                expectation.fulfill()
            } else {
                self.algoIndex.waitTask(content!["taskID"] as! Int, completionHandler: { (content, error) -> Void in
                    if let error = error {
                        XCTFail("Error during waitTask: \(error)")
                        expectation.fulfill()
                    } else {
                        let queries = [IndexQuery(index: self.algoIndex, query: Query())]
                        
                        self.alogClient.multipleQueries(queries, completionHandler: { (content, error) -> Void in
                            if let error = error {
                                XCTFail("Error during multipleQueries: \(error)")
                            } else {
                                let items = content!["results"] as! [[String: AnyObject]]
                                let nbHits = items[0]["nbHits"] as! Int
                                XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
                            }
                            
                            expectation.fulfill()
                        })
                    }
                })
            }
        })
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testHeaders() {
        // Make a call with a valid API key.
        let expectation1 = expectation(description: "Valid API key")
        self.alogClient.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            expectation1.fulfill()
        }
        
        // Override the API key and check the call fails.
        self.alogClient.headers["X-Algolia-API-Key"] = "NOT_A_VALID_API_KEY"
        let expectation2 = expectation(description: "Invalid API key")
        self.alogClient.listIndexes {
            (content, error) -> Void in
            XCTAssertNotNil(error)
            expectation2.fulfill()
        }

        // Restore the valid API key (otherwise tear down will fail).
        self.alogClient.headers["X-Algolia-API-Key"] = self.alogClient.apiKey
        
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testBatch() {
        let expectation = self.expectation(description: #function)
        let actions = [
            [
                "indexName": algoIndex.indexName,
                "action": "addObject",
                "body": [ "city": "San Francisco" ]
            ],
            [
                "indexName": algoIndex.indexName,
                "action": "addObject",
                "body": [ "city": "Paris" ]
            ]
        ]
        alogClient.batch(actions as [AnyObject]) {
            (content, error) -> Void in
            if error != nil {
                XCTFail(error!.localizedDescription)
            } else if let taskID = (content!["taskID"] as? [String: AnyObject])?[self.algoIndex.indexName] as? Int {
                // Wait for the batch to be processed.
                self.algoIndex.waitTask(taskID) {
                    (content, error) in
                    if error != nil {
                        XCTFail(error!.localizedDescription)
                    } else {
                        // Check that objects have been indexed.
                        self.algoIndex.search(Query(query: "Francisco")) {
                            (content, error) in
                            if error != nil {
                                XCTFail(error!.localizedDescription)
                            } else {
                                XCTAssertEqual(content!["nbHits"] as? Int, 1)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            } else {
                XCTFail("Could not find task ID")
            }
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
}
