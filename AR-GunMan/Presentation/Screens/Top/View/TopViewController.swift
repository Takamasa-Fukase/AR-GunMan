//
//  TopViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/04.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TopViewController: UIViewController {
    var viewModel: TopViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var howToPlayButton: UIButton!
    @IBOutlet private weak var startButtonIcon: UIImageView!
    @IBOutlet private weak var settingsButtonIcon: UIImageView!
    @IBOutlet private weak var howToPlayButtonIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let input = TopViewModel.Input(
            viewDidAppear: rx.viewDidAppear,
            startButtonTapped: startButton.rx.tap.asObservable(),
            settingsButtonTapped: settingsButton.rx.tap.asObservable(),
            howToPlayButtonTapped: howToPlayButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        bind(output: output)
    }
    
    func bind(output: TopViewModel.Output) {
        let viewModelAction = output.viewModelAction
        let outputToView = output.outputToView

        disposeBag.insert {
            viewModelAction.gameViewShowed.subscribe()
            viewModelAction.settingsViewShowed.subscribe()
            viewModelAction.tutorialViewShowed.subscribe()
            viewModelAction.cameraPermissionDescriptionAlertShowed.subscribe()
            viewModelAction.iconChangingSoundPlayed.subscribe()
            viewModelAction.needsReplayFlagIsSetToFalse.subscribe()
            
            outputToView.isStartButtonIconSwitched
                .map({ TopConst.targetIcon(isSwitched: $0) })
                .bind(to: startButtonIcon.rx.image)
            outputToView.isSettingsButtonIconSwitched
                .map({ TopConst.targetIcon(isSwitched: $0) })
                .bind(to: settingsButtonIcon.rx.image)
            outputToView.isHowToPlayButtonIconSwitched
                .map({ TopConst.targetIcon(isSwitched: $0) })
                .bind(to: howToPlayButtonIcon.rx.image)
        }
    }
}
