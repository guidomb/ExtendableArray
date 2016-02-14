//
//  ArrayConvertible.swift
//  SplitArray
//
//  Created by Guido Marucci Blas on 2/13/16.
//  Copyright © 2016 guidomb. All rights reserved.
//

import Foundation

public protocol ArrayConvertible {
    
    typealias Element
    
    func toArray() -> [Element]
    
}
