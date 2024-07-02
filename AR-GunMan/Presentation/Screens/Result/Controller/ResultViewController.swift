//
//  ResultViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/11.
//

import UIKit
import RxSwift
import RxCocoa

final class ResultViewController: UIViewController {
    var presenter: ResultPresenterInterface!
    private var contentView: ResultContentView!
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
        let controllerInput = ResultControllerInput(
            viewWillAppear: rx.viewWillAppear,
            replayButtonTapped: contentView.replayButton.rx.tap.asObservable(),
            toHomeButtonTapped: contentView.homeButton.rx.tap.asObservable()
        )
        let viewModel = presenter.transform(input: controllerInput)
        
        disposeBag.insert {
            viewModel.scoreText
                .drive(contentView.scoreLabel.rx.text)
            viewModel.showButtons
                .drive(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.contentView.showButtons()
                })
            viewModel.scrollCellToCenter
                .drive(onNext: { [weak self] indexPath in
                    guard let self = self else {return}
                    self.contentView.rankingListView.scrollCellToCenterVertically(at: indexPath)
                })
            contentView.rankingListView.bind(
                rankingList: viewModel.rankingList,
                isLoading: viewModel.isLoadingRankingList
            )
        }
    }
}
