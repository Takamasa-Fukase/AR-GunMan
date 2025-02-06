//
//  TopViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/12/24.
//

import Foundation
import Observation
import Combine
import Domain

@Observable
final class TopViewModel {
    enum OutputEventType {
        case playSound(SoundType)
    }
    enum IconButtonType {
        case start
        case settings
        case howToPlay
    }
    
    private(set) var isStartButtonIconSwitched = false
    private(set) var isSettingsButtonIconSwitched = false
    private(set) var isHowToPlayButtonIconSwitched = false
    var isPermissionRequiredAlertPresented = false
    var isGameViewPresented = false
    var isSettingsViewPresented = false
    var isTutorialViewPresented = false
    
    let outputEvent = PassthroughSubject<OutputEventType, Never>()

    private let permissionRepository: PermissionRepositoryInterface
    
    init(permissionRepository: PermissionRepositoryInterface) {
        self.permissionRepository = permissionRepository
    }
    
    func onViewAppear() {
        permissionRepository.requestCameraUsagePermission()
    }

    func startButtonTapped() {
        switchButtonIconAndRevert(type: .start)
    }
    
    func settingsButtonTapped() {
        switchButtonIconAndRevert(type: .settings)
    }
    
    func howToPlayButtonTapped() {
        switchButtonIconAndRevert(type: .howToPlay)
    }
    
    private func switchButtonIconAndRevert(type: IconButtonType) {
        outputEvent.send(.playSound(.westernPistolFire))
        
        switch type {
        case .start:
            isStartButtonIconSwitched = true
        case .settings:
            isSettingsButtonIconSwitched = true
        case .howToPlay:
            isHowToPlayButtonIconSwitched = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            switch type {
            case .start:
                self.isStartButtonIconSwitched = false
                
                let isCameraPermissionGranted = self.permissionRepository.getCameraUsagePermissionGrantedFlag()
                if isCameraPermissionGranted {
                    self.isGameViewPresented = true
                }else {
                    self.isPermissionRequiredAlertPresented = true
                }
                
            case .settings:
                self.isSettingsButtonIconSwitched = false
                self.isSettingsViewPresented = true
                
            case .howToPlay:
                self.isHowToPlayButtonIconSwitched = false
                self.isTutorialViewPresented = true
            }
        })
    }
}
