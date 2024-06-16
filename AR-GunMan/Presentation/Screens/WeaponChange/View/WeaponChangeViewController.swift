//
//  WeaponChangeViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/03.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import FSPagerView
import RxSwift
import RxCocoa

final class WeaponChangeViewController: UIViewController {
    var viewModel: WeaponChangeViewModel!
    private let itemSelectedRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var pagerView: FSPagerView! {
        didSet {
            let nib = UINib(nibName: WeaponChangeCell.className, bundle: nil)
            pagerView.register(nib, forCellWithReuseIdentifier: WeaponChangeCell.className)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFSPagerView()
        
        let input = WeaponChangeViewModel.Input(
            viewDidLayoutSubviews: rx.viewDidLayoutSubviews,
            itemSelected: itemSelectedRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        bind(output: output)
    }

    private func setupFSPagerView() {
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.automaticSlidingInterval = 0
        pagerView.isInfinite = true
        pagerView.decelerationDistance = 1
        pagerView.interitemSpacing = 8
        pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
    }
    
    private func bind(output: WeaponChangeViewModel.Output) {
        disposeBag.insert {
            output.adjustPageViewItemSize
                .map({ [weak self] _ in
                    guard let self = self else { return CGSize() }
                    return CGSize(width: self.view.frame.width * 0.5,
                                  height: self.view.frame.height * 0.8)
                })
                .bind(to: pagerView.rx.itemSize)
            
            output.weaponSelectEventSent.subscribe()
            output.viewDismissed.subscribe()
        }
    }
}

extension WeaponChangeViewController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        itemSelectedRelay.accept(index)
    }
}

extension WeaponChangeViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return WeaponType.allCases.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: WeaponChangeCell.className, at: index) as? WeaponChangeCell else {
            return FSPagerViewCell()
        }
        cell.configure(
            weaponImage: UIImage(named: WeaponType.allCases[index].name),
            isHiddenCommingSoonLabel: true
        )
        return cell
    }
}
