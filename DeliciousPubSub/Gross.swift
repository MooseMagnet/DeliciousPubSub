//
//  Gross.swift
//  DeliciousPubSub
//
//  Created by Skylark on 13/03/2016.
//  Copyright © 2016 DevSword. All rights reserved.
//

import Foundation

class ArrayReference<T: AnyObject> {
    
    private var _array: Array<T>
    
    var array: Array<T> {
        get {
            return _array
        }
    }
    
    init(array: Array<T>) {
        _array = array
    }
    
    func append(_ element: T) {
        _array.append(element)
    }
    
    func remove(_ element: T) {
        let index = _array.index(where: { (thisElement) -> Bool in
            return thisElement === element
        })
        guard index != nil else {
            return
        }
        _array.remove(at: index!)
    }
}

class Handler {
    
    let _function: (Any) -> Void
    
    init(handlingFunction: @escaping (Any) -> Void) {
        _function = handlingFunction
    }
    
    func handle(_ argument: Any) {
        _function(argument)
    }
}
