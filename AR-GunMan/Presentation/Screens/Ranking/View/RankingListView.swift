//
//  RankingListView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 13/6/24.
//

import RxSwift
import RxCocoa

final class RankingListView: UIView {
    private let disposeBag = DisposeBag()
    
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
        rankingList: Observable<[Ranking]>,
        isLoading: Observable<Bool>
    ) {
        rankingList
            .bind(to: tableView.rx.items(
                cellIdentifier: RankingCell.className,
                cellType: RankingCell.self
            )) { row, element, cell in
                cell.configure(ranking: element, row: row)
            }.disposed(by: disposeBag)
        
        isLoading
            .bind(to: activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    func scrollCellToCenterVertically(at indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    private func configure() {
        let nib = UINib(nibName: RankingListView.className, bundle: nil)
        guard let view = nib.instantiate(withOwner: self).first as? UIView else { return }
        addSubview(view)
        addConstraints(for: view)
        
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: RankingCell.className, bundle: nil), forCellReuseIdentifier: RankingCell.className)
        activityIndicatorView.hidesWhenStopped = true
    }
}
