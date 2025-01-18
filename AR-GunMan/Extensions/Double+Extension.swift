//
//  Double+Extension.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Foundation

extension Double {
    var timeCountText: String {
        let strTimeCount = String(format: "%.2f", self)
        return self > 10 ? "\(strTimeCount)" : "0\(strTimeCount)"
    }
    
    var scoreText: String {
        // （例）100点（3桁）の時は少数を2桁にする -> 100.00
        // （例） 99点（2桁）の時は少数を3桁にする -> 99.999
        // （例）  9点（1桁）の時は少数を3桁にする ->  9.999
        let integerPartDigitsCount: Int = String(Int(self)).count
        let decimalPartDigitsCount: Int = {
            if integerPartDigitsCount <= 2 {
                return 3
            }else {
                return 2
            }
        }()
        return String(format: "%.\(decimalPartDigitsCount)f", self)
    }
}
