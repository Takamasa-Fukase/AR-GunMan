//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Observation
import Combine
import Domain
import Presentation

@Observable
final class GameViewModel {
    private(set) var timeCount: Double = 0
    private(set) var currentWeapon: LoadedWeapon?
    var isWeaponChangeButtonEnabled = false
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented: (isPresented: Bool, score: Double) = (false, 0.0)
    
    private let presenter: GamePresenter
    private var cancellables: Set<AnyCancellable> = []

    init(presenter: GamePresenter) {
        self.presenter = presenter
        
        presenter.timeCountPublisher
            .sink { [weak self] timeCount in
                self?.timeCount = timeCount
            }
            .store(in: &cancellables)
        
        presenter.currentWeaponPublisher
            .sink { [weak self] currentWeapon in
                self?.currentWeapon = currentWeapon
            }
            .store(in: &cancellables)
        
        presenter.isWeaponChangeButtonEnabledPublisher
            .sink { [weak self] isEnabled in
                self?.isWeaponChangeButtonEnabled = isEnabled
            }
            .store(in: &cancellables)
        
        presenter.isTutorialViewPresentedPublisher
            .sink { [weak self] isPresented in
                self?.isTutorialViewPresented = isPresented
            }
            .store(in: &cancellables)
        
        presenter.isWeaponSelectViewPresentedPublisher
            .sink { [weak self] isPresented in
                self?.isWeaponSelectViewPresented = isPresented
            }
            .store(in: &cancellables)
        
        presenter.isResultViewPresentedPublisher
            .sink { [weak self] isPresented in
                self?.isResultViewPresented = isPresented
            }
            .store(in: &cancellables)
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
    
    func weaponSelected(weaponId: Int) {
        presenter.weaponSelected(weaponId: weaponId)
    }
}
