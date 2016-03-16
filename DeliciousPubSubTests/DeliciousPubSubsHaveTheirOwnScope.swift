//
//  DeliciousPubSubsHaveTheirOwnScope.swift
//  DeliciousPubSub
//
//  Created by Skylark on 13/03/2016.
//  Copyright © 2016 DevSword. All rights reserved.
//

import XCTest
@testable import DeliciousPubSub

class DeliciousPubSubsHaveTheirOwnScope: XCTestCase {
    
    func testItMayGoWithoutSayingButEachPubSubManagesItsOwnSubscribersSoYouCanHaveMany() {
        let pubSub1 = PubSub(dispatchImmediately: true)
        let _ = pubSub1.sub(Int.self) {
            XCTAssert($0 == 1)
        }
        
        let pubSub2 = PubSub(dispatchImmediately: true)
        let _ = pubSub2.sub(Int.self) {
            XCTAssert($0 == 2)
        }
        
        pubSub1.pub(1)
        pubSub2.pub(2)
    }
}