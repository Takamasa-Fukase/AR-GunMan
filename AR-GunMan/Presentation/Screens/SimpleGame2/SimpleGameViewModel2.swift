//
//  SimpleGameViewModel2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/5/24.
//

import RxSwift
import RxCocoa

final class SimpleGameViewModel2: ViewModelType {
    struct Input {
        let inputFromView: InputFromView
        let inputFromGameScene: InputFromGameScene
        let inputFromCoreMotion: InputFromCoreMotion

        struct InputFromView {
            let weaponChangeButtonTapped: Observable<Void>
        }
        
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
            let weaponSelected: Observable<WeaponType>
            let weaponFired: Observable<WeaponType>
            let weaponReloaded: Observable<WeaponType>
        }
        
        struct OutputToView {
            let bulletsCountImage: Observable<UIImage?>
        }
        
        struct OutputToGameScene {
            let renderSelectedWeapon: Observable<WeaponType>
            let renderWeaponFiring: Observable<WeaponType>
        }
    }
    
    class State {
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        var isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        let scoreRelay = BehaviorRelay<Double>(value: 0)
    }

    private let useCase: GameUseCase2Interface
    private var state: State
    private var soundPlayer: SoundPlayerInterface
    
    init(
        useCase: GameUseCase2Interface,
        state: State = State(),
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.useCase = useCase
        self.state = state
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: Input) -> Output {
        // MARK: ViewModelAction
        let weaponSelected = input.inputFromView.weaponChangeButtonTapped
            .map({[weak self] _ -> WeaponType in
                guard let self = self else { return .pistol }
                if self.state.weaponTypeRelay.value == .pistol {
                    return .bazooka
                }else {
                    return .pistol
                }
            })
            .do(onNext: {[weak self] selectedWeapon in
                guard let self = self else { return }
                self.state.weaponTypeRelay.accept(selectedWeapon)
                self.soundPlayer.play(selectedWeapon.weaponChangingSound)
                self.state.bulletsCountRelay.accept(selectedWeapon.bulletsCapacity)
                self.state.isWeaponReloadingRelay.accept(false)
            })
            .map({[weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol })
        
        let weaponFired = WeaponFiringEventTransformer()
            .transform(
                input: .init(weaponFiringTrigger: input.inputFromCoreMotion.firingMotionDetected
                    .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol })),
                state: .init(bulletsCountRelay: state.bulletsCountRelay)
            )
            .weaponFired
        
        let weaponReloaded = WeaponReloadingEventTransformer(gameUseCase: useCase)
            .transform(
                input: .init(weaponReloadingTrigger: input.inputFromCoreMotion.reloadingMotionDetected
                    .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol })),
                state: .init(bulletsCountRelay: state.bulletsCountRelay,
                             isWeaponReloadingRelay: state.isWeaponReloadingRelay)
            )
            .weaponReloaded
        
        // MARK: OutputToView
        let bulletsCountImage = state.bulletsCountRelay
            .map({ [weak self] in self?.state.weaponTypeRelay.value.bulletsCountImage(at: $0) })
        
        
        // MARK: OutputToGameScene
        let renderSelectedWeapon = weaponSelected

        let renderWeaponFiring = weaponFired

        
        return Output(
            viewModelAction: Output.ViewModelAction(
                weaponSelected: weaponSelected,
                weaponFired: weaponFired,
                weaponReloaded: weaponReloaded
            ),
            outputToView: Output.OutputToView(
                bulletsCountImage: bulletsCountImage
            ),
            outputToGameScene: Output.OutputToGameScene(
                renderSelectedWeapon: renderSelectedWeapon,
                renderWeaponFiring: renderWeaponFiring
            )
        )
    }
}



