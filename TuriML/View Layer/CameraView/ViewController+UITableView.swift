//
//  ViewController+UITableView.swift
//  TuriML
//
//  Created by Volker Bublitz on 25.09.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import UIKit

extension Array where Iterator.Element == DetectionResult {
    func containsTitle(ofOtherResult other: DetectionResult) -> Bool {
        return self.contains(where: { (result) -> Bool in
            return result.name == other.name
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detectedObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DetectedObjectTableViewCell.dequeue(fromTableView: tableView, indexPath: indexPath)
        if let title = detectedObjects[indexPath.row].name {
            cell.label.text = ModelLabelWrapper.map[title]
            cell.icon.image = UIImage(named: title)
        }
        return cell
    }
    
    func register(object: DetectionResult) {
        guard !detectedObjects.containsTitle(ofOtherResult: object) else {
            return
        }
        detectedObjects.append(object)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            detectedObjects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
