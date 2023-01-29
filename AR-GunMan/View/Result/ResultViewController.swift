//
//  ResultViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/11.
//

import UIKit
import RxSwift
import RxCocoa
import PanModal

class ResultViewController: UIViewController {
    var viewModel: ResultViewModel!
    let disposeBag = DisposeBag()
    var totalScore: Double = 0.000
    var limitRankIndex = Int()
    var rankingList: [Ranking] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var rightButtonsStackView: UIStackView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - input
        viewModel = ResultViewModel(
            input: .init(viewWillAppear: rx.viewWillAppear,
                         replayButtonTapped: replayButton.rx.tap.asObservable(),
                         toHomeButtonTapped: homeButton.rx.tap.asObservable()))
        
        // MARK: - output
        viewModel.rankingList
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                guard let element = element else {return}
                self.rankingList = element
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.showNameRegisterView
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.showNameRegisterVC()
            }).disposed(by: disposeBag)
        
        viewModel.showButtons
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.showButtons()
            }).disposed(by: disposeBag)
        
        viewModel.backToTopPageViewWithReplay
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.dismissToTopVC(isReplay: element)
            }).disposed(by: disposeBag)
        
        setupUI()
    }
    
    private func setupUI() {
        insertBlurEffectView()
        rightButtonsStackView.isHidden = true
        replayButton.alpha = 0
        homeButton.alpha = 0
        totalScoreLabel.text = String(format: "%.3f", totalScore)
        tableView.contentInset.top = 10
        tableView.register(UINib(nibName: "RankingCell", bundle: nil), forCellReuseIdentifier: "RankingCell")
    }
    
    private func showNameRegisterVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "NameRegisterViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! NameRegisterViewController
        vc.totalScore = self.totalScore
        vc.rankingCount = self.rankingList.count
        vc.modalPresentationStyle = .overCurrentContext
        
        let threeDigitsScore = Double(round(1000 * self.totalScore)/1000)
        
        let limitRankIndex = self.rankingList.firstIndex(where: {
            $0.score < threeDigitsScore
        })
        vc.tentativeRank = limitRankIndex ?? 0 + 1 + 1
        vc.delegate = viewModel
        
        self.presentPanModal(vc)
    }
    
    private func showButtons() {
        UIView.animate(withDuration: 0.6, delay: 0.1) {
            self.rightButtonsStackView.isHidden = false
            
        } completion: { (Bool) in
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.replayButton.alpha = 1
                self.homeButton.alpha = 1
            }
        }
    }
    
    private func dismissToTopVC(isReplay: Bool = false) {
        let topVC = self.presentingViewController?.presentingViewController as! ViewController
        UserDefaults.isReplay = isReplay
        topVC.dismiss(animated: false, completion: nil)
    }
}

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
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
