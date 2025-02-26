//
//  Cell.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 13/2/25.
//


import Foundation

struct Cell: Hashable, Equatable {
    var x: Int
    var y: Int
    // This will show whether the neighbouring cells are connected to each other.
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false 
    // This will update when it has being processed by the algorithms
    var visited: Bool = false
    var solution: Bool = false
}
