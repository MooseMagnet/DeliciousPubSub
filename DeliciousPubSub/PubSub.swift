//
//  PubSub.swift
//  DeliciousPubSub
//
//  Created by Skylark on 13/03/2016.
//  Copyright © 2016 DevSword. All rights reserved.
//

import Foundation

public class PubSub {
    
    private var handlers: [String: ArrayReference<Handler>] = [:]
    internal let dispatchImmediately: Bool
    private var unhandledMessages: Array<Any> = []
    
    public init(dispatchImmediately: Bool) {
        self.dispatchImmediately = dispatchImmediately
    }
    
    public convenience init() {
        self.init(dispatchImmediately: true)
    }
    
    deinit {
        handlers.removeAll()
    }
    
    
    
    //
    // MARK: Sub.
    //
    
    public func sub<T: Any>(fn: T -> Void) -> Void -> Void {
        let typeName = String(T)
        if (handlers[typeName] == nil) {
            handlers[typeName] = ArrayReference<Handler>(array: [])
        }
        var unsubbed = false
        let handler = Handler(handlingFunction: { (any: Any) in
            if (unsubbed) {
                return
            }
            fn(any as! T)
        })
        handlers[typeName]!.append(handler)
        
        return {
            if (unsubbed) {
                return
            }
            self.handlers[typeName]!.remove(handler)
            unsubbed = true
        }
    }
    
    public func sub<T: Any>(type: T.Type, fn: T -> Void) -> Void -> Void {
        return sub(fn)
    }
    
    public func sub<T: Any>(predicate predicate: T -> Bool, fn: T -> Void) -> Void -> Void {
        let predicatedFn: T -> Void = {
            if predicate($0) {
                fn($0)
            }
        }
        return sub(predicatedFn)
    }
    
    public func sub<T: Any>(type: T.Type, predicate: T -> Bool, fn: T -> Void) -> Void -> Void {
        return sub(predicate: predicate, fn: fn)
    }
    
    
    
    //
    // MARK: Sub Once.
    //
    
    public func subOnce<T: Any>(fn: T -> Void) -> Void -> Void {
        var unsub: Void -> Void = {
            fatalError("unsub should be re-assigned to the unsub function.")
        }
        let unsubbingFn: T -> Void = {
            fn($0)
            unsub()
        }
        unsub = sub(unsubbingFn)
        return unsub
    }
    
    public func subOnce<T: Any>(type: T.Type, fn: T -> Void) -> Void -> Void {
        return subOnce(fn)
    }
    
    public func subOnce<T: Any>(predicate predicate: T -> Bool, fn: T -> Void) -> Void -> Void {
        var unsub: Void -> Void = {
            fatalError("unsub should be re-assigned to the unsub function.")
        }
        let unsubbingFn: T -> Void = {
            fn($0)
            unsub()
        }
        unsub = sub(predicate: predicate, fn: unsubbingFn)
        return unsub
    }
    
    public func subOnce<T: Any>(type: T.Type, predicate: T -> Bool, fn: T -> Void) -> Void -> Void {
        return subOnce(predicate: predicate, fn: fn)
    }
    
    
    
    //
    // MARK: Pub and Dispatch.
    //
    
    public func pub(message: Any) {
        if (dispatchImmediately) {
            dispatchMessageOfType(getTypeNameOf(message), message: message)
        } else {
            unhandledMessages.append(message)
        }
    }
    
    public func dispatchMessages() {
        while (unhandledMessages.count > 0) {
            let message = unhandledMessages.removeFirst()
            dispatchMessageOfType(
                getTypeNameOf(message),
                message: message)
        }
    }
    
    private func getTypeNameOf(object: Any) -> String {
        return String(Mirror(reflecting: object).subjectType)
    }
    
    private func dispatchMessageOfType(typeName: String, message: Any) {
        
        guard let typeHandlers = handlers[typeName] else {
            return
        }
        
        for (_, handler) in typeHandlers.array.enumerate() {
            handler.handle(message)
        }
    }
}
