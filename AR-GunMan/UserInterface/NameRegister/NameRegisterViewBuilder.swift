//
//  NameRegisterViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation
import Combine
import Domain
import Presentation

struct NameRegisterViewBuilder {
    private init() {}

    @MainActor static func build(
        score: Double,
        dismissRequestReceiver: DismissRequestReceiver,
        onRegistered: @escaping () -> Void
    ) -> NameRegisterView {
        let viewModel = NameRegisterViewModel(
            rankingRegisterUseCase: Factory.create(),
            rankingStore: RankingStore.shared,
            score: score
        )
        return NameRegisterView(
            viewModel: viewModel,
            dismissRequestReceiver: dismissRequestReceiver,
            onRegistered: onRegistered
        )
    }
}
