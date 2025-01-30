//
//  WeaponSelectView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 15/12/24.
//

import SwiftUI
import Domain

struct WeaponSelectView: View {
    @State var viewModel: WeaponSelectViewModel
    let weaponSelected: (Int) -> Void
    
    var body: some View {
        WeaponSelectViewControllerRepresentable(
            weaponSelected: weaponSelected,
            weaponListItems: viewModel.weaponListItems
        )
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}

struct WeaponSelectViewControllerRepresentable: UIViewControllerRepresentable {
    let weaponSelected: (Int) -> Void
    let weaponListItems: [WeaponListItem]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> WeaponSelectViewController {
        return WeaponSelectViewController(
            weaponSelected: { weaponId in
                // このViewの利用側へ選択されたweaponIdをコールバック
                weaponSelected(weaponId)
                // 画面を閉じる
                dismiss()
            }
        )
    }
    
    func updateUIViewController(_ uiViewController: WeaponSelectViewController, context: Context) {
        uiViewController.updateWeaponListItems(weaponListItems)
    }
}
