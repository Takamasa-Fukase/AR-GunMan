//
//  Encodable+Extension.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation

extension Encodable {
    func toJson() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else { return [:] }
        return dict
    }
}
