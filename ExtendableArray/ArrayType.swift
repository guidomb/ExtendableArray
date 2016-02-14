//
//  ArrayType.swift
//  SplitArray
//
//  Created by Guido Marucci Blas on 2/13/16.
//  Copyright © 2016 guidomb. All rights reserved.
//

import Foundation

public protocol ArrayType: CollectionType {
    
    mutating func append(element: Self.Generator.Element)
    
    mutating func appendContentsOf(elements: [Self.Generator.Element])
    
    mutating func prepend(element: Self.Generator.Element)
    
    mutating func prependContentsOf(elements: [Self.Generator.Element])
    
}

public func ==<A: ArrayType, Element: Equatable where A.Generator.Element == Element>(lhs: A, rhs: A) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for (left, right) in zip(lhs, rhs) {
        if left != right {
            return false
        }
    }
    return true
}
