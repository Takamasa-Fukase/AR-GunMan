//
//  SwitchWeaponViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/03.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import FSPagerView
import RxSwift
import RxCocoa

protocol SwitchWeaponDelegate: AnyObject {
    func switchWeaponTo(weapon: WeaponTypes)
}

class SwitchWeaponViewController: UIViewController {
       
    let disposeBag = DisposeBag()
    weak var switchWeaponDelegate: SwitchWeaponDelegate?
    var viewModel: GameViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.automaticSlidingInterval = 0
        pagerView.isInfinite = true
        pagerView.decelerationDistance = 1
        pagerView.interitemSpacing = 8
        
        pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
        
        
        //output
        viewModel?.dismissSwitchWeaponVC
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                
                print("SwitchWeaponVC dismissSelfを通知受け取ったのでdismissします")
                self.dismiss(animated: false, completion: nil)
                
            }).disposed(by: disposeBag)
        
    }
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet{
            let nib = UINib(nibName: "SwitchWeaponCell", bundle: nil)
            self.pagerView.register(nib, forCellWithReuseIdentifier: "SwitchWeaponCell")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pagerView.itemSize = CGSize(width: self.view.frame.width * 0.5, height: self.view.frame.height * 0.8)
    }
    
}

extension SwitchWeaponViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return WeaponTypes.allCases.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "SwitchWeaponCell", at: index) as? SwitchWeaponCell else {
            return FSPagerViewCell()
        }
        cell.weaponImageView.image = UIImage(named: WeaponTypes.allCases[index].rawValue)
        cell.commingSoonLabel.isHidden = true
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        switchWeaponDelegate?.switchWeaponTo(weapon: WeaponTypes.allCases[index])
        self.dismiss(animated: true, completion: nil)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {

    }
    
}
