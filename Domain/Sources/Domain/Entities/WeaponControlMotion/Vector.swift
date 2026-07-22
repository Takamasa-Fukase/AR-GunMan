//
//  Vector.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation

public struct Vector {
    struct DimensionAndValue: Hashable {
        let dimension: Dimension
        let value: Double
    }
    enum Dimension {
        case x
        case y
        case z
    }
    
    private let values: Set<DimensionAndValue>
    
    public init(x: Double, y: Double, z: Double) {
        values = [
            DimensionAndValue(dimension: .x, value: x),
            DimensionAndValue(dimension: .y, value: y),
            DimensionAndValue(dimension: .z, value: z)
        ]
    }
    
    func getComposite(of dimensions: Set<Dimension>) -> Double {
        return dimensions.reduce(0) { partialResult, dimension in
            let value = values.first(where: { $0.dimension == dimension })?.value ?? 0.0
            let composite = (value * value)
            return partialResult + (composite)
        }
    }
}
