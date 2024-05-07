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

protocol RankingRepositoryInterface {
    func getRanking() -> Single<[Ranking]>
    func registerRanking(_ ranking: Ranking) -> Single<Ranking>
}

final class RankingRepository: RankingRepositoryInterface {
    private let firestoreDataBase = Firestore.firestore()
    
    func getRanking() -> Single<[Ranking]> {
        return Single.create { [weak self] observer in
            self?.firestoreDataBase
                .collection(FirebaseConst.rankingListCollectionName)
                .order(by: FirebaseConst.scoreFieldName, descending: true)
                .getDocuments { querySnapshot, error in
                    guard let querySnapshot = querySnapshot else {
                        if let error = error {
                            observer(.failure(CustomError.apiClientError(error)))
                        }else {
                            observer(.failure(CustomError.manualError(ErrorConst.unknownErrorMessage)))
                        }
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
                        .collection(FirebaseConst.rankingListCollectionName)
                        .document()
                        .setData(dict) { error in
                            if let error = error {
                                observer(.failure(CustomError.apiClientError(error)))
                            }else {
                                observer(.success(ranking))
                            }
                        }
                }else {
                    observer(.failure(CustomError.manualError(ErrorConst.unknownErrorMessage)))
                }
            } catch {
                // TODO: ネットワークエラーとサーバーエラーのハンドリング
                observer(.failure(CustomError.apiClientError(error)))
            }
            return Disposables.create()
        }
    }
}

final class MockRankingRepository: RankingRepositoryInterface {
    func getRanking() -> Single<[Ranking]> {
        let dummyRankingList = Array<Int>(1...100).map({ index in
            return Ranking(score: Double(101 - index), userName: "ダミーユーザー\(index)")
        })
        return Single.create(subscribe: { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                observer(.success(dummyRankingList))
            })
            return Disposables.create()
        })
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Ranking> {
        return Single.create(subscribe: { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                return observer(.success(ranking))
            })
            return Disposables.create()
        })
    }
}
