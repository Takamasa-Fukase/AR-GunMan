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
        //        WeaponSelectViewControllerRepresentable(
        //            weaponSelected: weaponSelected,
        //            weaponListItems: viewModel.weaponListItems
        //        )
        Text("Weapon Select")
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

//struct WeaponSelectViewControllerRepresentable: UIViewControllerRepresentable {
//    private var weaponSelected: (Int) -> Void
//    private var weaponListItems: [WeaponListItem]
//    @Environment(\.dismiss) private var dismiss
//    
//    init(
//        weaponSelected: @escaping (Int) -> Void,
//        weaponListItems: [WeaponListItem]
//    ) {
//        self.weaponSelected = weaponSelected
//        self.weaponListItems = weaponListItems
//    }
//    
//    func makeUIViewController(context: Context) -> WeaponSelectViewController {
//        let weaponSelectVC = WeaponSelectViewController()
//        weaponSelectVC.weaponSelected = { weaponId in
//            // このViewの利用側へ選択されたweaponIdをコールバック
//            weaponSelected(weaponId)
//            // 画面を閉じる
//            dismiss()
//        }
//        return weaponSelectVC
//    }
//    
//    func updateUIViewController(_ uiViewController: WeaponSelectViewController, context: Context) {
//        uiViewController.updateWeaponListItems(weaponListItems)
//    }
//}
