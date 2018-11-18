//
//  MainViewController.swift
//  Fryes
//
//  Created by Jarvis Wu on 2018-11-15.
//  Copyright © 2018 Jarvis Wu. All rights reserved.
//

import UIKit

class Game {
    var homeId: String
    var homeAbbr: String
    var homeCity: String
    var homeNickname: String
    var visitorId: String
    var visitorAbbr: String
    var visitorCity: String
    var visitorNickname: String
    var dateTime: Date
    var opponentBrandColor: UIColor
    
    init(homeId:String, homeAbbr: String, homeCity: String, homeNickname: String, visitorId: String, visitorAbbr: String, visitorCity: String, visitorNickname: String, dateTime: Date, opponentBrandColor: UIColor) {
        self.homeId = homeId
        self.homeAbbr = homeAbbr
        self.homeCity = homeCity
        self.homeNickname = homeNickname
        self.visitorId = visitorId
        self.visitorAbbr = visitorAbbr
        self.visitorCity = visitorCity
        self.visitorNickname = visitorNickname
        self.dateTime = dateTime
        self.opponentBrandColor = opponentBrandColor
    }
}

class MainViewController: UIViewController {

    var nextGame: Game!
    
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
        getNextGameInfo { (completed) in
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
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let alert = UIAlertController(title: "Concise or Verbose", message: "How often do you want to be notified?", preferredStyle: .actionSheet)
        alert.addAction(conciseNotification)
        alert.addAction(verboseNotification)
        alert.addAction(cancel)
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didPressViewStatisticsButton(_ sender: Any) {
        // for now using this to test GameVC
        // Use the following api to load team avg stats
        // http://data.nba.net/json/cms/{year}/statistics/{teamSlug}/regseason_stats_and_rankings.json
        present(GameViewController(), animated: true, completion: nil)
    }
    
    private func getNextGameInfo(completion: @escaping (Bool) -> ()) {
        let teamName = "raptors"
        let year = Calendar.current.component(.year, from: Date())
        let url = URL(string: "https://data.nba.net/json/cms/\(year)/team/\(teamName)/schedule.json")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                print(error!.localizedDescription); return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            //print(json!)
            if let jsonRoot = json as? [String: Any] {
                let sports_content = jsonRoot["sports_content"] as! [String: Any]
                let games = sports_content["game"] as! [[String : Any]]
                for game in games {
                    let home = game["home"] as! [String : Any]
                    let homeId = home["id"] as! String
                    let homeAbbr = home["abbreviation"] as! String
                    let homeCity = home["city"] as! String
                    let homeNickname = home["nickname"] as! String
                    let isAtHome = (homeAbbr == "TOR")
                    let dateString = (isAtHome ? game["home_start_date"] : game["visitor_start_date"]) as! String
                    let timeString = (isAtHome ? game["home_start_time"] : game["visitor_start_time"]) as! String
                    let dateTimeString = dateString + timeString
                    let dateTime = dateTimeString.toDate()!
                    if dateTime < Date() {
                        continue
                    } else {
                        let visitor = game["visitor"] as! [String : Any]
                        let visitorId = visitor["id"] as! String
                        let visitorAbbr = visitor["abbreviation"] as! String
                        let visitorCity = visitor["city"] as! String
                        let visitorNickname = visitor["nickname"] as! String
                        var opponentBrandColor = UIColor.white
                        self.getBrandColor(teamTricode: isAtHome ? visitorAbbr : homeAbbr, completion: { (color) in
                            opponentBrandColor = color ?? UIColor.white
                            self.nextGame = Game(homeId: homeId, homeAbbr: homeAbbr, homeCity: homeCity, homeNickname: homeNickname, visitorId: visitorId, visitorAbbr: visitorAbbr, visitorCity: visitorCity, visitorNickname: visitorNickname, dateTime: dateTime, opponentBrandColor: opponentBrandColor)
                            completion(true)
                        })
                        break
                    }
                }
            }
        }.resume()
    }
    
    private func getBrandColor(teamTricode: String, completion: @escaping (UIColor?) -> ()) {
        let url = URL(string: "https://data.nba.net/json/ge/brands.json")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                print(error!.localizedDescription); return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let jsonRoot = json as? [[String : Any]] {
                guard let teamDict = jsonRoot.first(where: { ($0["tricode"] as! String) == teamTricode}) else { return }
                let teamColorString = teamDict["primary"] as! String
                let teamColorHexValue = UIColor.intFromHexString(hexStr: teamColorString)
                completion(UIColor(rgb: Int(teamColorHexValue)))
            }
        }.resume()
    }
    
    private func updateUI() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd @ HH:mm"
        print("Next Game: \(nextGame.homeAbbr) vs \(nextGame.visitorAbbr): \(dateFormatter.string(from: nextGame.dateTime))")
        DispatchQueue.main.async {
            let isAtHome = (self.nextGame.homeAbbr == "TOR")
            self.versusLabel.text = isAtHome ? "VS" : "@"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 0.65
            paragraphStyle.alignment = .center
            let opponentColor = self.nextGame.opponentBrandColor
            let opponentString = NSAttributedString(string: isAtHome ? "\(self.nextGame.visitorCity)\n\(self.nextGame.visitorNickname)" : "\(self.nextGame.homeCity)\n\(self.nextGame.homeNickname)", attributes: [.paragraphStyle: paragraphStyle, .foregroundColor: opponentColor])
            self.opponentTeamLabel.attributedText = opponentString
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E MM/dd HH:mm"
            self.dateTimeLabel.text = dateFormatter.string(from: self.nextGame.dateTime)
            let days = self.nextGame.dateTime.daysFromToday()
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
