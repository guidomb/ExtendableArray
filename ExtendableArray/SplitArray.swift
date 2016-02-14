//
//  SplitArray.swift
//  SplitArray
//
//  Created by Guido Marucci Blas on 2/9/16.
//  Copyright © 2016 guidomb. All rights reserved.
//

import Foundation

public struct SplitArray<Element>:
    CollectionType,
    ArrayLiteralConvertible,
    ArrayType,
    ArrayConvertible {
    
    private var container: SplitArrayContainer<Element>
    
    public var isEmpty: Bool {
        switch container {
        case .Empty: return true
        default: return false
        }
    }
    
    public var count: Int {
        switch container {
        case .Empty: return 0
        case .Full(let elements): return elements.count
        case .Split(let left, let right): return left.count + right.count
        }
    }
    
    public var first: Element? {
        switch container {
        case .Empty: return Optional.None
        case .Full(let elements): return elements.first
        case .Split(let left, let right): return left.first ?? right.first
        }
    }
    
    public var startIndex: Int {
        switch container {
        case .Empty: return 0
        case .Full(let elements): return elements.startIndex
        case .Split(let left, let right) where left.isEmpty: return right.startIndex
        case .Split(let left, _): return left.startIndex
        }
    }
    
    public var endIndex: Int {
        switch container {
        case .Empty: return 0
        case .Full(let elements): return elements.endIndex
        case .Split(let left, let right) where right.isEmpty: return left.endIndex
        case .Split(_, let right): return right.endIndex
        }
    }
    
    public init(array: [Element]) {
        if array.isEmpty {
            container = .Empty
        } else {
            container = .Full(array)
        }
    }
    
    public init() {
        self.init(array: [])
    }
    
    public init(arrayLiteral elements: Element...) {
        self.init(array: elements)
    }
    
    public func generate() -> AnyGenerator<Element> {
        switch container {
        case .Empty:
            return anyGenerator { Optional.None }
        case .Full(let elements):
            var generator = elements.generate()
            return anyGenerator { generator.next() }
        case .Split(let left, let right):
            let leftGenerator = left.generate()
            let rightGenerator = right.generate()
            return anyGenerator { leftGenerator.next() ?? rightGenerator.next() }
        }
    }
    
    public subscript (position: Int) -> Element {
        switch container {
        case .Empty: return Array<Element>()[position]
        case .Full(let elements): return elements[position]
        case .Split(let left, _) where position < left.count: return left[position]
        case .Split(let left, let right): return right[position - left.count]
        }
    }
    
    public mutating func append(element: Element) {
        appendContentsOf([element])
    }
    
    public mutating func appendContentsOf(elements: [Element]) {
        switch container {
        case .Empty: container = .Full(elements)
        case .Full(let left): container = SplitArrayContainer(left: left, right: elements)
        case .Split(let left, let right): container = left + right + elements
        }
    }
    
    public mutating func prepend(element: Element) {
        return prependContentsOf([element])
    }
    
    public mutating func prependContentsOf(elements: [Element]) {
        switch container {
        case .Empty: container = .Full(elements)
        case .Full(let right): container = SplitArrayContainer(left: elements, right: right)
        case .Split(let left, let right): container = elements + left + right
        }
    }
    
    public func toArray() -> [Element] {
        switch container {
        case .Empty: return []
        case .Full(let array): return array
        case .Split(let left, let right):
            var array = left.toArray()
            array.appendContentsOf(right.toArray())
            return array
        }
    }
    
    func compact(limit: UInt64 = UINT64_MAX) -> SplitArray {
        switch container {
        case .Split(_, _) where limit == UINT64_MAX:
            return SplitArray(array: toArray())
        case .Split(let left, let right) where UInt64(left.count) < limit && UInt64(right.count) < limit:
            return left.compact() + right.compact()
        case .Split(let left, let right) where UInt64(left.count) < limit:
            return left.compact() + right
        case .Split(let left, let right) where UInt64(right.count) < limit:
            return left + right.compact()
        default:
            return self
        }
    }
    
}

private extension SplitArray {
    
    init(container: SplitArrayContainer<Element>) {
        switch container {
        case .Full(let elements) where elements.isEmpty: self.container = .Empty
        case .Split(let left, let right) where left.isEmpty && right.isEmpty: self.container = .Empty
        case .Split(let left, let right) where left.isEmpty: self.container = right.container
        case .Split(let left, let right) where right.isEmpty: self.container = left.container
        default: self.container = container
        }
    }
    
    init(left: [Element], right: [Element]) {
        self.init(container: .Split(SplitArray(array: left), SplitArray(array: right)))
    }
    
}


private enum SplitArrayContainer<Element> {
    
    case Empty
    case Full([Element])
    indirect case Split(SplitArray<Element>, SplitArray<Element>)
    
    init(left: [Element], right: [Element]) {
        if left.isEmpty && right.isEmpty {
            self = .Empty
        } else if left.isEmpty {
            self = .Full(right)
        } else {
            self = .Full(left)
        }
    }
    
}

infix operator + { associativity left precedence 140 }

private func +<Element>(lhs: SplitArray<Element>, rhs: SplitArray<Element>) -> SplitArrayContainer<Element> {
    return .Split(lhs, rhs)
}

private func +<Element>(lhs: SplitArray<Element>, rhs: [Element]) -> SplitArrayContainer<Element> {
    return .Split(lhs, SplitArray(array:rhs))
}

private func +<Element>(lhs: [Element], rhs: SplitArray<Element>) -> SplitArrayContainer<Element> {
    return .Split(SplitArray(array:lhs), rhs)
}

public func +<Element>(lhs: SplitArray<Element>, rhs: SplitArray<Element>) -> SplitArray<Element> {
    return SplitArray(container: .Split(lhs, rhs))
}

public func +<Element>(lhs: SplitArray<Element>, rhs: [Element]) -> SplitArray<Element> {
    return SplitArray(container: lhs + rhs)
}

public func +<Element>(lhs: [Element], rhs: SplitArray<Element>) -> SplitArray<Element> {
    return SplitArray(container: lhs + rhs)
}
