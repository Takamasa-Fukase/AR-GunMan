//
//  ReloadingMotionDetectedCount.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/19.
//

import Foundation

public struct ReloadingMotionDetectedCount {
    private var count: Int = 0
    
    public init() {}

    public mutating func update() -> ReloadingMotionDetectedCountUpdateResult {
        count += 1
        if count == 20 {
            return .exceededLimit
        } else {
            return .notExceededLimit
        }
    }
}

public enum ReloadingMotionDetectedCountUpdateResult {
    case notExceededLimit
    case exceededLimit
}
