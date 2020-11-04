//
//  SwitchWeaponViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/03.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import FSPagerView

protocol SwitchWeaponDelegate {
    func selectedAt(index: Int)
}

class SwitchWeaponViewController: UIViewController {
    
    var switchWeaponDelegate: SwitchWeaponDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.automaticSlidingInterval = 0
        pagerView.isInfinite = true
        pagerView.decelerationDistance = 1
        pagerView.interitemSpacing = 8
        
        pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
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
        return 6
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "SwitchWeaponCell", at: index) as? SwitchWeaponCell else {
            return FSPagerViewCell()
        }
        switch index {
        case 0:
            cell.weaponImageView.image = UIImage(named: "pistol")
            cell.commingSoonLabel.isHidden = true
        case 1:
            cell.weaponImageView.image = UIImage(named: "rifle")
            cell.commingSoonLabel.isHidden = false
        case 2:
            cell.weaponImageView.image = UIImage(named: "shot-gun")
            cell.commingSoonLabel.isHidden = false
        case 3:
            cell.weaponImageView.image = UIImage(named: "sniper-rifle")
            cell.commingSoonLabel.isHidden = false
        case 4:
            cell.weaponImageView.image = UIImage(named: "mini-gun")
            cell.commingSoonLabel.isHidden = false
        case 5:
            cell.weaponImageView.image = UIImage(named: "rocket-launcher")
            cell.commingSoonLabel.isHidden = true
        default:
            break
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        switchWeaponDelegate?.selectedAt(index: index)
        self.dismiss(animated: true, completion: nil)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {

    }
    
}
