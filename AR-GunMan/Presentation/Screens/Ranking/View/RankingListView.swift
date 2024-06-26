//
//  RankingListView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 13/6/24.
//

import RxSwift
import RxCocoa

final class RankingListView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func bind(
        rankingList: Driver<[Ranking]>,
        isLoading: Driver<Bool>
    ) -> Cancelable {
        return Disposables.create(
            rankingList
                .drive(tableView.rx.items(
                    cellIdentifier: RankingCell.className,
                    cellType: RankingCell.self
                )) { row, element, cell in
                    cell.configure(ranking: element, row: row)
                },
            isLoading
                .drive(activityIndicatorView.rx.isAnimating)
        )
    }
    
    func scrollCellToCenterVertically(at indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    private func configure() {
        loadNib()
        setupUI()
    }
    
    private func setupUI() {
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: RankingCell.className, bundle: nil), forCellReuseIdentifier: RankingCell.className)
        activityIndicatorView.hidesWhenStopped = true
    }
}
