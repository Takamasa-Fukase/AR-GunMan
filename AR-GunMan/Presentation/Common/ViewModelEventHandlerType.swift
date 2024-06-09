//
//  ViewModelEventHandlerType.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import Foundation

protocol ViewModelEventHandlerType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
