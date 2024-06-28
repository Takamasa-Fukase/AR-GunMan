//
//  Encodable+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import Foundation

extension Encodable {
    func toJson() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else { return [:] }
        return dict
    }
}
