//
//  GameResultViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/11.
//

import UIKit
import Firebase
import PanModal

struct Ranking {
    let score: Double
    let userName: String
}

class GameResultViewController: UIViewController {

    //MARK: - Properties
    var totalScore: Double = 0.000
    var limitRankIndex = Int()
    var db: Firestore!
    var list: [Ranking] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var rightButtonsStackView: UIStackView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightButtonsStackView.isHidden = true
        replayButton.alpha = 0
        homeButton.alpha = 0
                
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

            self.tableView.reloadData()
                        
        }
        
        //背景をぼかし処理
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.frame
        
//        let blueView = UIView(frame: self.view.frame)
//        blueView.backgroundColor = .brown
//        blueView.alpha = 0.2
//        self.view.addSubview(blueView)
//        self.view.sendSubviewToBack(blueView)
        
        self.view.insertSubview(visualEffectView, at: 0)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let storyboard: UIStoryboard = UIStoryboard(name: "RegisterNameViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RegisterNameViewController") as! RegisterNameViewController
            vc.totalScore = self.totalScore
            vc.rankingCount = self.list.count
            vc.modalPresentationStyle = .overCurrentContext
            
            let threeDigitsScore = Double(round(1000 * self.totalScore)/1000)
            
            let limitRankIndex = self.list.firstIndex(where: {
                $0.score < threeDigitsScore
            })
            vc.tentativeRank = limitRankIndex ?? 0 + 1 + 1
            vc.registerNameVCDelegate = self
            
            self.presentPanModal(vc)
        }
        
    }
    
    @IBAction func tappedReplay(_ sender: Any) {
        dismissToTopVC(retry: true)
    }
    
    @IBAction func tappedHome(_ sender: Any) {
        dismissToTopVC()
    }
    
    func dismissToTopVC(retry: Bool = false) {
        let topVC = self.presentingViewController?.presentingViewController as! ViewController
        topVC.replayFlag = retry
        topVC.dismiss(animated: false, completion: nil)
    }
    
}

extension GameResultViewController: RegisterNameVCDelegate {
    
    func showRightButtons() {
        
        UIView.animate(withDuration: 0.6, delay: 0.1) {
            self.rightButtonsStackView.isHidden = false
            
        } completion: { (Bool) in
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.replayButton.alpha = 1
                self.homeButton.alpha = 1
            }
        }

    }
    
}

extension GameResultViewController: UITableViewDelegate, UITableViewDataSource {
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
