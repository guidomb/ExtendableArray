//
//  ExtendableArray.swift
//  SplitArray
//
//  Created by Guido Marucci Blas on 2/13/16.
//  Copyright © 2016 guidomb. All rights reserved.
//

import Foundation

public struct ExtendableArray<Element>: ArrayType, ArrayLiteralConvertible, ArrayConvertible {
    
    private var _left: [Element]
    private var _right: SplitArray<Element>
    private var _count: Int
    
    public var isEmpty: Bool {
        return _left.isEmpty && _right.isEmpty
    }
    
    public var count: Int {
        return _count
    }
    
    public var first: Element? {
        return _left.first ?? _right.first
    }
    
    public var startIndex: Int {
        if isEmpty {
            return 0
        } else if _left.isEmpty {
            return _right.endIndex
        } else {
            return _right.startIndex
        }
    }
    
    public var endIndex: Int {
        if isEmpty {
            return 0
        } else if _right.isEmpty {
            return _left.startIndex
        } else {
            return _right.endIndex
        }
    }
    
    public init(array: [Element]) {
        _left = []
        _right = SplitArray(array: array)
        _count = array.count
    }
    
    public init() {
        self.init(array: [])
    }
    
    public init(arrayLiteral elements: Element...) {
        self.init(array: elements)
    }
    
    public func generate() -> AnyGenerator<Element> {
        var leftGenerator = _left.reverse().generate()
        let rightGenerator = _right.generate()
        return anyGenerator { leftGenerator.next() ?? rightGenerator.next() }
    }
    
    public subscript (position: Int) -> Element {
        if !_left.isEmpty && position < count {
            return _left[count - position - 1]
        } else {
            return _right[position]
        }
    }
    
    public mutating func append(element: Element) {
        _right.append(element)
        _count += 1
    }
    
    public mutating func appendContentsOf(elements: [Element]) {
        _right.appendContentsOf(elements)
        _count += elements.count
    }
    
    public mutating func prepend(element: Element) {
        _left.append(element)
        _count += 1
    }
    
    public mutating func prependContentsOf(elements: [Element]) {
        _left.appendContentsOf(elements.reverse())
        _count += elements.count
    }
    
    public func toArray() -> [Element] {
        var array: [Element] = []
        array.appendContentsOf(_left.reverse())
        array.appendContentsOf(_right)
        return array
    }
    
    
}

private extension ExtendableArray {
    
    init(left: [Element], right: SplitArray<Element>) {
        _left = left
        _right = right
        _count = left.count + right.count
    }
    
}
