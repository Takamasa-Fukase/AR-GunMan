//
//  SettingsViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

final class SettingsViewController: UIViewController {
    var viewModel: SettingsViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var worldRankingButton: UIButton!
    @IBOutlet private weak var privacyPolicyButton: UIButton!
    @IBOutlet private weak var developerContactButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = SettingsViewModel.Input(
            worldRankingButtonTapped: worldRankingButton.rx.tap.asObservable(),
            privacyPolicyButtonTapped: privacyPolicyButton.rx.tap.asObservable(),
            developerConctactButtonTapped: developerContactButton.rx.tap.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable()
        )
        
        _ = viewModel.transform(input: input)
    }
}
