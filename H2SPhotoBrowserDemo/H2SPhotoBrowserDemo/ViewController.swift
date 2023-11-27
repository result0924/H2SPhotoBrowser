//
//  ViewController.swift
//  H2SPhotoBrowserDemo
//
//  Created by Justin Lai on 2023/11/27.
//

import H2SPhotoBrowser
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "Local photo browser"
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let browser = H2SPhotoBrowser()
        browser.numberOfItems = {
            return 6
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? H2SPhotoBrowserImageCell
            let indexPath = IndexPath(item: context.index, section: indexPath.section)
            browserCell?.imageView.image = UIImage(named: "local_\(indexPath.row)")
        }
        browser.pageIndex = indexPath.item

        browser.show()
    }
}

