//
//  GameViewModel2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Observation
import Combine
import Domain
import Presentation

@Observable
final class GameViewModel2 {
    private(set) var timeCountText: String = ""
    private(set) var currentWeaponType: WeaponType = .defaultType
    private(set) var bulletsCountImageName: String = ""

    var isWeaponChangeButtonEnabled = false
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented: (isPresented: Bool, score: Double) = (false, 0.0)
    
    private let presenter: GamePresenter2
    private var cancellables: Set<AnyCancellable> = []

    init(presenter: GamePresenter2) {
        self.presenter = presenter
        
        presenter.timeCountTextPublisher
            .sink { [weak self] timeCountText in
                self?.timeCountText = timeCountText
            }
            .store(in: &cancellables)

        presenter.currentWeaponTypePublisher
            .sink { [weak self] currentWeaponType in
                self?.currentWeaponType = currentWeaponType
            }
            .store(in: &cancellables)
        
        presenter.bulletsCountPublisher
            .sink { [weak self] bulletsCount in
                let imageName = (self?.currentWeaponType.resources.bulletsCountImageBaseName ?? "") + bulletsCount
                self?.bulletsCountImageName = imageName
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
    
    func weaponSelected(weaponType: WeaponType) {
        presenter.weaponSelected(weaponType: weaponType)
    }
}
