//
//  PubSub.swift
//  DeliciousPubSub
//

import Foundation

open class PubSub {
    
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
    
    open func sub<T: Any>(_ fn: @escaping (T) -> Void) -> () -> Void {
        let typeName = String(describing: T.self)
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
    
    open func sub<T: Any>(_ type: T.Type, fn: @escaping (T) -> Void) -> () -> Void {
        return sub(fn)
    }
    
    open func sub<T: Any>(predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        let predicatedFn: (T) -> Void = {
            if predicate($0) {
                fn($0)
            }
        }
        return sub(predicatedFn)
    }
    
    open func sub<T: Any>(_ type: T.Type, predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        return sub(predicate: predicate, fn: fn)
    }
    
    
    
    //
    // MARK: Sub Once.
    //
    
    open func subOnce<T: Any>(_ fn: @escaping (T) -> Void) -> () -> Void {
        var unsub: () -> Void = {
            fatalError("unsub should be re-assigned to the unsub function.")
        }
        let unsubbingFn: (T) -> Void = {
            fn($0)
            unsub()
        }
        unsub = sub(unsubbingFn)
        return unsub
    }
    
    open func subOnce<T: Any>(_ type: T.Type, fn: @escaping (T) -> Void) -> () -> Void {
        return subOnce(fn)
    }
    
    open func subOnce<T: Any>(predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        var unsub: () -> Void = {
            fatalError("unsub should be re-assigned to the unsub function.")
        }
        let unsubbingFn: (T) -> Void = {
            fn($0)
            unsub()
        }
        unsub = sub(predicate: predicate, fn: unsubbingFn)
        return unsub
    }
    
    open func subOnce<T: Any>(_ type: T.Type, predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        return subOnce(predicate: predicate, fn: fn)
    }
    
    
    
    //
    // MARK: Pub and Dispatch.
    //
    
    open func pub(_ message: Any) {
        if (dispatchImmediately) {
            dispatchMessageOfType(getTypeNameOf(message), message: message)
        } else {
            unhandledMessages.append(message)
        }
    }
    
    open func dispatchMessages() {
        while (unhandledMessages.count > 0) {
            let message = unhandledMessages.removeFirst()
            dispatchMessageOfType(
                getTypeNameOf(message),
                message: message)
        }
    }
    
    fileprivate func getTypeNameOf(_ object: Any) -> String {
        return String(describing: Mirror(reflecting: object).subjectType)
    }
    
    fileprivate func dispatchMessageOfType(_ typeName: String, message: Any) {
        
        guard let typeHandlers = handlers[typeName] else {
            return
        }
        
        for (_, handler) in typeHandlers.array.enumerated() {
            handler.handle(message)
        }
    }
}
