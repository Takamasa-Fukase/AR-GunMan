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
    let viewModel = RankingViewModel()
    let disposeBag = DisposeBag()
    var rankingList: [Ranking] = []

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var worldRankingTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //input
        viewModel.getRanking.onNext(Void())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapDismiss()
        setupTableView()
        
        //output
        let _ = viewModel.rankingList
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                guard let element = element else {return}
                self.rankingList = element
                self.activityIndicatorView.stopAnimating()
                self.worldRankingTableView.reloadData()
            }).disposed(by: disposeBag)
        
        //other
        let _ = closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.dismiss(animated: true)
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
        worldRankingTableView.contentInset.top = 10
        worldRankingTableView.dataSource = self
        worldRankingTableView.register(UINib(nibName: "RankingCell", bundle: nil), forCellReuseIdentifier: "RankingCell")
    }
}

extension RankingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell") as? RankingCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = rankingList[indexPath.row].userName
        cell.scoreLabel.text = String(rankingList[indexPath.row].score)
        cell.rankLabel.text = String(indexPath.row + 1)
        return cell
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
