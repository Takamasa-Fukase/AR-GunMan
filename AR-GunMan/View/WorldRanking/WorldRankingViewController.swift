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
