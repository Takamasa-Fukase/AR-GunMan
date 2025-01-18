//
//  TutorialConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation

struct TutorialContent: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let imageNames: [String]
}

final class TutorialConst {
    static let contents: [TutorialContent] = [
        .init(
            title: "SHOOT",
            description: "Push device towards targets",
            imageNames: [
                "how_to_shoot_0",
                "how_to_shoot_1"
            ]
        ),
        .init(
            title: "RELOAD",
            description: "Rotate device",
            imageNames: [
                "how_to_reload_0",
                "how_to_reload_1"
            ]
        ),
        .init(
            title: "CHANGE WEAPON",
            description: "Tap this icon",
            imageNames: [
                "how_to_change_weapon"
            ]
        )
    ]
}
