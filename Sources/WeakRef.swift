//
//  WeakRef.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/16/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Weak reference object allows to "convert" object to weak object
/// to use it for example in an array, been nil when the object
/// is deallocated.
struct WeakRef<T: AnyObject> {

    weak var object: T?

    var description: String {
        if let object = object {
            return "Weak(" + String(reflecting: object) + ")"
        } else {
            return "nil"
        }
    }

    init(_ object: T?) {
        self.object = object
    }

    init() {
        object = nil
    }
}
