//
//  TutorialViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit

class TutorialViewController: UIViewController {

    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bottomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        
        if getCurrentScrollViewIndex() == 2 {
            print("OK tapped")
            self.dismiss(animated: true, completion: nil)
        }else {
            scrollPage()
        }
                
    }
    
    func getCurrentScrollViewIndex() -> Int {
        let contentsOffSetX: CGFloat = scrollView.contentOffset.x
        let pageIndex = Int(round(contentsOffSetX / scrollView.frame.width))
        print("currentIndex: \(pageIndex)")
        return pageIndex
    }
    
    func scrollPage() {
        guard !scrollView.isDecelerating else {
            print("scrollview is still decelerating")
            return
        }
        let frameWidth = scrollView.frame.width
        
        let targetContentOffsetX = frameWidth * CGFloat(min(getCurrentScrollViewIndex() + 1, 2))
        let targetCGPoint = CGPoint(x: targetContentOffsetX, y: 0)
        scrollView.setContentOffset(targetCGPoint, animated: true)
    }
    
}

extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        pageControl.currentPage = getCurrentScrollViewIndex()
        
        if pageControl.currentPage == 2 {
            bottomButton.setTitle("OK", for: .normal)
        }else {
            bottomButton.setTitle("NEXT", for: .normal)
        }
        
    }
    
}
