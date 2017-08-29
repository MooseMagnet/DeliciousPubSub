//
//  DeliciousPubSubTests.swift
//  DeliciousPubSubTests
//
//  Created by Skylark on 13/03/2016.
//  Copyright © 2016 DevSword. All rights reserved.
//

import XCTest
@testable import DeliciousPubSub

class DeliciousPubSubTests: XCTestCase {
    
    private var pubSub: PubSub!
    
    override func setUp() {
        super.setUp()
        pubSub = PubSub()
    }
    
    override func tearDown() {
        super.tearDown()
        pubSub = nil
    }
    
    func testTheDefaultInitializerCreatesAPubSubWithImmediateDispatch() {
        XCTAssert(pubSub.dispatchImmediately)
    }
    
    func testWhenAMessageOfAClassIsPublishedThenSubscribersAreNotifiedUntilTheyUnsubscribe() {
        var count = 0
        let unsub = pubSub.sub { (message: TestMessage) in
            count += 1
            XCTAssert(message.value == 1)
        }
        pubSub.pub(TestMessage(value: 1))
        pubSub.pub(TestMessage(value: 1))
        pubSub.pub(TestMessage(value: 1))
        unsub()
        pubSub.pub(TestMessage(value: 2))
        
        XCTAssert(count == 3)
    }
    
    func testEvenThoughItsProbablyABadIdeaMessagesOfPrimitiveTypesCanBeSubscribedTo() {
        var didItWork = false
        let _ = pubSub.sub { (message: Int) in
            didItWork = true
            XCTAssert(message == 1)
        }
        pubSub.pub(true)
        pubSub.pub(0.0)
        pubSub.pub(1)
        XCTAssert(didItWork)
    }
    
    func testOneTimeSubscriptionsAutomaticallyUnsubscribeAfterCallback() {
        let _ = pubSub.subOnce { (message: TestMessage) in
            XCTAssert(message.value == 1)
        }
        pubSub.pub(TestMessage(value: 1))
        pubSub.pub(TestMessage(value: 2))
    }
    
    func testPredicatedSubscriptionsOnlyCallbackIfPredicatePasses() {
        let _ = pubSub.sub(
            predicate: { (message: TestMessage) -> Bool in
                message.value < 10
            },
            fn: { (message: TestMessage) in
                XCTAssert(message.value == 1)
            })
        pubSub.pub(TestMessage(value: 10))
        pubSub.pub(TestMessage(value: 1))
    }
    
    func testPredicatedOneTimeSubscriptionsAutomaticallyUnsubscribeAfterCallback() {
        let _ = pubSub.subOnce(
            predicate: { (message: TestMessage) -> Bool in
                message.value < 10
            },
            fn: { (message: TestMessage) in
                XCTAssert(message.value == 1)
        })
        pubSub.pub(TestMessage(value: 10))
        pubSub.pub(TestMessage(value: 1))
        pubSub.pub(TestMessage(value: 2))
    }
    
    func testPurelyForLegibilityYouCanForceTypeInferenceBySpecifyingTheTypeAndUseCompactClosureSyntax() {
        
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
        
        XCTAssert(yep == 4)
    }
}

class TestMessage {
    let value: Int
    init(value: Int) {
        self.value = value
    }
}
