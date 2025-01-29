//
//  CustomError.swift
//  Core
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation

public enum CustomError: Error {
    case apiClientError(Error)
    case networkError(Error)
    case other(message: String)
    
    public var title: String {
        switch self {
        default:
            return ErrorConst.defaultAlertTitle
        }
    }
    
    public var message: String {
        switch self {
        case .apiClientError(let error), .networkError(let error):
            return error.localizedDescription
        case .other(message: let message):
            return message
        }
    }
}
