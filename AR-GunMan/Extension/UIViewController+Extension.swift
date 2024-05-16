//
//  UIViewController+Extension.swift
//  AR-GunMan
//
//  Created by Takahiro Fukase on 2021/11/27.
//

import UIKit
import PanModal

extension UIViewController {
    func insertBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.frame
        view.insertSubview(visualEffectView, at: 0)
    }
}
