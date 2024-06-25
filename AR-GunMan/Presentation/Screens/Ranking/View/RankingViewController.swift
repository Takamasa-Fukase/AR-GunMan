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
    private let rankingListView = RankingListView()
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var rankingListBaseView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        rankingListBaseView.addSubview(rankingListView)
        rankingListBaseView.addConstraints(for: rankingListView)
    }
    
    private func bind() {
        let controllerInput = RankingControllerInput(
            viewWillAppear: rx.viewWillAppear,
            closeButtonTapped: closeButton.rx.tap.asObservable(),
            backgroundViewTapped: trackBackgroundViewTap()
        )
        let viewModel = presenter.transform(input: controllerInput)
        
        disposeBag.insert {
            rankingListView.bind(
                rankingList: viewModel.rankingList,
                isLoading: viewModel.isLoadingRankingList
            )
        }
    }
}
