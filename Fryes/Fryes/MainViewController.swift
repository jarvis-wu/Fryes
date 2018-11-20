//
//  MainViewController.swift
//  Fryes
//
//  Created by Jarvis Wu on 2018-11-15.
//  Copyright © 2018 Jarvis Wu. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var torontoTeamLabel: UILabel!
    @IBOutlet weak var opponentTeamLabel: UILabel!
    @IBOutlet weak var versusLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var viewStatisticsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationButton.layer.cornerRadius = 10
        viewStatisticsButton.layer.cornerRadius = 10
        GameManager.shared.getCurrentGame { (completed) in
            if completed { self.updateUI() }
        }
    }
    
    @IBAction func didPressNotificationButton(_ sender: Any) {
        let conciseNotification = UIAlertAction(title: "When game ends (🍟?)", style: .default) { (action) in
            print("concise selected")
        }
        let verboseNotification = UIAlertAction(title: "When Raptors scores a 3PT", style: .default) { (action) in
            print("verbose selected")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alert = UIAlertController(title: "How often do you want to be notified?", message: nil, preferredStyle: .alert)
        alert.addAction(conciseNotification)
        alert.addAction(verboseNotification)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didPressViewStatisticsButton(_ sender: Any) {
        // for now using this to test GameVC
        // Use the following api to load team avg stats
        // http://data.nba.net/json/cms/{year}/statistics/{teamSlug}/regseason_stats_and_rankings.json
        guard let gameDateTime = GameManager.shared.currentGame?.dateTime else { return }
        let gameIsOn = (Date().timeIntervalSince(gameDateTime) > 0 && Date().timeIntervalSince(gameDateTime) < 2 * 60 * 60) // TODO
        if gameIsOn {
            present(GameViewController(), animated: true, completion: nil)
        } else {
            let goToStatistics = UIAlertAction(title: "View stats", style: .default) { (action) in
                print("show statistics")
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let alert = UIAlertController(title: "Stay tuned", message: "The game has not started yet. Do you want to check out relevant statistics?", preferredStyle: .alert)
            alert.addAction(goToStatistics)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func updateUI() {
        guard let nextGame = GameManager.shared.currentGame else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd @ HH:mm"
        print("Next Game: \(nextGame.homeAbbr) vs \(nextGame.visitorAbbr): \(dateFormatter.string(from: nextGame.dateTime))")
        DispatchQueue.main.async {
            let isAtHome = (nextGame.homeAbbr == "TOR")
            self.versusLabel.text = isAtHome ? "VS" : "@"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 0.65
            paragraphStyle.alignment = .center
            let opponentColor = nextGame.opponentBrandColor
            let opponentString = NSAttributedString(string: isAtHome ? "\(nextGame.visitorCity)\n\(nextGame.visitorNickname)" : "\(nextGame.homeCity)\n\(nextGame.homeNickname)", attributes: [.paragraphStyle: paragraphStyle, .foregroundColor: opponentColor])
            self.opponentTeamLabel.attributedText = opponentString
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E MM/dd HH:mm"
            self.dateTimeLabel.text = dateFormatter.string(from: nextGame.dateTime)
            let days = nextGame.dateTime.daysFromToday()
            switch days {
            case 0:
                self.countdownLabel.text = "TODAY"
            case 1:
                self.countdownLabel.text = "Tomorrow"
            default:
                self.countdownLabel.text = "In \(days) Days"
            }
        }
    }

}
