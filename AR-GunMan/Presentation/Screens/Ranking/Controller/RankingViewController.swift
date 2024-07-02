//
//  RankingViewController.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import UIKit
import RxSwift
import RxCocoa

final class RankingViewController: UIViewController {
    var presenter: RankingPresenter!
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
        let controllerEvents = RankingPresenter.ControllerEvents(
            viewWillAppear: rx.viewWillAppear,
            closeButtonTapped: contentView.closeButton.rx.tap.asObservable(),
            backgroundViewTapped: contentView.trackBackgroundViewTap()
        )
        let viewModel = presenter.generateViewModel(from: controllerEvents)
        
        disposeBag.insert {
            contentView.rankingListView.bind(
                rankingList: viewModel.rankingList,
                isLoading: viewModel.isLoadingRankingList
            )
        }
    }
}
