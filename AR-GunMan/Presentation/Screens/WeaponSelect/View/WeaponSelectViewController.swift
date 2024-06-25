//
//  WeaponSelectViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/03.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import FSPagerView
import RxSwift
import RxCocoa

final class WeaponSelectViewController: UIViewController {
    var viewModel: WeaponSelectViewModel!
    private let itemSelectedRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var pagerView: FSPagerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFSPagerView()
        bindViewModel()
    }

    private func setupFSPagerView() {
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.automaticSlidingInterval = 0
        pagerView.isInfinite = true
        pagerView.decelerationDistance = 1
        pagerView.interitemSpacing = 8
        pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
        let nib = UINib(nibName: WeaponSelectCell.className, bundle: nil)
        pagerView.register(nib, forCellWithReuseIdentifier: WeaponSelectCell.className)
    }
    
    private func bindViewModel() {
        let input = WeaponSelectViewModel.Input(
            viewDidLayoutSubviews: rx.viewDidLayoutSubviews,
            itemSelected: itemSelectedRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        let viewModelAction = output.viewModelAction
        let outputToView = output.outputToView
        
        disposeBag.insert {
            viewModelAction.weaponSelectEventSent.subscribe()
            viewModelAction.viewDismissed.subscribe()
            
            outputToView.adjustPageViewItemSize
                .map({ [weak self] _ in
                    guard let self = self else { return CGSize() }
                    return CGSize(width: self.view.frame.width * 0.5,
                                  height: self.view.frame.height * 0.8)
                })
                .bind(to: pagerView.rx.itemSize)
        }
    }
}

extension WeaponSelectViewController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        itemSelectedRelay.accept(index)
    }
}

extension WeaponSelectViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return WeaponType.allCases.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: WeaponSelectCell.className, at: index) as? WeaponSelectCell else {
            return FSPagerViewCell()
        }
        cell.configure(
            weaponImage: UIImage(named: WeaponType.allCases[index].name),
            isHiddenCommingSoonLabel: true
        )
        return cell
    }
}
