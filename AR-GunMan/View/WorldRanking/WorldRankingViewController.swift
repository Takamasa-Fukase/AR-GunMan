//
//  WorldRankingViewController.swift
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

class WorldRankingViewController: UIViewController {

    var totalScore: Double = 0.000
    var limitRankIndex = Int()
    var db: Firestore!
    var list: [Ranking] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var rightButtonsStackView: UIStackView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
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
            
//            if !self.list.isEmpty {
//
//                let threeDigitsScore = Double(round(1000 * self.totalScore)/1000)
//
//                let limitRankIndex = self.list.firstIndex(where: {
//                    $0.score < threeDigitsScore
//                })
//                self.limitRankIndex = limitRankIndex ?? 0
//
//                self.list.insert(Ranking(score: threeDigitsScore, userName: "YOU"), at: limitRankIndex ?? 0)
//
//            }
            
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
//            vc.tentativeRank = self.limitRankIndex + 1
            vc.rankingCount = self.list.count
            vc.modalPresentationStyle = .overCurrentContext
            
            let threeDigitsScore = Double(round(1000 * self.totalScore)/1000)
            
            let limitRankIndex = self.list.firstIndex(where: {
                $0.score < threeDigitsScore
            })
            vc.tentativeRank = limitRankIndex ?? 0 + 1
            vc.registerNameVCDelegate = self
            
            let navi = UINavigationController(rootViewController: vc)
            navi.setNavigationBarHidden(true, animated: false)
//            self.present(vc, animated: true)
            
            self.presentPanModal(navi)
        }
        
        

    }
    
    @IBAction func tappedReplay(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedHome(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension WorldRankingViewController: RegisterNameVCDelegate {
    
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

extension WorldRankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorldRankingCell") as? WorldRankingCell
        cell?.nameLabel.text = list[indexPath.row].userName
        cell?.scoreLabel.text = String(list[indexPath.row].score)
        cell?.rankLabel.text = String(indexPath.row + 1)
        
//        if indexPath.row == limitRankIndex {
//
//            cell?.contentView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
//            cell?.contentView.subviews[0].backgroundColor = UIColor(red: 135/255, green: 125/255, blue: 116/255, alpha: 1)
//            cell?.contentView.subviews[1].backgroundColor = UIColor(red: 202/255, green: 177/255, blue: 136/255, alpha: 0.58)
//            cell?.nameLabel.textColor = UIColor(red: 255/255, green: 224/255, blue: 173/255, alpha: 1)
//            cell?.scoreLabel.textColor = UIColor(red: 255/255, green: 224/255, blue: 173/255, alpha: 1)
//        }else {
//
//            cell?.contentView.backgroundColor = .clear
//            cell?.contentView.subviews[0].backgroundColor = UIColor(red: 85/255, green: 78/255, blue: 72/255, alpha: 1)
//            cell?.contentView.subviews[1].backgroundColor = UIColor(red: 110/255, green: 102/255, blue: 94/255, alpha: 1)
//            cell?.nameLabel.textColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
//            cell?.scoreLabel.textColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
//        }
        
        return cell ?? UITableViewCell()
    }
    
}

extension UINavigationController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        nil
    }
    
    public var topOffset: CGFloat {
        return 0.0
    }

    public var springDamping: CGFloat {
        return 1.0
    }

    public var transitionDuration: Double {
        return 0.4
    }

    public var transitionAnimationOptions: UIView.AnimationOptions {
        return [.allowUserInteraction, .beginFromCurrentState]
    }

    public var shouldRoundTopCorners: Bool {
        return false
    }

    public var showDragIndicator: Bool {
        return false
    }
    
    public var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
}
