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

    var totalScore: Double = 0.000
    var limitRankIndex = Int()
    var db: Firestore!
    var list: [Ranking] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalScore = Double.random(in: 0...100)
        
        totalScoreLabel.text = String(format: "%.3f", totalScore)
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: "WorldRankingCell", bundle: nil), forCellReuseIdentifier: "WorldRankingCell")
        
        db = Firestore.firestore()
        //自動更新を設定
        db.collection("worldRanking").order(by: "score", descending: true).addSnapshotListener{ snapshot, err in
            guard let snapshot = snapshot else {
                print("snapshotListener Error: \(String(describing: err))"); return
            }
            self.list = snapshot.documents.map { data -> Ranking in
                return Ranking(score: data.data()["score"] as? Double ?? 0.000, userName: data.data()["user_name"] as? String ?? "NO NAME")
            }
            
            if !self.list.isEmpty {
                
                let threeDigitsScore = Double(round(1000 * self.totalScore)/1000)
                
                let limitRankIndex = self.list.firstIndex(where: {
                    $0.score < threeDigitsScore
                })
                self.limitRankIndex = limitRankIndex ?? 0
                
                self.list.insert(Ranking(score: threeDigitsScore, userName: "YOU"), at: limitRankIndex ?? 0)
                
                self.tableView.reloadData()
                
            }
                        
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
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let storyboard: UIStoryboard = UIStoryboard(name: "RegisterNameViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RegisterNameViewController") as! RegisterNameViewController
            vc.totalScore = self.totalScore
            vc.tentativeRank = self.limitRankIndex + 1
            vc.rankingCount = self.list.count
            self.present(vc, animated: true)
        }

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
        
        if indexPath.row == limitRankIndex {
            
            cell?.contentView.subviews[0].backgroundColor = UIColor(red: 255/255, green: 217/255, blue: 0/255, alpha: 1)
            cell?.contentView.subviews[1].backgroundColor = UIColor(red: 255/255, green: 190/255, blue: 0/255, alpha: 1)
        }else {
            
            cell?.contentView.subviews[0].backgroundColor = UIColor(red: 52/255, green: 78/255, blue: 130/255, alpha: 1)
            cell?.contentView.subviews[1].backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 148/255, alpha: 1)
            
        }
        
        return cell ?? UITableViewCell()
    }
    
}
