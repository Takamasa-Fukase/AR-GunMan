//
//  SettingsViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 17/12/24.
//

import Foundation
import Observation
import Combine

@Observable
final class SettingsViewModel {
    var isRankingViewPresented = false
    var isPrivacyPolicyViewPresented = false
    var isDeveloperContactViewPresented = false
    
    let dismiss = PassthroughSubject<Void, Never>()

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
        dismiss.send(())
    }
}
