//
//  Array+withReplaced.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 09.07.2026.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}
