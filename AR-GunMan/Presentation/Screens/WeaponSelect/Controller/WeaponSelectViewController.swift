//
//  WeaponSelectViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/03.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WeaponSelectViewController: UIViewController {
    var presenter: WeaponSelectPresenter!
    private var contentView: WeaponSelectContentView!
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
        let controllerEvents = WeaponSelectPresenter.ControllerEvents(
            viewDidLayoutSubviews: rx.viewDidLayoutSubviews,
            itemSelected: contentView.itemSelectedRelay.asObservable()
        )
        let viewModel = presenter.generateViewModel(from: controllerEvents)

        disposeBag.insert {
            viewModel.adjustPageViewItemSize
                .map({ [weak self] _ in
                    guard let self = self else { return CGSize() }
                    return CGSize(width: self.view.frame.width * 0.5,
                                  height: self.view.frame.height * 0.8)
                })
                .drive(contentView.pagerView.rx.itemSize)
        }
    }
}
