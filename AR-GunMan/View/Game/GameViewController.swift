//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/15.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import ARKit
import FSPagerView
import PanModal
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    var viewModel: GameViewModel2!
    let disposeBag = DisposeBag()
    let sceneView = ARSCNView()
    
    @IBOutlet weak var bulletsCountImageView: UIImageView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        viewModel = GameViewModel2(
            tutorialRepository: TutorialRepository(),
            navigator: GameNavigator(viewController: self)
        )
        
        //MARK: - input
        let input: GameViewModel2.Input = .init(
            viewDidAppear: rx.viewDidAppear,
            weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
        )
        let sceneManager = GameSceneManager(sceneView: sceneView)
        
        let output = viewModel.transform(
            input: input,
            sceneManager: sceneManager
        )
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SceneViewSettingUtil.startSession(sceneView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SceneViewSettingUtil.pauseSession(sceneView)
    }
    
    private func setupUI() {
        // - 等幅フォントにして高速で動くタイムカウントの横振れを防止
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
        sceneView.frame = view.frame
        view.insertSubview(sceneView, at: 0)
    }
}
