//
//  Expectation.swift
//  Expectations
//
//  Created by Paulo F. Andrade on 16/12/2018.
//  Copyright © 2018 Paulo F. Andrade. All rights reserved.
//

import Foundation


@objcMembers
public class Expectation: NSObject {
    
    // public
    public private(set) var fulfilled = false
    public var waitGranularity: TimeInterval = 0.1 // test condition in intervals of 0.1 s
    
    public init(name: String? = nil) {
        self.state.name = name
    }
    
    public func fulfill() {
        state.lock()
        fulfilled = true
        state.broadcast()
        state.unlock()
    }
    
    public func wait(for interval: TimeInterval,
                     runRunloop: Bool = false,
                     while condition: @autoclosure () -> Bool = true) {
        wait(until: Date().addingTimeInterval(interval), runRunloop: runRunloop, while: condition)
    }
    
    public func wait(until limit: Date,
                     runRunloop: Bool = false,
                     while condition: @autoclosure () -> Bool = true) {
        state.lock()
        while condition() && !fulfilled {
            if Date() > limit {
                break;
            }
            let nextTick = Date().addingTimeInterval(waitGranularity)
            if runRunloop {
                state.unlock()
                let ranRunloop = RunLoop.current.run(mode: .default, before: nextTick)
                state.lock()
                
                // if the runloop did not run at all,
                // then wait on then condition to prevent a live loop
                if !ranRunloop {
                    state.wait(until: nextTick)
                }
            }
            else {
                state.wait(until: nextTick)
            }
            
        }
        state.unlock()
    }
    
    public override var description: String {
        return state.name ?? super.description
    }
    
    // private
    private let state = NSCondition()

}
