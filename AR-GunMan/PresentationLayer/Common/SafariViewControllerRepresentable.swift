//
//  SafariViewControllerRepresentable.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/12/24.
//

import SafariServices
import SwiftUI

struct SafariViewControllerRepresentable: UIViewControllerRepresentable {
    var url: URL
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let safariViewController = SFSafariViewController(url: url)
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
