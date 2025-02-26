//
//  IsSortedExtension.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 22/2/25.
//
import Foundation

extension Array {
    func isSorted(isOrderedBefore: (Element, Element) -> Bool) -> Bool {
        for i in 1..<self.count {
            if !isOrderedBefore(self[i-1], self[i]) {
                return false
            }
        }
        return true
    }
}

