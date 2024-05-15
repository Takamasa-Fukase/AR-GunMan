//
//  SimpleGameViewModel.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/15.
//

import RxSwift
import RxCocoa

final class SimpleGameViewModel: ViewModelType {
    struct Input {
        let inputFromGameScene: InputFromGameScene
        let inputFromCoreMotion: InputFromCoreMotion

        struct InputFromGameScene {
            let targetHit: Observable<Void>
        }
        
        struct InputFromCoreMotion {
            let firingMotionDetected: Observable<Void>
            let reloadingMotionDetected: Observable<Void>
        }
    }
    
    struct Output {
        let outputToView: OutputToView
        let outputToGameScene: OutputToGameScene
        let viewModelAction: ViewModelAction
        
        struct OutputToView {
            let bulletsCountImage: Observable<UIImage?>
        }
        
        struct OutputToGameScene {
            let renderWeaponFiring: Observable<WeaponType>
        }
        
        struct ViewModelAction {
            let fireWeapon: Observable<Void>
            let reloadWeapon: Observable<Void>
            let addScore: Observable<Void>
        }
    }
    
    struct State {
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        var score: Double = 0
        var canFire: Bool {
            return bulletsCountRelay.value > 0
        }
        var canReload: Bool {
            return bulletsCountRelay.value <= 0
        }
    }
    
    func transform(input: Input) -> Output {
        // 画面が持つ状態
        var state = State()
        
        
        // MARK: OutputToView
        let bulletsCountImage = state.bulletsCountRelay
            .map({ WeaponType.pistol.bulletsCountImage(at: $0) })
        
        
        // MARK: OutputToGameScene
        let renderWeaponFiring = input.inputFromCoreMotion.firingMotionDetected
            .filter({ _ in state.canFire })
            .map({ _ in WeaponType.pistol })

        
        // MARK: ViewModelAction
        let fireWeapon = input.inputFromCoreMotion.firingMotionDetected
            .filter({ _ in state.canFire })
            .do(onNext: { _ in
                AudioUtil.playSound(of: WeaponType.pistol.firingSound)
                state.bulletsCountRelay.accept(
                    state.bulletsCountRelay.value - 1
                )
            })
            .map({ _ in })
        
        let reloadWeapon = input.inputFromCoreMotion.reloadingMotionDetected
            .filter({ _ in state.canReload })
            .do(onNext: { _ in
                AudioUtil.playSound(of: WeaponType.pistol.reloadingSound)
                state.bulletsCountRelay.accept(
                    WeaponType.pistol.bulletsCapacity
                )
            })
            .map({ _ in })
        
        let addScore = input.inputFromGameScene.targetHit
            .do(onNext: { _ in
                AudioUtil.playSound(of: WeaponType.pistol.hitSound)
                state.score += 1
            })
        
        
        return Output(
            outputToView: Output.OutputToView(
                bulletsCountImage: bulletsCountImage
            ),
            outputToGameScene: Output.OutputToGameScene(
                renderWeaponFiring: renderWeaponFiring
            ),
            viewModelAction: Output.ViewModelAction(
                fireWeapon: fireWeapon,
                reloadWeapon: reloadWeapon,
                addScore: addScore
            )
        )
    }
}


