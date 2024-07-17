//
//  AnimeFetchData.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/16.
//

import Foundation

//{
//  "data": {
//    "Page": {
//      "media": [
//        {
//          "title": {
//            "romaji": "Mahoutsukai ni Narenakatta Onnanoko no Hanashi.",
//            "english": null,
//            "native": "魔法使いになれなかった女の子の話。"
//          },
//          "coverImage": {
//            "extraLarge": "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx107372-4N3N0xVgI8go.jpg"
//          }
//        }
//      ],
//      "pageInfo": {
//        "hasNextPage": true
//      }
//    }
//  }
//}

struct AnimeTrend: Codable {
    let data: Page
}

struct PageInfoAndMedia: Codable {
    let media: [Anime]
    let pageInfo: PageInfo
}
struct Page: Codable {
    let Page: PageInfoAndMedia
}
struct Anime: Codable {
    let title: Title
    let coverImage: CoverImage
}

struct Title: Codable {
    let romaji: String?
    let english: String?
    let native: String
}

struct CoverImage: Codable {
    let extraLarge: String
}

struct PageInfo: Codable {
    let hasNextPage: Bool
}

class AnimeFetchData {
    // trending
    // anime image, anime title
    let queryURL = URL(string: "https://graphql.anilist.co")!
    var animeDataDelegateManager: AnimeDataDelegate?
    
    func fetchData(year: String, season: String) {
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
            query {
              Page(page: 1, perPage: 50) {
                media(type: ANIME, seasonYear: \(year), season: \(season)) {
                  # id
                  title {
                    romaji
                    english
                    native
                  }
                  # episodes
                  coverImage {
                    extraLarge
                  }
                  # season
                }
                pageInfo {
                  hasNextPage
                }
              }
            }
            """
        print(query)
        // Set GraphQL query data
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
//            print(String(data: data, encoding: .utf8))
            do {
                let media = try JSONDecoder().decode(AnimeTrend.self, from: data)
                self.animeDataDelegateManager?.passAnimeData(animeData: media)
//                print(media.data.Page.first?.media.coverImage)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
        
    }
}
