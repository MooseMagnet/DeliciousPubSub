//
//  Performance.swift
//  DeliciousPubSub
//

import XCTest
@testable import DeliciousPubSub

class Performance: XCTestCase {

    func testPubPerformanceWithOneSubscriberWithManualDispatch() {
        let pubSub = PubSub(dispatchImmediately: false)
        let _ = pubSub.sub { (_: TestMessage) in }
        let testMessage = TestMessage(value: 1)
        
        measure {
            for _ in 0..<10000 {
                pubSub.pub(testMessage)
            }
            pubSub.dispatchMessages()
        }
    }
    
    func testPubPerformanceWithOneSubscriberWithImmediateDispatch() {
        let pubSub = PubSub(dispatchImmediately: true)
        let _ = pubSub.sub { (_: TestMessage) in }
        let testMessage = TestMessage(value: 1)

        measure { 
            for _ in 0..<10000 {
                pubSub.pub(testMessage)
            }
        }
    }
    
    func testSubPerformance() {
        let pubSub = PubSub()
        
        measure { 
            for _ in 0..<10000 {
                let _ = pubSub.sub { (_: TestMessage) in }
            }
        }
    }
    
    func testPerformanceWithManySubscribersWithImmediateDispatch() {
        let pubSub = PubSub(dispatchImmediately: true)
        let testMessage = TestMessage(value: 1)
        
        for _ in 0..<100 {
            let _ = pubSub.sub(TestMessage.self) { _ in }
            let _ = pubSub.sub(TestMessage.self,
                               predicate: { _ in true },
                               fn: { _ in })
        }
        
        measure {
            for _ in 0..<1000 {
                pubSub.pub(testMessage)
            }
        }
    }
    
    func testPerformanceWithManySubscribersWithManualDispatch() {
        let pubSub = PubSub(dispatchImmediately: true)
        let testMessage = TestMessage(value: 1)
        
        for _ in 0..<100 {
            let _ = pubSub.sub(TestMessage.self) { _ in }
            let _ = pubSub.sub(TestMessage.self,
                               predicate: { _ in true },
                               fn: { _ in })
        }
        
        measure {
            for _ in 0..<1000 {
                pubSub.pub(testMessage)
            }
            
            pubSub.dispatchMessages()
        }
    }
    
    func testPerformanceNewingUpMessages() {
        let pubSub = PubSub(dispatchImmediately: true)
        
        for _ in 0..<100 {
            let _ = pubSub.sub(TestMessage.self) { _ in }
            let _ = pubSub.sub(TestMessage.self,
                               predicate: { _ in true },
                               fn: { _ in })
        }
        
        measure {
            for i in 0..<1000 {
                pubSub.pub(TestMessage(value: i))
            }
            
            pubSub.dispatchMessages()
        }
    }

}
