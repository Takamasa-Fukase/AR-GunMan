//
//  RankingViewController.swift
//  AR-GunMan
//
//  Created by Takahiro Fukase on 2021/11/13.
//

import UIKit
import RxSwift
import RxCocoa

final class RankingViewController: UIViewController, BackgroundViewTapTrackable {
    var presenter: RankingPresenterInterface!
    private var contentView: RankingContentView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        bind()
    }
    
    private func setView() {
        contentView = .init(frame: view.frame)
        view.addSubview(contentView)
        view.addConstraints(for: contentView)
    }
    
    private func bind() {
        let controllerInput = RankingControllerInput(
            viewWillAppear: rx.viewWillAppear,
            closeButtonTapped: contentView.closeButton.rx.tap.asObservable(),
            backgroundViewTapped: contentView.trackBackgroundViewTap()
        )
        let viewModel = presenter.transform(input: controllerInput)
        
        disposeBag.insert {
            contentView.rankingListView.bind(
                rankingList: viewModel.rankingList,
                isLoading: viewModel.isLoadingRankingList
            )
        }
    }
}
