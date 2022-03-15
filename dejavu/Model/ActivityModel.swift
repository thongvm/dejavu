//
//  ActivityModel.swift
//  dejavu
//
//  Created by thongvm on 15/03/2022.
//

import Foundation
class ActivityModel: Codable {
    let activity: String
    let type: String
    let participants: Int
    let price: Int
    let link: String
    let key: String
    let accessibility: Float
    
    
    enum CodingKeys: String, CodingKey {
        case activity
        case type
        case participants
        case price
        case link
        case key
        case accessibility
    }
}
