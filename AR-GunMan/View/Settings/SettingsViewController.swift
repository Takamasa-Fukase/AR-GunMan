//
//  SettingsViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedDeveloperConctact(_ sender: Any) {
        openSafariView(urlString: Const.developerContactURL)
    }
    
    @IBAction func tappedPrivacyPolicy(_ sender: Any) {
        openSafariView(urlString: Const.privacyPolicyURL)
    }
    
    @IBAction func tappedBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openSafariView(urlString: String) {
        let safariVC = SFSafariViewController(url: NSURL(string: urlString)! as URL)
        present(safariVC, animated: true, completion: nil)
    }
}
