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
    @IBOutlet weak var rankingButton: UIButton!
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var startButtonIcon: UIImageView!
    @IBOutlet weak var rankingButtonIcon: UIImageView!
    @IBOutlet weak var howToPlayButtonIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: - input
        viewModel = TopViewModel(
            input: .init(viewDidAppear: rx.viewDidAppear,
                         startButtonTapped: startButton.rx.tap.asObservable(),
                         rankingButtonTapped: rankingButton.rx.tap.asObservable(),
                         howToPlayButtonTapped: howToPlayButton.rx.tap.asObservable(),
                         settingsButtonTapped: settingsButton.rx.tap.asObservable()),
            dependency: TopPageButtonImageSwitcher())
        
        //MARK: - output
        viewModel.startButtonImage
            .bind(to: startButtonIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.rankingButtonImage
            .bind(to: rankingButtonIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.howToPlayButtonImage
            .bind(to: howToPlayButtonIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.settingsButtonImage
            .bind(to: settingsButton.rx.image())
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(viewModel.showGame, viewModel.isReplay)
            .subscribe(onNext: { [weak self] (_, isReplay) in
                guard let self = self else {return}
                CameraAuthUtil.checkCameraAuthorization(vc: self)
                self.presentGameVC(animated: !isReplay)
            }).disposed(by: disposeBag)
        
        viewModel.showRanking
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.presentRankingVC()
            }).disposed(by: disposeBag)
        
        viewModel.showTutorial
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.presentHowToPlayVC()
            }).disposed(by: disposeBag)
        
        viewModel.showSettings
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.presentSettingsVC()
            }).disposed(by: disposeBag)
    }

    func presentGameVC(animated: Bool = true) {
        startButtonIcon.image = TopConst.targetIcon
        
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: animated)
    }
    
    func presentRankingVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "WorldRankingViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! WorldRankingViewController
        self.presentPanModal(vc)
    }
    
    func presentHowToPlayVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        vc.vmDependency = .init(transitionType: .topPage)
        self.presentPanModal(vc)
    }
    
    func presentSettingsVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.presentPanModal(vc)
    }
}
