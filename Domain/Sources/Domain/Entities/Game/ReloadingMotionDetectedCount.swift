//
//  ReloadingMotionDetectedCount.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/19.
//

import Foundation

public struct ReloadingMotionDetectedCount {
    public enum Result {
        case notExceededLimit
        case exceededLimit
    }
    
    public private(set) var count: Int = 0
    
    mutating func update() -> Result {
        count += 1
        if count == 20 {
            return .exceededLimit
        } else {
            return .notExceededLimit
        }
    }
}
