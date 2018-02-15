//
//  TableViewController.swift
//  UIScrollView-Refresh
//
//  Created by Dmitry on 15.02.18.
//  Copyright © 2018 Dmitry Popravka. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    fileprivate var items: [String] = []
    
    fileprivate let cellReuseIdentifier: String = "TableCellReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.addHeader(withTarget: self, action: #selector(self.headerRefresh(sender:)))
        table.addFooter(withTarget: self, action: #selector(self.footerRefresh(sender:)))
        
        table.headerBeginRefreshing()
    }

    //MARK: -
    //MARK: refresh
    
    @objc private func headerRefresh(sender:AnyObject) {
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1) {
            debugPrint(#function)
            self.items = self.getItems()
            self.table.reload()
            self.table.headerEndRefreshing()
        }
        
    }
    
    
    @objc private func footerRefresh(sender:AnyObject) {
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1) {
            debugPrint(#function)
            self.items += self.getItems()
            self.table.reload()
            self.table.footerEndRefreshing()
        }
    }
    
    private func getItems() -> [String] {
        return Array(repeating: "", count: 20)
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func tableCell(_ table: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = table.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:cellReuseIdentifier)
        }
        
        cell.textLabel?.text = "item \(indexPath.row + 1)"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableCell(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

//MARK: - UITableView extension
extension UITableView {
    
    func reload() {
        DispatchQueue.main.async {
            UIView.transition(with: self, duration: 0.05, options: .transitionCrossDissolve, animations: {
                self.reloadData()
            }, completion: nil)
        }
    }
}
