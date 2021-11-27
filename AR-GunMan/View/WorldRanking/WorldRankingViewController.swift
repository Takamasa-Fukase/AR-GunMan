//
//  WorldRankingViewController.swift
//  AR-GunMan
//
//  Created by Takahiro Fukase on 2021/11/13.
//

import UIKit
import Firebase
import RxSwift

class WorldRankingViewController: UIViewController {
    
    var db: Firestore!
    var list: [Ranking] = []
    let disposeBag = DisposeBag()

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var worldRankingTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        setupTableView()
        setupFirestore()
    }
    
    private func setupTableView() {
        worldRankingTableView.contentInset.top = 10
        worldRankingTableView.dataSource = self
        worldRankingTableView.register(UINib(nibName: "WorldRankingCell", bundle: nil), forCellReuseIdentifier: "WorldRankingCell")
    }
    
    private func setupFirestore() {
        db = Firestore.firestore()
        //自動更新を設定
        db.collection("worldRanking").order(by: "score", descending: true).addSnapshotListener{ snapshot, err in
            guard let snapshot = snapshot else {
                print("snapshotListener Error: \(String(describing: err))"); return
            }
            self.list = snapshot.documents.map { data -> Ranking in
                return Ranking(score: data.data()["score"] as? Double ?? 0.000, userName: data.data()["user_name"] as? String ?? "NO NAME")
            }

            self.activityIndicatorView.stopAnimating()
            self.worldRankingTableView.reloadData()
        }
    }
}

extension WorldRankingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorldRankingCell") as? WorldRankingCell
        cell?.nameLabel.text = list[indexPath.row].userName
        cell?.scoreLabel.text = String(list[indexPath.row].score)
        cell?.rankLabel.text = String(indexPath.row + 1)
        return cell ?? UITableViewCell()
    }
}
