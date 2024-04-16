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
        
        viewModel = SettingsViewModel()
        
        let input = SettingsViewModel.Input(
            worldRankingButtonTapped: worldRankingButton.rx.tap.asObservable(),
            privacyPolicyButtonTapped: privacyPolicyButton.rx.tap.asObservable(),
            developerConctactButtonTapped: developerContactButton.rx.tap.asObservable(),
            backButtonTapped: backButton.rx.tap.asObservable()
        )
        
        //output
        let output = viewModel.transform(input: input)
        
        output.showRanking
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                presentRankingVC()
            }).disposed(by: disposeBag)
        
        output.openSafariView
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                SafariViewUtil.openSafariView(urlString: element, vc: self)
            }).disposed(by: disposeBag)
        
        output.dismiss
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    func presentRankingVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "RankingViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! RankingViewController
        self.presentPanModal(vc)
    }
}
