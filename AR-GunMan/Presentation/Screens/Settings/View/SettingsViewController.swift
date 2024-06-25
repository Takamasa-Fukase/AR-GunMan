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
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var worldRankingButton: UIButton!
    @IBOutlet private weak var privacyPolicyButton: UIButton!
    @IBOutlet private weak var developerContactButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        let controllerInput = SettingsControllerInput(
            worldRankingButtonTapped: worldRankingButton.rx.tap.asObservable(),
            privacyPolicyButtonTapped: privacyPolicyButton.rx.tap.asObservable(),
            developerConctactButtonTapped: developerContactButton.rx.tap.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable()
        )
        presenter.transform(input: controllerInput)
    }
}
