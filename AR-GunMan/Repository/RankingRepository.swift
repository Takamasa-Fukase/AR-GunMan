//
//  RankingRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/31.
//

import Foundation
import Firebase
import RxSwift
import FirebaseFirestoreSwift

class RankingRepository {
    private let firestoreDataBase = Firestore.firestore()
    
    func getRanking() -> Single<[Ranking]> {
        return Single.create { [weak self] observer in
            self?.firestoreDataBase
                .collection("worldRanking")
                .order(by: "score", descending: true)
                .getDocuments { querySnapshot, error in
                    guard let querySnapshot = querySnapshot else {
                        observer(.failure(error ?? NSError()))
                        return
                    }
                    let rankings = querySnapshot
                        .documents
                        .compactMap({ queryDocSnapshot in
                            return try? queryDocSnapshot.data(as: Ranking.self)
                        })
                    observer(.success(rankings))
                }
            return Disposables.create()
        }
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Ranking> {
        // TODO: 何とかもう少し綺麗にしたい
        return Single.create { [weak self] observer in
            do {
                let data = try JSONEncoder().encode(ranking)
                if let dict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] {
                    self?.firestoreDataBase
                        .collection("worldRanking")
                        .document()
                        .setData(dict) { error in
                            if let error = error {
                                observer(.failure(error))
                            }else {
                                observer(.success(ranking))
                            }
                        }
                }else {
                    observer(.failure(NSError()))
                }
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
}
