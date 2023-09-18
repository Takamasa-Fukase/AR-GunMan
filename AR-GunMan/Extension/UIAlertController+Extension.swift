//
//  UIAlertController+Extension.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2023/09/18.
//

import UIKit

extension UIAlertController {
    static func errorAlert(_ error: Error) -> UIAlertController {
        let alert = UIAlertController(title: "エラーが発生しました",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "閉じる",
                              style: .default))
        return alert
    }
}
