//
//  SoundPlayerInterface.swift
//  DeviceInterface
//
//  Created by ウルトラ深瀬 on 2026/06/10.
//

import Foundation

public protocol SoundPlayerInterface: AnyObject {
    func play(_ sound: SoundType)
}
