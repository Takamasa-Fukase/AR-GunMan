//
//  UIScrollView+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/1/23.
//

import UIKit

extension UIScrollView {
    var horizontalPageIndex: Int {
        return Int(round(contentOffset.x / frame.width))
    }
    
    func scrollHorizontallyToNextPage(animated: Bool = true) {
        let maxPageIndex = Int((contentSize.width / frame.width) - 1)
        let targetIndex = CGFloat(min(horizontalPageIndex + 1, maxPageIndex))
        let targetContentOffsetX = frame.width * targetIndex
        let targetCGPoint = CGPoint(x: targetContentOffsetX, y: 0)
        setContentOffset(targetCGPoint, animated: animated)
    }
}
