//
//  PriorityQueueEntry.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 20/2/25.
//
import Foundation

struct PriorityQEntry: Hashable {
    var vertex: Cell
    var originVertex: Cell?
    var Distance: Int
    var cost: CGFloat = 1000.00
}
