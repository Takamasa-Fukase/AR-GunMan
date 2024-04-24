//
//  UIAlertController+Extension.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2023/09/18.
//

import UIKit

extension UIAlertController {
    static func errorAlert(_ error: Error) -> UIAlertController {
        if let customError = error as? CustomError {
            return customError.alert
        }else {
            let alert = UIAlertController(title: ErrorConst.defaultAlertTitle,
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(.init(title: ErrorConst.defaultCloseButtonTitle, style: .default))
            return alert
        }
    }
}
