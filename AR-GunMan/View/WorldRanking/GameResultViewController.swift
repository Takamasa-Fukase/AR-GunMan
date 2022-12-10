//
//  GameResultViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/11.
//

import UIKit
import RxSwift
import RxCocoa
import PanModal

class GameResultViewController: UIViewController {

    //MARK: - Properties
    let viewModel = RankingViewModel()
    let disposeBag = DisposeBag()
    
    var totalScore: Double = 0.000
    var limitRankIndex = Int()
    var rankingList: [Ranking] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var rightButtonsStackView: UIStackView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    //MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //input
        viewModel.getRanking.onNext(Void())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialUI()
        setupTableView()
        setupBlurEffect()
        showRegisterNameVC()
        
        //input
        let _ = replayButton.rx.tap
            .bind(to: viewModel.replayButtonTapped)
            .disposed(by: disposeBag)
        
        let _ = homeButton.rx.tap
            .bind(to: viewModel.toHomeButtonTapped)
            .disposed(by: disposeBag)
        
        //output
        let _ = viewModel.rankingList
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                guard let element = element else {return}
                self.rankingList = element
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        let _ = viewModel.backToTopPageWithReplay
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.dismissToTopVC(retry: element)
            }).disposed(by: disposeBag)
    }
    
    private func setupInitialUI() {
        rightButtonsStackView.isHidden = true
        replayButton.alpha = 0
        homeButton.alpha = 0
        totalScoreLabel.text = String(format: "%.3f", totalScore)
    }
    
    private func setupTableView() {
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: "WorldRankingCell", bundle: nil), forCellReuseIdentifier: "WorldRankingCell")
    }
    
    private func setupBlurEffect() {
        //背景をぼかし処理
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.frame
        self.view.insertSubview(visualEffectView, at: 0)
    }
    
    private func showRegisterNameVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let storyboard: UIStoryboard = UIStoryboard(name: "RegisterNameViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RegisterNameViewController") as! RegisterNameViewController
            vc.totalScore = self.totalScore
            vc.rankingCount = self.rankingList.count
            vc.modalPresentationStyle = .overCurrentContext
            
            let threeDigitsScore = Double(round(1000 * self.totalScore)/1000)
            
            let limitRankIndex = self.rankingList.firstIndex(where: {
                $0.score < threeDigitsScore
            })
            vc.tentativeRank = limitRankIndex ?? 0 + 1 + 1
            vc.registerNameVCDelegate = self
            
            self.presentPanModal(vc)
        }
    }
    
    private func dismissToTopVC(retry: Bool = false) {
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
        return rankingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorldRankingCell") as? WorldRankingCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = rankingList[indexPath.row].userName
        cell.scoreLabel.text = String(rankingList[indexPath.row].score)
        cell.rankLabel.text = String(indexPath.row + 1)
        return cell
    }
    
}
