//
//  SubscriptionsCanBeCancelledInsideOfSubscriptionCallbacks.swift
//  DeliciousPubSub
//
//  Created by Skylark on 19/03/2016.
//  Copyright © 2016 DevSword. All rights reserved.
//

import XCTest
@testable import DeliciousPubSub

// There was a bug.

// During the message dispatch, subscription callbacks could be invoked after they
// were prematurely unregistered inside of the body of another handler invoked previously
// in the same message dispatch call.

// That is to say, Handler 1 was unable to prevent the later Handler 2 from running
// by calling a function to deregister it.

// There's probably use case for this, so here is a test to prove it now works.

class SubscriptionsCanBeCancelledInsideOfSubscriptionCallbacks : XCTestCase {
    
    func testTheCallbackWillNotBeInvokedAfterAPreviousHandlerHasCancelledIt() {
        
        let pubSub = PubSub()
        
        var invokedPrecedingHandler = false
        var invokedCancelledHandler = false
        
        var unsub: ((Void) -> Void)!
        
        let _ = pubSub.sub { (_: Int) in
            invokedPrecedingHandler = true
            unsub()
        }
        
        unsub = pubSub.sub { (_: Int) in
            invokedCancelledHandler = true
            XCTFail()
        }
        
        pubSub.pub(1)
        
        XCTAssert(!invokedCancelledHandler)
        XCTAssert(invokedPrecedingHandler)
        
        // Ideally we'd be able to call this again without an explosion...
        unsub()
    }
}
