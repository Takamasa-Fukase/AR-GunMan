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
    let viewModel = SettingsViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var developerContactButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //input
        let _ = developerContactButton.rx.tap
            .bind(to: viewModel.developerConctactButtonTapped)
            .disposed(by: disposeBag)
        
        let _ = privacyPolicyButton.rx.tap
            .bind(to: viewModel.privacyPolicyButtonTapped)
            .disposed(by: disposeBag)
        
        let _ = backButton.rx.tap
            .bind(to: viewModel.backButtonTapped)
            .disposed(by: disposeBag)
        
        //output
        let _ = viewModel.openSafariView
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                SafariViewUtil.openSafariView(urlString: element, vc: self)
            }).disposed(by: disposeBag)
        
        let _ = viewModel.dismiss
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}
