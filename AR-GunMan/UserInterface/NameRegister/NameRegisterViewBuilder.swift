//
//  NameRegisterViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation
import Combine
import Domain

struct NameRegisterViewBuilder {
    private init() {}

    static func build(
        score: Double,
        temporaryRankTextSubject: CurrentValueSubject<String, Never>,
        dismissRequestReceiver: DismissRequestReceiver,
        onRegistered: @escaping (Ranking) -> Void
    ) -> NameRegisterView {
        let viewModel = NameRegisterViewModel(
            rankingUseCase: Factory.create(),
            score: score,
            temporaryRankTextSubject: temporaryRankTextSubject
        )
        return NameRegisterView(
            viewModel: viewModel,
            dismissRequestReceiver: dismissRequestReceiver,
            onRegistered: onRegistered
        )
    }
}
