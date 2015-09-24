//
//  Serializable.swift
//  Skunk
//
//  Created by Josh on 9/22/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation

protocol Serializable {
    func serialize() -> AnyObject
}
