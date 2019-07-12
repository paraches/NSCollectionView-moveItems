//
//  MyItem.swift
//  MyCollectionView
//
//  Created by paraches on 2019/07/04.
//  Copyright © 2019 paraches. All rights reserved.
//

import Cocoa

class MyItem: NSCollectionViewItem {

    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 3.0 : 0.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.darkGray.cgColor
        view.layer?.cornerRadius = 2.0
        let borderWhite = NSColor(white: 1.0, alpha: 0.5).cgColor
        view.layer?.borderColor = borderWhite
        view.layer?.borderWidth = 0.0
    }
    
}
