//
//  ViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/04.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    var viewModel: TopViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var startButtonIcon: UIImageView!
    @IBOutlet weak var settingsButtonIcon: UIImageView!
    @IBOutlet weak var howToPlayButtonIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: - input
        viewModel = TopViewModel(
            input: .init(
                viewDidAppear: rx.viewDidAppear,
                startButtonTapped: startButton.rx.tap.asObservable(),
                settingsButtonTapped: settingsButton.rx.tap.asObservable(),
                howToPlayButtonTapped: howToPlayButton.rx.tap.asObservable()
            ),
            dependency: .init(
                buttonImageSwitcher: TopPageButtonImageSwitcher()
            )
        )
        
        //MARK: - output
        viewModel.startButtonImage
            .bind(to: startButtonIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.settingsButtonImage
            .bind(to: settingsButtonIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.howToPlayButtonImage
            .bind(to: howToPlayButtonIcon.rx.image)
            .disposed(by: disposeBag)

        viewModel.showGame
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                CameraAuthUtil.checkCameraAuthorization(vc: self)
                self.presentGameVC()
            }).disposed(by: disposeBag)
        
        viewModel.showSettings
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.presentSettingsVC()
            }).disposed(by: disposeBag)
        
        viewModel.showTutorial
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.presentHowToPlayVC()
            }).disposed(by: disposeBag)
    }

    func presentGameVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func presentSettingsVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SettingsViewController
        self.presentPanModal(vc)
    }

    func presentHowToPlayVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! TutorialViewController
        vc.vmDependency = .init(transitionType: .topPage)
        self.presentPanModal(vc)
    }
}
