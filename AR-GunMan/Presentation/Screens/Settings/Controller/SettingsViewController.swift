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
    var presenter: SettingsPresenter!
    private var contentView: SettingsContentView!

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
        let controllerEvents = SettingsPresenter.ControllerEvents(
            worldRankingButtonTapped: contentView.worldRankingButton.rx.tap.asObservable(),
            privacyPolicyButtonTapped: contentView.privacyPolicyButton.rx.tap.asObservable(),
            developerConctactButtonTapped: contentView.developerContactButton.rx.tap.asObservable(),
            backButtonTapped: contentView.backButton.rx.tap.asObservable()
        )
        _ = presenter.generateViewModel(from: controllerEvents)
    }
}
