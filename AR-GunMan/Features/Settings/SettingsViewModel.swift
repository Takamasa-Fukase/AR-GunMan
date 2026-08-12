//
//  SettingsViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 17/12/24.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    enum OutputEventType {
        case dismiss
    }
    
    let outputEvent: AsyncStream<OutputEventType>
    var isRankingViewPresented = false
    var isPrivacyPolicyViewPresented = false
    var isDeveloperContactViewPresented = false
    
    private let outputEventContinuation: AsyncStream<OutputEventType>.Continuation
    
    init() {
        (outputEvent, outputEventContinuation) = AsyncStream.makeStream()
    }
    
    func worldRankingButtonTapped() {
        isRankingViewPresented = true
    }
    
    func privacyPolicyButtonTapped() {
        isPrivacyPolicyViewPresented = true
    }
    
    func contactDeveloperButtonTapped() {
        isDeveloperContactViewPresented = true
    }
    
    func backButtonTapped() {
        outputEventContinuation.yield(.dismiss)
    }
}
