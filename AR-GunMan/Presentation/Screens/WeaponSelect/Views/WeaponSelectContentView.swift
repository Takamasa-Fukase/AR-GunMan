//
//  WeaponSelectContentView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import UIKit
import FSPagerView
import RxCocoa

final class WeaponSelectContentView: UIView {
    let itemSelectedRelay = PublishRelay<Int>()

    @IBOutlet weak var pagerView: FSPagerView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        loadNib()
        setupFSPagerView()
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
}

extension WeaponSelectContentView: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        itemSelectedRelay.accept(index)
    }
}

extension WeaponSelectContentView: FSPagerViewDataSource {
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
