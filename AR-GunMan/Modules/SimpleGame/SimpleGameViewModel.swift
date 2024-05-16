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
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
        let outputToGameScene: OutputToGameScene
        
        struct ViewModelAction {
            let fireWeapon: Observable<Void>
            let reloadWeapon: Observable<Void>
            let addScore: Observable<Void>
        }
        
        struct OutputToView {
            let bulletsCountImage: Observable<UIImage?>
        }
        
        struct OutputToGameScene {
            let renderWeaponFiring: Observable<WeaponType>
        }
    }
    
    class State {
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        var score: Double = 0
        var canFire: Bool {
//            print("vm canFire: \(bulletsCountRelay.value > 0), bulletsCountRelay.value: \(bulletsCountRelay.value)")
            return bulletsCountRelay.value > 0
        }
        var canReload: Bool {
            return bulletsCountRelay.value <= 0
        }
    }
    
    private var state: State
    
    init(state: State = State()) {
        self.state = state
    }
    
    func transform(input: Input) -> Output {
        // MARK: ViewModelAction
        let fireWeapon = input.inputFromCoreMotion.firingMotionDetected
            .filter({ [weak self] _ in
                guard let self = self else { return false }
                return self.state.canFire
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                AudioUtil.playSound(of: WeaponType.pistol.firingSound)
                self.state.bulletsCountRelay.accept(
                    self.state.bulletsCountRelay.value - 1
                )
            })
            .map({ _ in })
            .share()
                
        let reloadWeapon = input.inputFromCoreMotion.reloadingMotionDetected
            .filter({ [weak self] _ in
                guard let self = self else { return false }
                return self.state.canReload
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                AudioUtil.playSound(of: WeaponType.pistol.reloadingSound)
                self.state.bulletsCountRelay.accept(
                    WeaponType.pistol.bulletsCapacity
                )
            })
            .map({ _ in })
        
        let addScore = input.inputFromGameScene.targetHit
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                AudioUtil.playSound(of: WeaponType.pistol.hitSound)
                self.state.score += 1
            })
        
        
        // MARK: OutputToView
        let bulletsCountImage = state.bulletsCountRelay
            .map({ WeaponType.pistol.bulletsCountImage(at: $0) })
        
        
        // MARK: OutputToGameScene
        let renderWeaponFiring = fireWeapon
            .map({ _ in WeaponType.pistol })

        
        return Output(
            viewModelAction: Output.ViewModelAction(
                fireWeapon: fireWeapon,
                reloadWeapon: reloadWeapon,
                addScore: addScore
            ),
            outputToView: Output.OutputToView(
                bulletsCountImage: bulletsCountImage
            ),
            outputToGameScene: Output.OutputToGameScene(
                renderWeaponFiring: renderWeaponFiring
            )
        )
    }
}


