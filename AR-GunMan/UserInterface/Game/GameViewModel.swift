//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Observation
import Domain
import Presentation

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
            for await _ in presenter.showTutorialViewEvent {
                isTutorialViewPresented = true
            }
        }
        
        Task {
            for await _ in presenter.showWeaponSelectViewEvent {
                isWeaponSelectViewPresented = true
            }
        }
        
        Task {
            for await _ in presenter.closeWeaponSelectViewEvent {
                isWeaponSelectViewPresented = false
            }
        }
        
        Task {
            for await score in presenter.showResultViewEvent {
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
