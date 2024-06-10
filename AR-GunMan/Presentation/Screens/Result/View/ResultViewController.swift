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
    var viewModel: ResultViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var rightButtonsStackView: UIStackView!
    @IBOutlet private weak var replayButton: UIButton!
    @IBOutlet private weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let input = ResultViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            replayButtonTapped: replayButton.rx.tap.asObservable(),
            toHomeButtonTapped: homeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.rankingList
            .bind(to: tableView.rx.items(
                // TODO: セルのクラス内にstaticで定義する
                cellIdentifier: "RankingCell",
                cellType: RankingCell.self
            )) { row, element, cell in
                cell.configure(ranking: element, row: row)
            }.disposed(by: disposeBag)
        
        output.scoreText
            .bind(to: scoreLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.showButtons
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.showButtons()
            }).disposed(by: disposeBag)
        
        output.scrollAndHightlightCell
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else {return}
                self.scrollCellToCenterVertically(at: indexPath)
                // TODO: ハイライトさせる
            }).disposed(by: disposeBag)
        
        output.isLoading
            .subscribe(onNext: { [weak self] element in
                guard let self = self else { return }
                if element {
                    self.activityIndicatorView.startAnimating()
                }else {
                    self.activityIndicatorView.stopAnimating()
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupUI() {
        insertBlurEffectView()
        rightButtonsStackView.isHidden = true
        replayButton.alpha = 0
        homeButton.alpha = 0
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: "RankingCell", bundle: nil), forCellReuseIdentifier: "RankingCell")
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
    
    private func scrollCellToCenterVertically(at indexPath: IndexPath) {
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    private func highlightCell(at indexPath: IndexPath) {
        // TODO: ハイライト実装
    }
}
