//
//  TopPageButtonIconChanger.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 17/1/23.
//

import RxSwift
import RxCocoa

class TopPageButtonImageSwitcher {
    typealias Image = (type: TopPageButtonType, isSwitched: Bool)
    
    var image: Observable<Image> {
        return imageRelay.asObservable()
    }
    
    private let imageRelay = PublishRelay<Image>()
    
    func switchAndRevert(of type: TopPageButtonType) {
        AudioUtil.playSound(of: type.iconChangingSound)
        imageRelay.accept(Image(type: type, isSwitched: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + type.iconRevertInterval) {
            self.imageRelay.accept(Image(type: type, isSwitched: false))
        }
    }
}
