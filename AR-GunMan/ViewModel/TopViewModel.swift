//
//  TopViewModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import Foundation
import RxSwift
import RxCocoa

enum TopPageButtonTypes {
    case start
    case ranking
    case howToPlay
    case settings
}

class TopViewModel {
    
    //input
    let buttonTapped: AnyObserver<TopPageButtonTypes>
    
    //output
    let isShotButtonIcon: Observable<(TopPageButtonTypes, Bool)>
    let transit: Observable<TopPageButtonTypes>

    
    init() {
        
        //output
        let _isShotButtonIcon = PublishRelay<(TopPageButtonTypes, Bool)>()
        self.isShotButtonIcon = _isShotButtonIcon.asObservable()
        
        let _transit = PublishRelay<TopPageButtonTypes>()
        self.transit = _transit.asObservable()
        
        
        //input
        self.buttonTapped = AnyObserver<TopPageButtonTypes>() { event in
            guard let element = event.element else {return}
            changeButtonIcon(type: element)
        }
        
        
        //other
        func changeButtonIcon(type: TopPageButtonTypes) {
            switch type {
            case .start, .ranking, .howToPlay:
                _isShotButtonIcon.accept((type, true))
                AudioModel.playSound(of: .westernPistolShoot)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    _isShotButtonIcon.accept((type, false))
                    _transit.accept(type)
                }
            case .settings:
                AudioModel.playSound(of: .bazookaSet)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    //TODO: - 後で良い画像素材が見つかればsettingsのアイコンも画像変えギミックを追加したい
                    _transit.accept(type)
                }
            }
        }

    }
    
    
}
