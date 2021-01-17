//
//  data.swift
//  ios-test
//
//  Created by Lucas Nahuel Giacche on 15/01/2021.
//

import Foundation

struct ServiceResponse: Decodable {
    let kind: String
    let data: ServiceResponseData
}

struct ServiceResponseData: Decodable {
    let children: [Entry]
}

struct Entry: Decodable {
    let kind: String
    let data: EntryData
}

struct EntryData: Decodable {
    let title: String
    let authorName: String
    let commentsAmount: Int
    let timeCreated: TimeInterval
    let thumbnailURL: String?
    let urlBigImage: String
    var seenDot : Bool
    
    enum CodingKeys: String, CodingKey {
        case title
        case authorName = "author"
        case commentsAmount = "num_comments"
        case timeCreated = "created_utc"
        case thumbnailURL = "thumbnail"
        case urlBigImage = "url"
        case seenDot = "visited"
    }
}

class RedditService {
    static func requestData(success: @escaping (([EntryData]) -> Void), failure: @escaping ((Error) -> Void)) {
        let session = URLSession.shared
        let entriesAmount = 50
        
        guard let url = URL(string: "http://reddit.com/top.json?limit=\(entriesAmount)") else {
            return
        }
        
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                failure(error)
            } else {
                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    let entries = try decoder.decode(ServiceResponse.self, from: data)
                    var entriesData: [EntryData] = []
                    for child in entries.data.children {
                        entriesData.append(child.data)
                    }
                    entriesData = entriesData.sorted(by: {$0.timeCreated > $1.timeCreated})
                    DispatchQueue.main.async {
                        success(entriesData)
                        print(entriesData)
                    }
                } catch let err {
                    DispatchQueue.main.async {
                        failure(err)
                    }
                }
            }
        })
        
        task.resume()
    }
    
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

