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
            itemSelected: itemSelectedRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        bind(output: output)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pagerView.itemSize = CGSize(width: view.frame.width * 0.5, height: view.frame.height * 0.8)
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
