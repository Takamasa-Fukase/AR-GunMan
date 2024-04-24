//
//  CustomError.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/24.
//

import UIKit

enum CustomError: Error {
    case apiClientError(Error)
    case networkError(Error)
    case manualError(String?)
    
    var alert: UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alertActions.forEach({ alert.addAction($0) })
        return alert
    }
    
    private var title: String {
        switch self {
        default:
            return ErrorConst.defaultAlertTitle
        }
    }
    
    private var message: String? {
        switch self {
        case .apiClientError(let error), .networkError(let error):
            return error.localizedDescription
        case .manualError(let message):
            return message
        }
    }
    
    private var alertActions: [UIAlertAction] {
        switch self {
        default:
            return [.init(title: ErrorConst.defaultCloseButtonTitle, style: .default)]
        }
    }
}
