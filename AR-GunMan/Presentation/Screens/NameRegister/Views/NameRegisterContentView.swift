//
//  NameRegisterContentView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import UIKit

final class NameRegisterContentView: UIView, BackgroundViewTapTrackable {
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankLabelSpinner: UIActivityIndicatorView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerButtonSpinner: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        loadNib()
        setupUI()
    }
    
    private func setupUI() {
        nameTextField.delegate = self
        registerButton.setTitleColor(.black.withAlphaComponent(0.1), for: .disabled)
        rankLabelSpinner.hidesWhenStopped = true
        registerButtonSpinner.hidesWhenStopped = true
    }
}

extension NameRegisterContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
