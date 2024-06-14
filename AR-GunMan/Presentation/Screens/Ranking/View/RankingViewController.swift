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
    var viewModel: RankingViewModel!
    private let rankingListView = RankingListView()
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var rankingListBaseView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        rankingListBaseView.addSubview(rankingListView)
        rankingListBaseView.addConstraints(for: rankingListView)
    }
    
    private func bindViewModel() {
        let input = RankingViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            closeButtonTapped: closeButton.rx.tap.asObservable(),
            backgroundViewTapped: trackBackgroundViewTap()
        )
        let output = viewModel.transform(input: input)
        let viewModelAction = output.viewModelAction
        let outputToView = output.outputToView
        
        disposeBag.insert {
            viewModelAction.viewDismissed.subscribe()
            viewModelAction.errorAlertShowed.subscribe()
            
            rankingListView.bind(
                rankingList: outputToView.rankingList,
                isLoading: outputToView.isLoadingRankingList
            )
        }
    }
}
