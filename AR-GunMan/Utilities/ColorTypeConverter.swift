//
//  ColorTypeConverter.swift
//  Sample_AR-GunMan_Replace
//
//  Created by ウルトラ深瀬 on 10/11/24.
//

import SwiftUI
import DomainLayer

final class ColorTypeConverter {
    static func fromColorType(_ colorType: ColorType) -> Color {
        switch colorType {
        case .red:
            return Color(uiColor: .systemRed)
        case .green:
            return Color(uiColor: .systemGreen)
        }
    }
}
