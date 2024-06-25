//
//  SettingsViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsViewController: UIViewController {
    var presenter: SettingsPresenterInterface!
    private let contentView = SettingsContentView()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        bind()
    }
    
    private func setView() {
        view.addSubview(contentView)
        view.addConstraints(for: contentView)
    }
    
    private func bind() {
        let controllerInput = SettingsControllerInput(
            worldRankingButtonTapped: contentView.worldRankingButton.rx.tap.asObservable(),
            privacyPolicyButtonTapped: contentView.privacyPolicyButton.rx.tap.asObservable(),
            developerConctactButtonTapped: contentView.developerContactButton.rx.tap.asObservable(),
            backButtonTapped: contentView.backButton.rx.tap.asObservable()
        )
        presenter.transform(input: controllerInput)
    }
}
