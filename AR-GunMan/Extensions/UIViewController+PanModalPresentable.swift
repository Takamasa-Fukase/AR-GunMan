//
//  UIViewController+PanModalPresentable.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 10/6/24.
//

import Foundation
import PanModal

extension UIViewController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        nil
    }
    
    public var topOffset: CGFloat {
        return 0.0
    }

    public var springDamping: CGFloat {
        return 1.0
    }

    public var transitionDuration: Double {
        return 0.4
    }

    public var transitionAnimationOptions: UIView.AnimationOptions {
        return [.allowUserInteraction, .beginFromCurrentState]
    }

    public var shouldRoundTopCorners: Bool {
        return false
    }

    public var showDragIndicator: Bool {
        return false
    }
    
    public var longFormHeight: PanModalHeight {
        return .maxHeight
    }
}
