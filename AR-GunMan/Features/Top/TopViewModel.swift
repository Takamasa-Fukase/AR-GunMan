//
//  TopViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/12/24.
//

import Foundation
import Observation
import Device

@MainActor
@Observable
final class TopViewModel {
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
    
    private let cameraPermissionHandler: CameraPermissionHandlerInterface
    private let soundPlayer: SoundPlayerInterface

    init(
        cameraPermissionHandler: CameraPermissionHandlerInterface,
        soundPlayer: SoundPlayerInterface
    ) {
        self.cameraPermissionHandler = cameraPermissionHandler
        self.soundPlayer = soundPlayer
    }
    
    func onViewAppear() {
        cameraPermissionHandler.requestCameraUsagePermission()
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
        soundPlayer.play(.westernPistolFire)
        
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
                
                let isCameraPermissionGranted = self.cameraPermissionHandler.getCameraUsagePermissionGrantedFlag()
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
