//
//  DeliciousPubSubWithManualDispatch.swift
//  DeliciousPubSub
//
//  Created by Skylark on 13/03/2016.
//  Copyright © 2016 DevSword. All rights reserved.
//

import XCTest
@testable import DeliciousPubSub

class DeliciousPubSubWithManualDispatch: XCTestCase {

    private var pubSub: PubSub!
    
    override func setUp() {
        super.setUp()
        pubSub = PubSub(dispatchImmediately: false)
    }
    
    override func tearDown() {
        super.tearDown()
        pubSub = nil
    }
    
    func testWhenDispatchMessagesIsCalledTheSubscribersAreNotified() {
        var yep = 0
        
        let _ = pubSub.sub(TestMessage.self) {
            yep += 1
            XCTAssert($0.value == 1)
        }
        
        let _ = pubSub.subOnce(TestMessage.self) {
            yep += 1
            XCTAssert($0.value == 1)
        }
        
        let _ = pubSub.sub(TestMessage.self,
                           predicate: {
                            $0.value == 1
            },
                           fn: {
                            yep += 1
                            XCTAssert($0.value == 1)
        })
        
        let _ = pubSub.subOnce(TestMessage.self,
                               predicate: {
                                $0.value == 1
            },
                               fn: {
                                yep += 1
                                XCTAssert($0.value == 1)
        })
        
        pubSub.pub(TestMessage(value: 1))
        
        XCTAssert(yep == 0)
        
        pubSub.dispatchMessages()
        
        XCTAssert(yep == 4)
        
        pubSub.dispatchMessages()
        
        XCTAssert(yep == 4)
    }

}
