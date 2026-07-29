//
//  ViewConst.swift
//  Presentation
//
//  Created by ウルトラ深瀬 on 2026/07/29.
//

import Foundation

public struct TopViewConst {
    public static let buttonTitleStart = "Start"
    public static let buttonTitleSettings = "Settings"
    public static let buttonTitleHowToPlay = "HowToPlay"
    public static let cameraPermissionAlertTitle = "Camera Permission Required"
    public static let cameraPermissionAlertMessage = "Camera Permission is required to play this game.\nDo you want to change your settings?"
    public static let cameraPermissionAlertButtonTitleYes = "Yes"
    public static let cameraPermissionAlertButtonTitleNo = "Not now"
}

public struct GameViewConst {
    
}

public struct SettingsViewConst {
    
}

public struct TutorialViewConst {
    
}

public struct RankingViewConst {
    
}

public struct WeaponSelectViewConst {
    
}

public struct ResultViewConst {
    
}

public struct NameRegisterViewConst {
    public static let labelTitle = "Congratulations!"
    public static let labelMessage1 = "You're ranked at "
    public static let labelMessage2 = " in"
    public static let labelMessage3 = "the world!"
    public static func labelScore(_ scoreText: String) -> String {
        return "Score: \(scoreText)"
    }
    public static let labelName = "Name:"
    public static let buttonTitleRegister = "Register!"
    public static let buttonTitleNo = "No, thanks"
}
