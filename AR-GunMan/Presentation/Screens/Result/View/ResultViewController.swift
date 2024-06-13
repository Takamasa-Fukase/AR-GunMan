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
    var viewModel: ResultViewModel2!
    private let disposeBag = DisposeBag()
    private let rankingListView = RankingListView()
    
    @IBOutlet private weak var rankingListBaseView: UIView!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var rightButtonsStackView: UIStackView!
    @IBOutlet private weak var replayButton: UIButton!
    @IBOutlet private weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = ResultViewModel2.Input(
            viewWillAppear: rx.viewWillAppear,
            replayButtonTapped: replayButton.rx.tap.asObservable(),
            toHomeButtonTapped: homeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        let viewModelAction = output.viewModelAction
        let outputToView = output.outputToView
        
        disposeBag.insert {
            viewModelAction.rankingListLoaded.subscribe()
            viewModelAction.nameRegisterViewShowed.subscribe()
            viewModelAction.rankingListUpdatedAfterRegister.subscribe()
            viewModelAction.viewDismissedToTopPage.subscribe()
            viewModelAction.errorAlertShowed.subscribe()
            viewModelAction.needsReplayFlagIsSetToTrue.subscribe()

            outputToView.scoreText
                .bind(to: scoreLabel.rx.text)
            outputToView.showButtons
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.showButtons()
                })
            outputToView.scrollCellToCenter
                .subscribe(onNext: { [weak self] indexPath in
                    guard let self = self else {return}
                    self.rankingListView.scrollCellToCenterVertically(at: indexPath)
                })
        }
        
        rankingListView.bind(
            rankingList: outputToView.rankingList,
            isLoading: outputToView.isLoadingRankingList
        )
    }
    
    private func setupUI() {
        insertBlurEffectView()
        rightButtonsStackView.isHidden = true
        replayButton.alpha = 0
        homeButton.alpha = 0
        
        rankingListBaseView.addSubview(rankingListView)
        rankingListBaseView.addConstraints(for: rankingListView)
    }

    private func showButtons() {
        UIView.animate(withDuration: 0.6, delay: 0.1) {
            self.rightButtonsStackView.isHidden = false
            
        } completion: { (Bool) in
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.replayButton.alpha = 1
                self.homeButton.alpha = 1
            }
        }
    }
    
    private func highlightCell(at indexPath: IndexPath) {
        // TODO: ハイライト実装
    }
}
