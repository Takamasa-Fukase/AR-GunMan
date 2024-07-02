//
//  PresenterType.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import Foundation

protocol PresenterType {
    associatedtype ControllerEvents
    associatedtype ViewModel
    
    func transform(from input: ControllerEvents) -> ViewModel
}
