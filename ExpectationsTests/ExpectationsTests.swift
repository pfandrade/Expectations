//
//  ExpectationsTests.swift
//  ExpectationsTests
//
//  Created by Paulo F. Andrade on 16/12/2018.
//  Copyright © 2018 Paulo F. Andrade. All rights reserved.
//

import XCTest
@testable import Expectations

class ExpectationsTests: XCTestCase {

    func testSimpleWait() {
        
        let expectation = Expectation()
        
        var flag = false
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            flag = true
            expectation.fulfill()
        }
        
        let startDate = Date()
        expectation.wait(for: 5)
        let exitDate = Date()
        
        XCTAssertTrue(flag)
        XCTAssertTrue(exitDate.timeIntervalSince(startDate) < 1.3)
    }

    func testConditionWait() {
        let expectation = Expectation()
        let queue = OperationQueue()
        
        var flag = false
        
        let blockOperation = BlockOperation()
        blockOperation.addExecutionBlock { [unowned blockOperation] () -> Void in
            expectation.wait(until: Date.distantFuture, while: !blockOperation.isCancelled)
            
            if blockOperation.isCancelled {
                return
            }
            flag = true
        }
        queue.addOperation(blockOperation)
        
        Thread.sleep(forTimeInterval: 1.0)
        blockOperation.cancel()
        queue.waitUntilAllOperationsAreFinished()
        XCTAssertFalse(flag)
    }
    
    func testRunRunloop() {
        
        let expectation = Expectation()
        
        var flag = false
        // by scheduling in the main thread we assert that the runloop is running
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            flag = true
            expectation.fulfill()
        }
        
        let startDate = Date()
        expectation.wait(for: 5, runRunloop: true)
        let exitDate = Date()
        
        XCTAssertTrue(flag)
        XCTAssertTrue(exitDate.timeIntervalSince(startDate) < 1.3)
    }
}
