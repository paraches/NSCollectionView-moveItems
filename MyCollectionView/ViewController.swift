//
//  ViewController.swift
//  MyCollectionView
//
//  Created by paraches on 2019/07/04.
//  Copyright © 2019 paraches. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var readButton: NSButton!
    
    let myItemName = "MyItem"
    let collectionViewItemId = NSUserInterfaceItemIdentifier(rawValue: "MyItem")
    var sampleItems = [MyItemHolder]()
    
    var draggedItems: Set<IndexPath>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = NSNib(nibNamed: NSNib.Name(myItemName), bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: collectionViewItemId)

        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.URL])
        collectionView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
        collectionView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: false)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func clickReadButton(_ sender: Any) {
        sampleItems.append(contentsOf: readImageFile())
        collectionView.reloadData()
    }
    
    @IBAction func clickDeleteButton(_ sender: Any) {
        if let collectionView = collectionView {
            let indexPaths = collectionView.selectionIndexPaths
            for indexPath in indexPaths.sorted().reversed() {
                sampleItems.remove(at: indexPath.item)
            }
            collectionView.animator().deleteItems(at: indexPaths)
            updateDeleteButtonState(collectionView)
        }
    }
    
    private func updateDeleteButtonState(_ collectionView: NSCollectionView) {
        deleteButton?.isEnabled = !collectionView.selectionIndexPaths.isEmpty
    }
    
    //
    //  MyItemHolder
    //
    func readImageFile() -> [MyItemHolder] {
        var itemHolders = [MyItemHolder]()
        
        let openFileDialog = NSOpenPanel()
        openFileDialog.allowsMultipleSelection = false
        openFileDialog.canChooseFiles = false
        openFileDialog.canChooseDirectories = true
        openFileDialog.canCreateDirectories = false
        if openFileDialog.runModal() == NSApplication.ModalResponse.OK {
            if let fileUrl = openFileDialog.url {
                do {
                    let files = try FileManager.default.contentsOfDirectory(at: fileUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    let newItems = readMyItemHolderFromUrls(urls: files)
                    itemHolders.append(contentsOf: newItems)
                }
                catch let error as NSError {
                    print("Error: \(error)")
                }
            }
        }
        return itemHolders.sorted(by: {$0.filename < $1.filename} )
    }

    func readMyItemHolderFromUrls(urls: [URL]) -> [MyItemHolder] {
        var items = [MyItemHolder]()
        for url in urls {
            items.append(MyItemHolder(url: url))
        }
        return items
    }
    
    func moveMyItemHolder(indexPaths: Set<IndexPath>, to toIndex: Int) {
        var arrangedToIndex = toIndex
        for indexPath in indexPaths {
            if toIndex > indexPath.item { arrangedToIndex -= 1}
        }
        
        var tempArray = [MyItemHolder]()
        for indexPath in indexPaths.sorted().reversed() {
            let deletedSample = sampleItems.remove(at: indexPath.item)
            tempArray.append(deletedSample)
        }
        for item in tempArray {
            sampleItems.insert(item, at: arrangedToIndex)
        }
    }

}

//
//  NSCollectionViewDataSource
//
extension ViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: collectionViewItemId, for: indexPath)
        let sampleItem = sampleItems[indexPath.item]
        item.imageView?.image = sampleItem.thumbnail
        item.textField?.stringValue = sampleItem.filename
        return item
        
    }
}


//
//  NSCollectionViewDelegate
//
extension ViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        updateDeleteButtonState(collectionView)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        updateDeleteButtonState(collectionView)
    }
    
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexes: IndexSet, with event: NSEvent) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt index: Int) -> NSPasteboardWriting? {
        return sampleItems[index].url as NSPasteboardWriting
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        draggedItems = indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
            proposedDropOperation.pointee = NSCollectionView.DropOperation.before
        }
        if draggedItems == nil {
            return NSDragOperation.copy
        }
        else {
            return NSDragOperation.move
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        if let draggedItems = draggedItems, let draggedItem = draggedItems.first {
            if draggedItems.count == 1 {
                let toIndexPath = NSIndexPath(forItem: draggedItem.item < indexPath.item ? indexPath.item - 1 : indexPath.item, inSection: indexPath.section)
                sampleItems.move(at: draggedItem.item, to: toIndexPath.item)
                collectionView.animator().moveItem(at: draggedItem, to: toIndexPath as IndexPath)
            }
            else {
                moveMyItemHolder(indexPaths: draggedItems, to: indexPath.item)
                collectionView.moveItems(at: draggedItems, to: indexPath)
            }
            return true
        }
        else {
            draggingInfo.enumerateDraggingItems(options: .concurrent, for: collectionView, classes: [NSURL.self], searchOptions: [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly: NSNumber(value: true)], using: { (draggingItem, idx, stop) in
                if let url = draggingItem.item as? NSURL {
                    let newItems = self.readMyItemHolderFromUrls(urls: [url as URL])
                    collectionView.animator().performBatchUpdates({
                        for item in newItems {
                            self.sampleItems.insert(item, at: indexPath.item)
                        }
                        var insertIndexPaths = [IndexPath]()
                        for (index, _) in newItems.enumerated() {
                            insertIndexPaths.append(IndexPath(item: index + indexPath.item, section: 0))
                        }
                        let insertIndexPathSet = Set(insertIndexPaths)
                        collectionView.insertItems(at: insertIndexPathSet)
                    })
                }
            })
        }
        return false
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        draggedItems = nil
    }
}
