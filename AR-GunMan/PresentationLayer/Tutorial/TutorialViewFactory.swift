//
//  TutorialViewFactory.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation

final class TutorialViewFactory {
    static func create(dismissRequestReceiver: DismissRequestReceiver? = nil) -> TutorialView {
        let viewModel = TutorialViewModel()
        return TutorialView(viewModel: viewModel, dismissRequestReceiver: dismissRequestReceiver)
    }
}
