//
//  GameViewController.swift
//  Fryes
//
//  Created by Jarvis Wu on 2018-11-15.
//  Copyright © 2018 Jarvis Wu. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // hardcode data for testing
    let data = [("Danny Green", "1st 09:16"),
                ("Kyle Lowry", "1st 04:02"),
                ("Danny Green", "2nd 10:30"),
                ("Kawhi Leonard", "2nd 08:06"),
                ("Kyle Lowry", "2nd 05:47"),
                ("CJ Miles", "2nd 00:25"),
                ("Delon Wright", "3rd 08:52"),
                ("Fred VanVleet", "3rd 02:49"),
                ("Serge Ibaka", "4th 08:23"),
                ("Kawhi Leonard", "4th 06:12")]
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        setupUI()
        messageTableView.dataSource = self
        messageTableView.delegate = self
        messageTableView.rowHeight = 40
    }
    
    private func setupUI() {
        progressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
    }
    
    private func registerTableViewCells() {
        let tableViewCell = UINib(nibName: "MessageTableViewCell", bundle: nil)
        messageTableView.register(tableViewCell, forCellReuseIdentifier: "MessageTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.playerNameLabel.text = data[indexPath.row].0
        cell.timerLabel.text = data[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

}
