//
//  ViewModelType.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype State
    
    func transform(input: Input) -> Output
}
