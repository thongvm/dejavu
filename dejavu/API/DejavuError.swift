//
//  DejavuError.swift
//  dejavu
//
//  Created by thongvm on 15/03/2022.
//

import Foundation

enum DejavuError: Error {
    case parsing(desc: String)
    case network(desc: String)
}
