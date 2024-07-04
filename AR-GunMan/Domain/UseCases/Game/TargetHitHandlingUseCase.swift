//
//  TargetHitHandlingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct TargetHitHandlingInput {
    let targetHit: Observable<(weaponType: WeaponType, collisionInfo: CollisionInfo, currentScore: Double)>
}

struct TargetHitHandlingOutput {
    let updateScore: Observable<Double>
    let removeContactedTargetAndBullet: Observable<(targetId: UUID, bulletId: UUID)>
    let renderTargetHitParticleToContactPoint: Observable<(weaponType: WeaponType, contactPoint: Vector)>
}

protocol TargetHitHandlingUseCaseInterface {
    func transform(input: TargetHitHandlingInput) -> TargetHitHandlingOutput
}

final class TargetHitHandlingUseCase: TargetHitHandlingUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: TargetHitHandlingInput) -> TargetHitHandlingOutput {
        // 🟥 Stateの更新指示<スコアを更新>
        let updateScore = input.targetHit
            .map({
                return ScoreCalculator.getUpdatedScoreAfterHit(
                    currentScore: $0.currentScore,
                    weaponType: $0.weaponType
                )
            })
        
        // 衝突したオブジェクトの削除指示
        let removeContactedTargetAndBullet = input.targetHit
            .map({ (targetId: $0.collisionInfo.firstObjectInfo.id, bulletId: $0.collisionInfo.secondObjectInfo.id) })

        // 衝突地点に特殊効果の表示指示
        let renderTargetHitParticleToContactPoint = input.targetHit
            .filter({ $0.weaponType == .bazooka })
            .map({ (weaponType: $0.weaponType, contactPoint: $0.collisionInfo.contactPoint) })
        
        disposeBag.insert {
            input.targetHit
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    // 🟨 音声の再生<的へのヒット音声>
                    self.soundPlayer.play($0.weaponType.hitSound)
                })
        }
        
        return TargetHitHandlingOutput(
            updateScore: updateScore,
            removeContactedTargetAndBullet: removeContactedTargetAndBullet,
            renderTargetHitParticleToContactPoint: renderTargetHitParticleToContactPoint
        )
    }
}
