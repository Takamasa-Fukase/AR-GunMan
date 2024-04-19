//
//  ResultViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/11.
//

import UIKit
import RxSwift
import RxCocoa

class ResultViewController: UIViewController {
    var viewModel: ResultViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var rightButtonsStackView: UIStackView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // MARK: - input
        let input = ResultViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            replayButtonTapped: replayButton.rx.tap.asObservable(),
            toHomeButtonTapped: homeButton.rx.tap.asObservable()
        )
        
        // MARK: - output
        let output = viewModel.transform(input: input)
        
        output.rankingList
            .bind(to: tableView.rx.items(
                cellIdentifier: "RankingCell",
                cellType: RankingCell.self
            )) { row, element, cell in
                cell.configureCell(ranking: element, row: row)
            }.disposed(by: disposeBag)
        
        output.totalScore
            .bind(to: totalScoreLabel.rx.text)
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
