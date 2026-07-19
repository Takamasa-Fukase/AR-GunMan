//
//  ErrorAlert.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/1/25.
//

import SwiftUI
import Core

struct ErrorAlert: ViewModifier {
    let error: Error?
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        let title: String = {
            if let customError = error as? CustomError {
                return customError.title
            } else {
                return ErrorConst.defaultAlertTitle
            }
        }()
        
        let message: String = {
            if let customError = error as? CustomError {
                return customError.message
            } else {
                return error?.localizedDescription ?? ""
            }
        }()
        
        return content
            .alert(
                title,
                isPresented: $isPresented,
                actions: {
                    Button(ErrorConst.defaultCloseButtonTitle) {}
                },
                message: {
                    Text(message)
                }
            )
    }
}

extension View {
    func errorAlert(
        _ error: Error?,
        isPresented: Binding<Bool>
    ) -> ModifiedContent<Self, ErrorAlert> {
        return modifier(ErrorAlert(error: error, isPresented: isPresented))
    }
}
