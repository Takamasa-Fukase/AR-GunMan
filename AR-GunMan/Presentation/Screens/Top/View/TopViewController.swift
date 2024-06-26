//
//  TopViewController.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import UIKit
import RxSwift
import RxCocoa

class TopViewController: UIViewController {
    var presenter: TopPresenterInterface!
    private var contentView: TopContentView!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        bind()
    }
    
    private func setView() {
        contentView = .init(frame: view.frame)
        view.addSubview(contentView)
        view.addConstraints(for: contentView)
    }
    
    private func bind() {
        let controllerInput = TopControllerInput(
            viewDidAppear: rx.viewDidAppear,
            startButtonTapped: contentView.startButton.rx.tap.asObservable(),
            settingsButtonTapped: contentView.settingsButton.rx.tap.asObservable(),
            howToPlayButtonTapped: contentView.howToPlayButton.rx.tap.asObservable()
        )
        let viewModel = presenter.transform(input: controllerInput)
        
        disposeBag.insert {
            viewModel.isStartButtonIconSwitched
                .map({ TopConst.targetIcon(isSwitched: $0) })
                .drive(contentView.startButtonIcon.rx.image)
            viewModel.isSettingsButtonIconSwitched
                .map({ TopConst.targetIcon(isSwitched: $0) })
                .drive(contentView.settingsButtonIcon.rx.image)
            viewModel.isHowToPlayButtonIconSwitched
                .map({ TopConst.targetIcon(isSwitched: $0) })
                .drive(contentView.howToPlayButtonIcon.rx.image)
        }
    }
}
