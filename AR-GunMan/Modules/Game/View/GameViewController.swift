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

final class GameViewController: UIViewController {
    var viewModel: GameViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var bulletsCountImageView: UIImageView!
    @IBOutlet private weak var sightImageView: UIImageView!
    @IBOutlet private weak var timeCountLabel: UILabel!
    @IBOutlet private weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let input = GameViewModel.Input(
            viewDidLoad: Observable.just(Void()),
            viewWillAppear: rx.viewWillAppear,
            viewDidAppear: rx.viewDidAppear,
            viewWillDisappear: rx.viewWillDisappear,
            weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sceneView
            .subscribe(onNext: { [weak self] sceneView in
                guard let self = self else {return}
                sceneView.frame = self.view.frame
                self.view.insertSubview(sceneView, at: 0)
            }).disposed(by: disposeBag)
        
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

//extension GameViewController: GameSceneManagerDelegate {
//    func injectSceneView(_ sceneView: UIView) {
//        sceneView.frame = self.view.frame
//        self.view.insertSubview(sceneView, at: 0)
//    }
//}
