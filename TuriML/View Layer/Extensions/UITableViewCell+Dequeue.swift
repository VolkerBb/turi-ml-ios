//
//  UITableViewCell+Dequeue.swift
//  BarmerServiceApp2018
//
//  Created by Volker Bublitz on 23.02.18.
//  Copyright © 2018 T-Systems Multimedia Solutions GmbH. All rights reserved.
//
import UIKit

extension UITableViewCell {
    
    fileprivate static func dequeueGenerics<V: UITableViewCell>(fromTableView tableView:UITableView, indexPath: IndexPath) -> V {
        let identifier = String(describing: V.self)
        guard let result = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? V else {
            let msgFormat = "Unable to instantiate table view cell with identifier %@ from tableView"
            fatalError(String(format: msgFormat, identifier))
        }
        return result
    }
    
    static func dequeue(fromTableView tableView:UITableView, indexPath: IndexPath) -> Self {
        return UITableViewCell.dequeueGenerics(fromTableView: tableView, indexPath: indexPath)
    }
}
