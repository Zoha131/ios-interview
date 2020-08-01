//
//  Attributes.swift
//  RW Take Home
//
//  Created by Zoha on 8/1/20.
//  Copyright © 2020 Zoha. All rights reserved.
//

import Foundation

struct Attributes: Codable, Hashable {
  let uri, name, attributesDescription: String
  let releasedAt: Date
  let contentType: String
  let descriptionPlainText: String
  let cardArtworkURL: String
  let duration: Int
  
  enum CodingKeys: String, CodingKey {
    case uri, name,duration
    case attributesDescription = "description"
    case releasedAt = "released_at"
    case contentType = "content_type"
    case descriptionPlainText = "description_plain_text"
    case cardArtworkURL = "card_artwork_url"
  }
}

extension Attributes {
  var releaseTxt: String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.setLocalizedDateFormatFromTemplate("MMMdyyyy")
    
    return dateFormatter.string(from: releasedAt)
  }
  
  var durationTxt: String {
    var minutes = duration / 60
    
    let hours = minutes / 60
    minutes = minutes % 60
    
    if hours > 0 {
      return "\(hours) hrs, \(minutes) mins"
    } else{
      return "\(minutes) mins"
    }
  }
}
