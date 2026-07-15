//
//  GameSessionStoreInterface.swift
//  Data
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation
import Domain

public protocol GameSessionStoreInterface {
    var session: GameSession { get set }
}
