//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/15.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    var viewModel: GameViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var bulletsCountImageView: UIImageView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        //MARK: - input
        let input = GameViewModel.Input(
            viewDidLoad: Observable.just(Void()),
            viewWillAppear: rx.viewWillAppear,
            viewDidAppear: rx.viewDidAppear,
            viewWillDisappear: rx.viewWillDisappear,
            weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        //MARK: - output
        output.sightImage
            .bind(to: sightImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.sightImageColor
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.sightImageView.tintColor = element
            }).disposed(by: disposeBag)
        
        output.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.timeCountText
            .bind(to: timeCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        // - 等幅フォントにして高速で動くタイムカウントの横振れを防止
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
    }
}

extension GameViewController: GameSceneManagerDelegate {
    func injectSceneView(_ sceneView: UIView) {
        sceneView.frame = self.view.frame
        self.view.insertSubview(sceneView, at: 0)
    }
}
