//
//  UserDefaultsClientInterface.swift
//  Data
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Combine

public protocol UserDefaultsClientInterface {
    var isTutorialCompleted: Bool { get set }
}
