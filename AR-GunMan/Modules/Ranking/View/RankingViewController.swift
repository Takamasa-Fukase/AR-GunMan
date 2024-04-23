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
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapDismiss()
        setupTableView()
        
        let input = RankingViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            closeButtonTapped: closeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.rankingList
            .bind(to: tableView.rx.items(
                cellIdentifier: "RankingCell",
                cellType: RankingCell.self
            )) { row, element, cell in
                cell.configure(ranking: element, row: row)
            }.disposed(by: disposeBag)

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
    
    //枠外タップでdismissの設定をつける
    private func setupTapDismiss() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissByTap))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func dismissByTap() {
        self.dismiss(animated: true)
    }
    
    private func setupTableView() {
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: "RankingCell", bundle: nil), forCellReuseIdentifier: "RankingCell")
    }
}

extension RankingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.view {
            return true
        } else {
            return false
        }
    }
}
