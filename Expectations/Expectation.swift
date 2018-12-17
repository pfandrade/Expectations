//
//  Expectation.swift
//  Expectations
//
//  Created by Paulo F. Andrade on 16/12/2018.
//  Copyright © 2018 Paulo F. Andrade. All rights reserved.
//

import Foundation


public class Expectation: NSObject {
    
    // public
    public private(set) var fulfilled = false
    public var waitGranularity: TimeInterval = 0.1 // test condition in intervals of 0.1 s
    
    init(name: String? = nil) {
        self.state.name = name
    }
    
    public func fulfill() {
        state.lock()
        fulfilled = true
        state.broadcast()
        state.unlock()
    }
    
    public func wait(for interval: TimeInterval,
                     while condition: @autoclosure () -> Bool = true,
                     runRunloop: Bool = false) {
        wait(until: Date().addingTimeInterval(interval), while: condition, runRunloop: runRunloop)
    }
    
    public func wait(until limit: Date,
                     while condition: @autoclosure () -> Bool = true,
                     runRunloop: Bool = false) {
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
