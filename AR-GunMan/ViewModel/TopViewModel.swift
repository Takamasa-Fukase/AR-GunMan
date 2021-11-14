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
}

class TopViewModel {
    
    //input
    var buttonTapped: AnyObserver<TopPageButtonTypes>
    
    //output
    var isShotButtonIcon: Observable<(TopPageButtonTypes, Bool)>
    var transit: Observable<TopPageButtonTypes>

    
    init() {
        
        //other
        func changeButtonIcon(type: TopPageButtonTypes) {
            _isShotButtonIcon.accept((type, true))
            AudioModel.playSound(of: .westernPistolShoot)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                _isShotButtonIcon.accept((type, false))
                _transit.accept(type)
            }
        }

        
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
        
        
    }
    
    
}
