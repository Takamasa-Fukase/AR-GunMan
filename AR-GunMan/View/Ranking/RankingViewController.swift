//
//  RankingViewController.swift
//  AR-GunMan
//
//  Created by Takahiro Fukase on 2021/11/13.
//

import UIKit
import RxSwift
import RxCocoa

class RankingViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel: RankingViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapDismiss()
        setupTableView()
        
        // input
        viewModel = RankingViewModel(
            input: .init(viewWillAppear: rx.viewWillAppear,
                         closeButtonTapped: closeButton.rx.tap.asObservable()),
            dependency: RankingRepository())
        
        // output
        viewModel.rankingList
            .bind(to: tableView.rx.items(
                cellIdentifier: "RankingCell",
                cellType: RankingCell.self
            )) { row, element, cell in
                cell.configureCell(ranking: element, row: row)
            }.disposed(by: disposeBag)
        
        viewModel.dismiss
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [weak self] element in
                guard let self = self else { return }
                if element {
                    self.activityIndicatorView.startAnimating()
                }else {
                    self.activityIndicatorView.stopAnimating()
                }
            }).disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] element in
                guard let self = self else { return }
                self.present(UIAlertController.errorAlert(element), animated: true)
            }).disposed(by: disposeBag)
    }
    
    //枠外タップでdismissの設定をつける
    private func setupTapDismiss() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissByTap))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissByTap() {
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
