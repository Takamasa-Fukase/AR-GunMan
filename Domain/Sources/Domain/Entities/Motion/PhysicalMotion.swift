//
//  PhysicalMotion.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/24.
//

import Foundation

public struct PhysicalMotion {
    public enum MotionType {
        case acceleration, gyro
    }
    enum Dimension {
        case x, y, z
    }
    struct DimensionAndValue: Hashable {
        let dimension: Dimension
        let value: Double
    }
    
    let type: MotionType
    
    private let values: Set<DimensionAndValue>
    
    public init(type: MotionType, x: Double, y: Double, z: Double) {
        self.type = type
        values = [
            DimensionAndValue(dimension: .x, value: x),
            DimensionAndValue(dimension: .y, value: y),
            DimensionAndValue(dimension: .z, value: z)
        ]
    }
    
    func getCompositeValue(of dimensions: Set<Dimension>) -> Double {
        return dimensions.reduce(0) { partialResult, dimension in
            let value = values.first(where: { $0.dimension == dimension })?.value ?? 0.0
            let composite = (value * value)
            return partialResult + (composite)
        }
    }
}
