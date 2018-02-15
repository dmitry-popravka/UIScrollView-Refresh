//
//  CollectionViewController.swift
//  UIScrollView-Refresh
//
//  Created by Dmitry on 15.02.18.
//  Copyright © 2018 Dmitry Popravka. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collection: UICollectionView!

    fileprivate var items: [String] = []
    
    fileprivate let cellReuseIdentifier: String = "CollectionCellReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collection.addHeader(withTarget: self, action: #selector(self.headerRefresh(sender:)))
        collection.addFooter(withTarget: self, action: #selector(self.footerRefresh(sender:)))
        
        collection.headerBeginRefreshing()
    }
    
    //MARK: -
    //MARK: refresh
    
    @objc private func headerRefresh(sender:AnyObject) {
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1) {
            debugPrint(#function)
            self.items = self.getItems()
            self.collection.reload()
            self.collection.headerEndRefreshing()
        }
        
    }
    
    
    @objc private func footerRefresh(sender:AnyObject) {
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1) {
            debugPrint(#function)
            self.items += self.getItems()
            self.collection.reload()
            self.collection.footerEndRefreshing()
        }
    }

    private func getItems() -> [String] {
        return Array(repeating: "", count: 30)
    }

}

//MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CollectionViewCell

        cell.textLabel.text = "item \(indexPath.row + 1)"
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor

        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 3
        return CGSize(width: width, height: width)
    }
}


//MARK: - CollectionViewCell
class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
}


//MARK: - UITableView extension
extension UICollectionView {
    
    func reload() {
        DispatchQueue.main.async {
            UIView.transition(with: self, duration: 0.05, options: .transitionCrossDissolve, animations: {
                self.reloadData()
            }, completion: nil)
        }
    }
}

