//
//  TopViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/04.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TopViewController: UIViewController {
    var viewModel: TopViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var howToPlayButton: UIButton!
    @IBOutlet private weak var startButtonIcon: UIImageView!
    @IBOutlet private weak var settingsButtonIcon: UIImageView!
    @IBOutlet private weak var howToPlayButtonIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = TopViewModel.Input(
            viewDidAppear: rx.viewDidAppear,
            startButtonTapped: startButton.rx.tap.asObservable(),
            settingsButtonTapped: settingsButton.rx.tap.asObservable(),
            howToPlayButtonTapped: howToPlayButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.startButtonImage
            .bind(to: startButtonIcon.rx.image)
            .disposed(by: disposeBag)
        
        output.settingsButtonImage
            .bind(to: settingsButtonIcon.rx.image)
            .disposed(by: disposeBag)
        
        output.howToPlayButtonImage
            .bind(to: howToPlayButtonIcon.rx.image)
            .disposed(by: disposeBag)
    }
}
