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
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var rankingListBaseView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        setupTapDismiss()
    }
    
    private func setupUI() {
        rankingListBaseView.addSubview(rankingListView)
        rankingListBaseView.addConstraints(for: rankingListView)
    }
    
    private func bindViewModel() {
        let input = RankingViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            closeButtonTapped: closeButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        rankingListView.bind(
            rankingList: output.rankingList,
            isLoading: output.isLoading
        )
    }
    
    //枠外タップでdismissの設定をつける
    private func setupTapDismiss() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissByTap))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func dismissByTap() {
        dismiss(animated: true)
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
