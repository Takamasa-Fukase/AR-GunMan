//
//  SafariViewUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/30.
//

import Foundation
import SafariServices

final class SafariViewUtil {
    static func openSafariView(urlString: String, vc: UIViewController?) {
        let safariVC = SFSafariViewController(url: NSURL(string: urlString)! as URL)
        vc?.present(safariVC, animated: true, completion: nil)
    }
}
