//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Observation
import Domain
import Presentation
import SwiftUI

@Observable
@MainActor
final class GameViewModel {
    var timeCountText: String {
        return presenter.timeCountText
    }
    var currentWeaponType: WeaponType {
        return presenter.currentWeaponType
    }
    var sightImageName: String {
        return currentWeaponType.resources.sightImageName
    }
    var sightImageColor: Color {
        return currentWeaponType.resources.sightImageColor
    }
    var bulletsCountImageName: String {
        return currentWeaponType.resources.bulletsCountImageName(presenter.bulletsCount)
    }
    var isWeaponChangeButtonEnabled: Bool {
        return presenter.isWeaponChangeButtonEnabled
    }

    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented: (isPresented: Bool, score: Double) = (false, 0.0)
    
    private let presenter: GamePresenter

    init(presenter: GamePresenter) {
        self.presenter = presenter
        
        Task {
            for await _ in presenter.showTutorialViewStream {
                isTutorialViewPresented = true
            }
        }
        
        Task {
            for await _ in presenter.showWeaponSelectViewStream {
                isWeaponSelectViewPresented = true
            }
        }
        
        Task {
            for await _ in presenter.closeWeaponSelectViewStream {
                isWeaponSelectViewPresented = false
            }
        }
        
        Task {
            for await score in presenter.showResultViewStream {
                isResultViewPresented = (true, score)
            }
        }
    }
    
    func onViewAppear() {
        presenter.onViewAppear()
    }
    
    func onViewDisappear() {
        presenter.onViewDisappear()
    }
    
    func tutorialEnded() {
        presenter.tutorialEnded()
    }
    
    func weaponChangeButtonTapped() {
        presenter.weaponChangeButtonTapped()
    }
    
    func weaponSelected(weaponType: WeaponType) {
        presenter.weaponSelected(weaponType: weaponType)
    }
}
