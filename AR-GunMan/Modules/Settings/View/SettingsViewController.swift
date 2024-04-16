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

class SettingsViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel: SettingsViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var worldRankingButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var developerContactButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Methods
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
