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
    let itemSelectedRelay = PublishRelay<Int>()
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet{
            let nib = UINib(nibName: "WeaponChangeCell", bundle: nil)
            self.pagerView.register(nib, forCellWithReuseIdentifier: "WeaponChangeCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFSPagerView()
        
        let input = WeaponChangeViewModel.Input(
            itemSelected: itemSelectedRelay.asObservable()
        )
                
        _ = viewModel.transform(input: input)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pagerView.itemSize = CGSize(width: self.view.frame.width * 0.5, height: self.view.frame.height * 0.8)
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
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "WeaponChangeCell", at: index) as? WeaponChangeCell else {
            return FSPagerViewCell()
        }
        cell.weaponImageView.image = UIImage(named: WeaponType.allCases[index].name)
        cell.commingSoonLabel.isHidden = true
        return cell
    }
}
