//
//  UIView+NibLoading.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import UIKit

extension UIView {
    func loadNib() {
        let nib = UINib(nibName: Self.className, bundle: nil)
        guard let view = nib.instantiate(withOwner: self).first as? UIView else { return }
        addSubview(view)
        addConstraints(for: view)
    }
}
