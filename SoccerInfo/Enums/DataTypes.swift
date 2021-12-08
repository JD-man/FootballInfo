//
//  DataTypes.swift
//  SoccerInfo
//
//  Created by JD_MacMini on 2021/11/22.
//

import Foundation
import RealmSwift
import Alamofire

enum FootballData {
    case standings
    case fixtures
    case events
    case lineups
    case newsSearch
    case newsImage
    
    var realmTable: Any.Type {
        switch self {
        case .standings:
            return StandingsTable.self
        case .fixtures:
            return FixturesTable.self
        case .events, .lineups:
            return MatchDetailTable.self
        case .newsSearch, .newsImage:
            return NewsResponse.self
        @unknown default:
            print("FootballData realmTable unknown default")
            break
        }
    }
    
    var urlPath: String {
        switch self {
        case .standings:
            return "/standings"
        case .fixtures:
            return "/fixtures"
        case .events:
            return "/fixtures/events"
        case .lineups:
            return "/fixtures/lineups"
        case .newsSearch:
            return "/news.json"
        case .newsImage:
            return "/image"
        @unknown default:
            print ("FootballData urlPath unknown default")
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .standings, .fixtures , .events, .lineups:
            return APIComponents.footBallHeaders
        case .newsImage, .newsSearch:
            return APIComponents.newsHeaders
        @unknown default:
            print("FootballData headers unknown default")
        }
    }
}

enum League: String, CaseIterable {
    case premierLeague = "Premier League"
    case laLiga = "LaLiga"
    case serieA = "Serie A"
    case bundesliga = "Bundesliga"
    case ligue1 = "Ligue 1"
    
    var leagueID: Int {
        switch self {
        case .premierLeague:
            return 39
        case .laLiga:
            return 140
        case .serieA:
            return 135
        case .bundesliga:
            return 78
        case .ligue1:
            return 61
        @unknown default:
            print("league unknown default")
            break
        }
    }
    
    var newsQuery: String {
        switch self {
        case .premierLeague:
            return "프리미어리그 | 첼시 | 맨시티 | 리버풀 | 웨스트햄 | 아스날 | 울버햄튼 | 토트넘 | 맨유"
        case .laLiga:
            return "스페인 라리가 | 라리가 | 프리메라리가"
        case .serieA:
            return "세리에 A"
        case .bundesliga:
            return "분데스리가"
        case .ligue1:
            return "리그앙"
        }
    }
}
