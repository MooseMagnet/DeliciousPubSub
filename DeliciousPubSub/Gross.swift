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
    
    func append(element: T) {
        _array.append(element)
    }
    
    func remove(element: T) {
        _array.removeAtIndex(
            _array.indexOf({ (thisElement) -> Bool in
                return thisElement === element
            })!
        )
    }
}

class Handler {
    
    let _function: Any -> Void
    
    init(handlingFunction: Any -> Void) {
        _function = handlingFunction
    }
    
    func handle(argument: Any) {
        _function(argument)
    }
}