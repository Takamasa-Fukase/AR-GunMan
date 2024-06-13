//
//  UIView+Constraint.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 13/6/24.
//

import UIKit

extension UIView {
    func addConstraints(for childView: UIView, insets: UIEdgeInsets = .zero) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: childView.topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(equalTo: childView.bottomAnchor, constant: insets.bottom).isActive = true
        leadingAnchor.constraint(equalTo: childView.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(equalTo: childView.trailingAnchor, constant: insets.right).isActive = true
    }
}
