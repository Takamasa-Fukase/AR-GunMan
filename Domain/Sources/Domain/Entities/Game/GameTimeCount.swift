//
//  GameTimeCount.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/19.
//

import Foundation

public struct GameTimeCount {
    static let updateIntervalMillisec: Int = 10
    
    public private(set) var countMillisec: Int = 30000
    
    var isTimeUp: Bool {
        return countMillisec <= 0
    }
        
    public init() {}

    mutating func decrement() {
        countMillisec = max(0, countMillisec - GameTimeCount.updateIntervalMillisec)
    }
}
