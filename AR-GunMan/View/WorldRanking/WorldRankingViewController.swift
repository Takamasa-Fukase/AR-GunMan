//
//  WorldRankingViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/11.
//

import UIKit
import Firebase

struct Ranking {
    let score: Double
    let userName: String
}

class WorldRankingViewController: UIViewController {

    var db: Firestore!
    var list: [Ranking] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: "WorldRankingCell", bundle: nil), forCellReuseIdentifier: "WorldRankingCell")
        
        db = Firestore.firestore()
        //自動更新を設定
        db.collection("worldRanking").order(by: "score").addSnapshotListener{ snapshot, err in
            guard let snapshot = snapshot else {
                print("snapshotListener Error: \(String(describing: err))"); return
            }
            self.list = snapshot.documents.map { data -> Ranking in
                return Ranking(score: data.data()["score"] as? Double ?? 0.000, userName: data.data()["user_name"] as? String ?? "NO NAME")
            }
            self.tableView.reloadData()
        }
        
        //背景をぼかし処理
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.frame
        
        let blueView = UIView(frame: self.view.frame)
        blueView.backgroundColor = .blue
        blueView.alpha = 0.2
        
        self.view.addSubview(blueView)
        self.view.sendSubviewToBack(blueView)
        
        self.view.insertSubview(visualEffectView, at: 0)

    }
    
}

extension WorldRankingViewController: UITableViewDelegate, UITableViewDataSource {
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
