//
//  ReplayRepositoryInterface.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import RxSwift

protocol ReplayRepositoryInterface {
    func getNeedsReplay() -> Observable<Bool>
    func setNeedsReplay(_ newValue: Bool) -> Observable<Void>
}
