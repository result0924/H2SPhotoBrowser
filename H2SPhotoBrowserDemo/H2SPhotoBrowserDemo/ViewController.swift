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
        let photos = [H2SPhoto.photo(with: UIImage(named: "local_0")), H2SPhoto.photo(with: UIImage(named: "local_1")), H2SPhoto.photo(with: UIImage(named: "local_2"))]
        let browser = H2SPhotoBrowser(photos: photos, currentIndex: indexPath.row)
        browser.pageIndex = indexPath.item
        browser.show()
    }
}

