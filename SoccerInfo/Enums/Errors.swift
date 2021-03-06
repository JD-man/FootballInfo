//
//  Errors.swift
//  SoccerInfo
//
//  Created by JD_MacMini on 2021/11/22.
//

import Foundation

enum RealmErrorType: Error {
    case emptyData    
    case asyncOpenFail // Error 1
    case realmFail // Error 2
}

enum APIErrorType: Int, Error {
    case footballServerBug = 204
    case requestLimit = 429
    case timeout = 499
    case serverError = 500
    
    var description: String {
        switch self {
        case .requestLimit:
            return "더 이상 데이터를 받을 수 없습니다."
        case .timeout:
            return "데이터를 받는 시간이 초과 됐습니다."
        case .serverError, .footballServerBug:
            return "서버에 오류가 생겼습니다."
        @unknown default:
            print("APIError Unknown default")
        }
    }
}

/* Football API Error
 200 : OK, Request Limit(??)
 204 : Server Bug
 499 : Time Out
 500 : Server Error
*/


/* Naver Search API
 429 : Request Limit
 500 : Server Error
 */
