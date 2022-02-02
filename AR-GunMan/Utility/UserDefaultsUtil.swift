//
//  UserDefaultsUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/02.
//

import Foundation

class UserDefaultsUtil {
    //MARK: - setValue
    static func setTutorialSeen() {
        UserDefaults.standard.setValue(true, forKey: UserDefaultsKey.tutorialAlreadySeen)
    }
    
    //MARK: - getValue
    static func isTutorialAlreadySeen() -> Bool {
        return UserDefaults.standard.value(forKey: UserDefaultsKey.tutorialAlreadySeen) == nil
    }
}
