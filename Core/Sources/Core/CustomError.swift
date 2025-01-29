//
//  CustomError.swift
//  WeaponFiringSimulator
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation

enum CustomError: Error {
    case apiClientError(Error)
    case networkError(Error)
    case other(message: String)
}
