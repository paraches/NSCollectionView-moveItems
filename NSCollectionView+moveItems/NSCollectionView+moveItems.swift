//
//  NSCollectionView+moveItems.swift
//  MyCollectionView
//
//  Created by paraches on 2019/07/08.
//  Copyright © 2019 paraches. All rights reserved.
//

import Foundation
import Cocoa

extension NSCollectionView {
    func moveItems(at items: Set<IndexPath>, to indexPath: IndexPath, completionHandler handler: ((Bool) -> Void)? = nil) {
        var deleteCount = 0
        for moveItem in items {
            if moveItem.item < indexPath.item { deleteCount += 1}
        }
        animator().performBatchUpdates({
            deleteItems(at: items)
            var insertIndexPaths = [IndexPath]()
            for (index, _) in items.enumerated() {
                insertIndexPaths.append(IndexPath(item: indexPath.item + index - deleteCount, section: 0))
            }
            insertItems(at: Set(insertIndexPaths))
        },
        completionHandler: { finished in
            print("batch is finished: \(finished)")
            guard let handler = handler else { return }
            handler(finished)
        })
    }
}
