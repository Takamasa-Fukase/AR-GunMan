//
//  ReloadMotionDetectionCountUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct ReloadMotionDetectionCountInput {
    let currentCountWhenReloadMotionDetected: Observable<Int>
}

struct ReloadMotionDetectionCountOutput {
    let updateCount: Observable<Int>
    let changeTargetsAppearance: Observable<Void>
}

protocol ReloadMotionDetectionCountUseCaseInterface {
    func transform(
        input: ReloadMotionDetectionCountInput
    ) -> ReloadMotionDetectionCountOutput
}

final class ReloadMotionDetectionCountUseCase: ReloadMotionDetectionCountUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(
        input: ReloadMotionDetectionCountInput
    ) -> ReloadMotionDetectionCountOutput {
        // 🟥 Stateの更新指示<検知回数を+1>
        let updateCount = input.currentCountWhenReloadMotionDetected
            .map({ $0 + 1 })
                
        // 的の見た目変更指示
        let changeTargetsAppearance = input.currentCountWhenReloadMotionDetected
            .filter({ $0 == GameConst.targetsAppearanceChangingLimit })
            .mapToVoid()
            .share()
        
        disposeBag.insert {
            changeTargetsAppearance
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    // 🟨 音声の再生<的の見た目変更音声>
                    self.soundPlayer.play(.kyuiin)
                })
        }

        return ReloadMotionDetectionCountOutput(
            updateCount: updateCount,
            changeTargetsAppearance: changeTargetsAppearance
        )
    }
}
