//
//  RankingViewController.swift
//  AR-GunMan
//
//  Created by Takahiro Fukase on 2021/11/13.
//

import UIKit
import RxSwift
import RxCocoa

final class RankingViewController: UIViewController {
    var viewModel: RankingViewModel!
    private let rankingListView = RankingListView()
    private let tapRecognizer = UITapGestureRecognizer()
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
        view.addGestureRecognizer(tapRecognizer)
    }
    
    private func bindViewModel() {
        let backgroundViewTapped = tapRecognizer.rx.shouldReceiveCalled
            .filter({
                return $0.touch.view == $0.gestureRecognizer.view
            })
            .mapToVoid()

        let input = RankingViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            closeButtonTapped: closeButton.rx.tap.asObservable(),
            backgroundViewTapped: backgroundViewTapped
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
