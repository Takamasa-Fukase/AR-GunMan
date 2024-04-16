//
//  UIImageView+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/1/23.
//

import UIKit

extension UIImageView {
    func setupAnimationImages(imageNames: [String],
                              duration: Double,
                              repeatCount: Int = 0) {
        var images: [UIImage] = []
        imageNames.forEach({ name in
            if let image = UIImage(named: name) {
                images.append(image)
            }
        })
        animationImages = images
        animationDuration = duration
        animationRepeatCount = repeatCount
        startAnimating()
    }
}
