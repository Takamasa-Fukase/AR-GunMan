//
//  UIViewController+Extension.swift
//  AR-GunMan
//
//  Created by Takahiro Fukase on 2021/11/27.
//

import UIKit

extension UIViewController {
    func insertBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.frame
        view.insertSubview(visualEffectView, at: 0)
    }
    
    func handleActiveTextFieldOverlapWhenKeyboardWillShow(
        keyboardFrameEnd: CGRect,
        keyboardAnimationDuration: TimeInterval,
        activeTextField: UITextField,
        inset: Int = 6
    ) {
        let overlapCalcultaionResult = KeyboardOverlapCalculator.calculate(
            keyboardFrameEnd: keyboardFrameEnd,
            activieTextField: activeTextField,
            backgroundView: view
        )
        guard overlapCalcultaionResult.isTextFieldOverlapped else { return }
        let distanceToMove = -(overlapCalcultaionResult.overlap) - CGFloat(inset)
        let transform = CGAffineTransform(translationX: 0, y: distanceToMove)
        transformView(transform, with: keyboardAnimationDuration)
    }
    
    func transformView(_ transform: CGAffineTransform, with duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.transform = transform
        }
    }
    
    func resetViewTransform(with duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.transform = CGAffineTransform.identity
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
