//
//  TargetHitHandlingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct TargetHitHandlingInput {
    let targetHit: Observable<(weaponType: WeaponType, currentScore: Double)>
}

struct TargetHitHandlingOutput {
    let updateScore: Observable<Double>
}

protocol TargetHitHandlingUseCaseInterface {
    func generateOutput(from input: TargetHitHandlingInput) -> TargetHitHandlingOutput
}

final class TargetHitHandlingUseCase: TargetHitHandlingUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func generateOutput(from input: TargetHitHandlingInput) -> TargetHitHandlingOutput {
        // 🟥 Stateの更新指示<スコアを更新>
        let updateScore = input.targetHit
            .map({
                return ScoreCalculator.getUpdatedScoreAfterHit(
                    currentScore: $0.currentScore,
                    weaponType: $0.weaponType
                )
            })
        
        disposeBag.insert {
            input.targetHit
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    // 🟨 音声の再生<的へのヒット音声>
                    self.soundPlayer.play($0.weaponType.hitSound)
                })
        }
        
        return TargetHitHandlingOutput(
            updateScore: updateScore
        )
    }
}
