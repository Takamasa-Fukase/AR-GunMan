//
//  TutorialViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation
import Observation

@MainActor
@Observable
final class TutorialViewModel {
    enum OutputEventType {
        case scrollToPageIndex(index: Int)
        case dismiss
    }
    
    let contents: [TutorialContent] = TutorialConst.contents
    let outputEvent: AsyncStream<OutputEventType>
    private(set) var currentPageIndex: Int = 0
    private(set) var buttonTitle: String = "NEXT"
    
    private let outputEventContinuation: AsyncStream<OutputEventType>.Continuation
    
    private var isLastPage: Bool {
        return currentPageIndex == (contents.count - 1)
    }
    
    init() {
        (outputEvent, outputEventContinuation) = AsyncStream.makeStream()
    }
    
    func onScroll(_ contentFrame: CGRect) {
        currentPageIndex = abs(Int(round(contentFrame.minX / (contentFrame.width / CGFloat(contents.count)))))
        if isLastPage {
            buttonTitle = "OK"
        }else {
            buttonTitle = "NEXT"
        }
    }
    
    func buttonTapped() {
        if isLastPage {
            outputEventContinuation.yield(.dismiss)
        }else {
            outputEventContinuation.yield(.scrollToPageIndex(index: currentPageIndex + 1))
        }
    }
    
    func backgroundViewTapped() {
        outputEventContinuation.yield(.dismiss)
    }
}
