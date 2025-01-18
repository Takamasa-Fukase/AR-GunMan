//
//  TutorialViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation
import Observation
import Combine

@Observable
final class TutorialViewModel {
    let contents: [TutorialContent] = TutorialConst.contents
    private(set) var currentPageIndex: Int = 0
    private(set) var buttonTitle: String = "NEXT"
    
    let scrollToPageIndex = PassthroughSubject<Int, Never>()
    let dismiss = PassthroughSubject<Void, Never>()
    
    func onScroll(_ contentFrame: CGRect) {
        currentPageIndex = abs(Int(round(contentFrame.minX / (contentFrame.width / CGFloat(contents.count)))))
        if isLastPage() {
            buttonTitle = "OK"
        }else {
            buttonTitle = "NEXT"
        }
    }
    
    func buttonTapped() {
        if isLastPage() {
            dismiss.send(Void())
        }else {
            scrollToPageIndex.send(currentPageIndex + 1)
        }
    }
    
    func backgroundViewTapped() {
        dismiss.send(Void())
    }
    
    private func isLastPage() -> Bool {
        return currentPageIndex == (contents.count - 1)
    }
}
