//
//  KeyboardOverlapCalculator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/6/24.
//

import UIKit

final class KeyboardOverlapCalculator {
    static func calculate(
        keyboardFrameEnd: CGRect,
        activieTextField: UITextField,
        backgroundView: UIView
    ) -> (isTextFieldOverlapped: Bool, overlap: CGFloat) {
        let keyboardY = backgroundView.frame.size.height - keyboardFrameEnd.height
        let textFieldY = activieTextField.convert(activieTextField.frame, to: backgroundView).maxY
        let keyboardOverlap = textFieldY - keyboardY
        return (
            isTextFieldOverlapped: keyboardOverlap > 0,
            overlap: keyboardOverlap
        )
    }
}
