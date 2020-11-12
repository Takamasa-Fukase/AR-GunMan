//
//  WorldRankingViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/11.
//

import UIKit
import Firebase

struct Ranking {
    let score: String
    let userName: String
}

class WorldRankingViewController: UIViewController {

    var db: Firestore!
    var list: [Ranking] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        //自動更新を設定
        db.collection("worldRanking").order(by: "score").addSnapshotListener{ snapshot, err in
            guard let snapshot = snapshot else {
                print("snapshotListener Error: \(String(describing: err))"); return
            }
            self.list = snapshot.documents.map { data -> Ranking in
                return Ranking(score: data.data()["score"] as! String, userName: data.data()["user_name"] as! String)
            }
            self.tableView.reloadData()
        }
        
        //背景をぼかし処理
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.frame
        self.view.insertSubview(visualEffectView, at: 0)

    }
    
}

extension WorldRankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = list[indexPath.row].userName
        cell.detailTextLabel?.text = list[indexPath.row].score
        return cell
    }
    
    
    
    
}
