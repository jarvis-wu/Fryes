//
//  GameManager.swift
//  Fryes
//
//  Created by Jarvis Wu on 2018-11-19.
//  Copyright © 2018 Jarvis Wu. All rights reserved.
//

import Foundation
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

class GameManager {
    static let shared = GameManager()
    var currentGame: Game?
    
    func getCurrentGame(completion: @escaping (Bool) -> ()) {
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
                            self.currentGame = Game(homeId: homeId, homeAbbr: homeAbbr, homeCity: homeCity, homeNickname: homeNickname, visitorId: visitorId, visitorAbbr: visitorAbbr, visitorCity: visitorCity, visitorNickname: visitorNickname, dateTime: dateTime, opponentBrandColor: opponentBrandColor)
                            completion(true)
                        })
                        break
                    }
                }
            }
        }.resume()
    }
    
    func getBrandColor(teamTricode: String, completion: @escaping (UIColor?) -> ()) {
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
    
}
