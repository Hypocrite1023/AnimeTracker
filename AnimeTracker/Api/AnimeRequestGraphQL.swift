//
//  AnimeRequestGraphQL.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation

enum AnimeRequestGraphQL {
    case fetchAnimeDetail(id: Int)
    case fetchRanking(mediaId: Int)
    case fetchAnimeSimpleData(id: Int)
    case fetchAnimeEpisodeData(id: Int)
    case fetchAnimeSimpleDataByIDs(ids: [Int])
    case fetchAnimeEpisodeDataByIDs(ids: [Int])
    case fetchAnimeTimeLineInfoByID(id: Int)
    case loadAnimeSearchingEssentialData
    case searchAnime(title: String, genres: [String], format: [String], sort: String, airingStatus: [String], streamingOn: [String], country: String, sourceMaterial: [String], doujin: Bool, year: Int?, season: String, page: Int)
    case fetchCharacterPreview(mediaId: Int, page: Int)
    case fetchCharacterDetail(characterId: Int, page: Int)
    case fetchVoiceActorData(staffId: Int, page: Int)
    case fetchMoreVoiceActorData(staffId: Int, page: Int)
    case fetchStaffPreview(mediaId: Int, page: Int)
    case fetchStaffDetail(staffId: Int)
    case fetchTrendingAnime(page: Int)
    case fetchAnimeByCategory(genres: [String], sortBy: String, page: Int)
    case fetchThreadDataByMediaId(id: Int, page: Int)
    case fetchAnimeListBySeason(year: Int, season: String, page: Int)
    
    var query: String {
        switch self {
        case .fetchAnimeDetail(let id):
            return """
            query {
                Media(id: \(id)) {
                    id
                    title {
                        romaji
                        english
                        native
                    }
                    coverImage {
                        extraLarge
                    }
                    seasonYear
                    season
                    description
                    streamingEpisodes {
                        site
                        title
                        thumbnail
                        url
                    }
                    bannerImage
                    nextAiringEpisode {
                        airingAt
                        timeUntilAiring
                        episode
                    }
                    format
                    episodes
                    duration
                    status
                    startDate {
                        year
                        month
                        day
                    }
                    averageScore
                    meanScore
                    popularity
                    favourites
                    studios {
                        edges {
                            isMain
                            node {
                                name
                            }
                        }
                    }
                    source
                    hashtag
                    genres
                    synonyms
                    relations {
                        edges {
                            id
                            relationType(version: 2)
                            node {
                                id
                                title {
                                    userPreferred
                                }
                                format
                                type
                                status(version: 2)
                                bannerImage
                                coverImage {
                                    large
                                }
                            }
                        }
                    }
                    characterPreview:characters(perPage: 6,sort: [ROLE,RELEVANCE,ID]) {
                        pageInfo {
                            currentPage
                            hasNextPage
                        }
                        edges {
                            id
                            role
                            name
                            voiceActors(language: JAPANESE,sort: [RELEVANCE,ID]) {
                                id
                                name {
                                    userPreferred
                                }
                                language: languageV2
                                image {
                                    large
                                }
                            }
                            node {
                                id
                                name {
                                    userPreferred
                                }
                                image {
                                    large
                                }
                            }
                        }
                    }
                    staffPreview: staff(perPage: 6, page: 1,sort: [RELEVANCE,ID]) {
                        pageInfo {
                            hasNextPage
                            currentPage
                        }
                        edges {
                            id
                            role
                            node {
                                id
                                name {
                                    userPreferred
                                }
                                language: languageV2
                                image {
                                    large
                                }
                            }
                        }
                    }
                    stats {
                        statusDistribution {
                            status
                            amount
                        }
                        scoreDistribution {
                            score
                            amount
                        }
                    }
                    recommendations(perPage: 7,sort: [RATING_DESC,ID]) {
                        pageInfo {
                            total
                        }
                        nodes {
                            id
                            rating
                            userRating
                            mediaRecommendation {
                                id
                                title {
                                    userPreferred
                                }
                                format
                                type
                                status(version:2)
                                bannerImage
                                coverImage {
                                    large
                                }
                            }
                            user {
                                id
                                name
                                avatar {
                                    large
                                }
                            }
                        }
                    }
                    reviewPreview: reviews(perPage: 2,sort: [RATING_DESC,ID]) {
                        pageInfo {
                            total
                        }
                        nodes {
                            id
                            summary
                            rating
                            ratingAmount
                            user {
                                id
                                name
                                avatar{
                                    large
                                }
                            }
                        }
                    }
                    externalLinks {
                        id
                        site
                        url
                        type
                        language
                        color
                        icon
                        notes
                        isDisabled
                    }
                    tags {
                        id
                        name
                        description
                        rank
                        isMediaSpoiler
                        isGeneralSpoiler
                        userId
                    }
                }
            }
            """
        case .fetchRanking(let mediaId):
            return """
            query {
                Media(id: \(mediaId)) {
                    rankings {
                        rank
                        type
                        format
                        year
                        season
                        allTime
                        context
                    }
                }
            }
            """
        case .fetchAnimeSimpleData(let id):
            return """
            query {
              Media(id: \(id)) {
                id
                title {
                  native
                  romaji
                  english
                }
                coverImage {
                  large
                }
                status
              }
            }
            """
        case .fetchAnimeEpisodeData(let id):
            return """
            query {
              Media(id: \(id)) {
                id
                title {
                  native
                  romaji
                  english
                }
                nextAiringEpisode {
                  episode
                  timeUntilAiring
                }
                episodes
                coverImage {
                  large
                }
                status
              }
            }
            """
        case .fetchAnimeSimpleDataByIDs(let ids):
            var query = ""
            for (index, animeID) in ids.enumerated() {
                query += """
              anime\(index): Media(id: \(animeID)) {
                id
                title {
                  native
                  romaji
                  english
                }
                coverImage {
                  large
                }
                status
              }
            """
            }
            return "{ \(query) }"
            
        case .loadAnimeSearchingEssentialData:
            return """
            query {
              genreCollection: GenreCollection
              externalLinkSourceCollection: ExternalLinkSourceCollection(type: STREAMING, mediaType: ANIME) {
                site
              }
            }
            """
            
        case .searchAnime(let title, let genres, let format, let sort, let airingStatus, let streamingOn, let country, let sourceMaterial, let doujin, let year, let season, let page):
            return """
            query {
                Page(page: \(page), perPage: 50) {
                    pageInfo {
                        hasNextPage
                        currentPage
                    }
                    media(isAdult: false, type: ANIME\(title == "" ? "": ", search: \"\(title)\"")\(genres.isEmpty ? "" : ", genre_in: \(genres)")\(format.isEmpty ? "" : ", format_in: [\(format.joined(separator: ", "))]"), sort: \(sort == "" ? "POPULARITY_DESC" : sort)\(airingStatus.isEmpty ? "" : ", status_in: [\(airingStatus.joined(separator: ", "))]")\(streamingOn.isEmpty ? "" : ", licensedBy_in: \(streamingOn)")\(country == "" ? "" : ", countryOfOrigin: \(country)")\(sourceMaterial.isEmpty ? "" : ", source_in: [\(sourceMaterial.joined(separator: ", "))]"), isLicensed: \(!doujin)\(year == nil ? "" : ", seasonYear: \(year!)")\(season == "" ? "" : ", season: \(season.uppercased())")) {
                        id
                        title {
                            romaji
                            english
                            native
                        }
                        coverImage {
                            extraLarge
                        }
                    }
                }
            }
            """
            
        case .fetchCharacterPreview(let mediaId, let page):
            return """
            query {
                Media(id: \(mediaId)) {
                    characterPreview:characters(perPage: 6, page: \(page), sort: [ROLE, RELEVANCE, ID]) {
                        pageInfo {
                            currentPage
                            hasNextPage
                        }
                        edges {
                            id
                            role
                            voiceActors(language: JAPANESE, sort: [RELEVANCE, ID]) {
                                id
                                name {
                                    userPreferred
                                }
                                language: languageV2
                                image {
                                    large
                                }
                            }
                            node {
                                id
                                name {
                                    userPreferred
                                }
                                image {
                                    large
                                }
                            }
                        }
                    }
                }
            }
            """
            
        case .fetchCharacterDetail(let characterId, let page):
            return """
            query{
              Character(id: \(characterId)) {
                id
                name {
                  first
                  middle
                  last
                  full
                  native
                  userPreferred
                  alternative
                  alternativeSpoiler
                }
                image{
                  large
                }
                favourites
                isFavourite
                isFavouriteBlocked
                description(asHtml: true)
                age
                gender
                bloodType
                dateOfBirth {
                  year
                  month
                  day
                }
                media(page: \(page), sort: POPULARITY_DESC, onList: true)@include(if: true) {
                  pageInfo {
                    total
                    perPage
                    currentPage
                    lastPage
                    hasNextPage
                  }
                  edges {
                    id
                    characterRole
                    voiceActorRoles(sort:[RELEVANCE,ID]) {
                      roleNotes
                      voiceActor {
                        id
                        name {
                          userPreferred
                        }
                        image {
                          large
                        }
                        language:languageV2
                      }
                    }
                    node {
                      id
                      type
                      isAdult
                      bannerImage
                      title {
                        userPreferred
                      }
                      coverImage {
                        extraLarge
                      }
                      startDate {
                        year
                      }
                      mediaListEntry {
                        id
                        status
                      }
                    }
                  }
                }
              }
            }
            """
            
        case .fetchVoiceActorData(let staffId, let page):
            return """
            query {
              Staff(id: \(staffId)) {
                id
                name {
                  first
                  middle
                  last
                  full
                  native
                  userPreferred
                  alternative
                }
                image {
                  large
                }
                description(asHtml:true)
                favourites
                isFavourite
                isFavouriteBlocked
                age
                gender
                yearsActive
                homeTown
                bloodType
                primaryOccupations
                dateOfBirth {
                  year
                  month
                  day
                }
                dateOfDeath {
                  year
                  month
                  day
                }
                language: languageV2
                characterMedia(page: \(page), perPage: 50, sort: START_DATE_DESC, onList: false) @include (if: true) {
                  pageInfo {
                    total
                    perPage
                    currentPage
                    lastPage
                    hasNextPage
                  }
                  edges {
                    characterRole
                    characterName
                    node {
                      id
                      type
                      bannerImage
                      isAdult
                      title {
                        userPreferred
                      }
                      coverImage {
                        large
                      }
                      startDate {
                        year
                      }
                      mediaListEntry {
                        id
                        status
                      }
                    }
                    characters {
                      id
                      name {
                        userPreferred
                      }
                      image {
                        large
                      }
                    }
                  }
                }
                staffMedia(page: \(page), perPage: 10, sort: ID_DESC, onList: false) @include (if: true) {
                  pageInfo {
                    total
                    perPage
                    currentPage
                    lastPage
                    hasNextPage
                  }
                  edges {
                    staffRole
                    node {
                      id
                      type
                      isAdult
                      title {
                        userPreferred
                      }
                      coverImage {
                        large
                      }
                      mediaListEntry {
                        id
                        status
                      }
                    }
                  }
                }
              }
            }
            """
            
        case .fetchMoreVoiceActorData(let staffId, let page):
            return """
            query {
              Staff(id: \(staffId)) {
                characterMedia(page: \(page), perPage: 50, sort: START_DATE_DESC, onList: false) @include (if: true) {
                  pageInfo {
                    total
                    perPage
                    currentPage
                    lastPage
                    hasNextPage
                  }
                  edges {
                    characterRole
                    characterName
                    node {
                      id
                      type
                      bannerImage
                      isAdult
                      title {
                        userPreferred
                      }
                      coverImage {
                        large
                      }
                      startDate {
                        year
                      }
                      mediaListEntry {
                        id
                        status
                      }
                    }
                    characters {
                      id
                      name {
                        userPreferred
                      }
                      image {
                        large
                      }
                    }
                  }
                }
              }
            }
            """
            
        case .fetchStaffPreview(let mediaId, let page):
            return """
            query {
                Media(id: \(mediaId)) {
                    staffPreview: staff(perPage: 6, page: \(page), sort: [RELEVANCE, ID]) {
                        pageInfo {
                            hasNextPage
                            currentPage
                        }
                        edges {
                            id
                            role
                            node {
                                id
                                name {
                                    userPreferred
                                }
                                language: languageV2
                                image {
                                    large
                                }
                            }
                        }
                    }
                }
            }
            """
            
        case .fetchStaffDetail(let staffId):
            return """
            query {
                staff: Staff(id: \(staffId)) {
                id
                name {
                  native
                  userPreferred
                }
                primaryOccupations
                image {
                  large
                }
                description(asHtml: false)
                staffMedia {
                  edges {
                    staffRole
                    node {
                      id
                      coverImage {
                        large
                      }
                      title {
                        native
                      }
                      type
                    }
                  }
                }
                
              }
            }
            """
            
        case .fetchTrendingAnime(let page):
            return """
            query {
              Page(page: \(page), perPage: 50) {
                media(sort: TRENDING_DESC, type: ANIME) {
                  id
                  title {
                    native
                  }
                  coverImage {
                    extraLarge
                  }
                }
                pageInfo {
                  currentPage
                  hasNextPage
                }
              }
            }
            """
            
        case .fetchAnimeByCategory(let genres, let sortBy, let page):
            var queryString = ""
            for (_, value) in genres.enumerated() {
                let genreKey = value
                    .lowercased()
                    .replacingOccurrences(of: " ", with: "_")
                    .replacingOccurrences(of: "-", with: "_")
                let genreTemplate = """
                              \(genreKey): Page(perPage: 20, page: \(page)) {
                                    media(genre: "\(value.lowercased())", type: ANIME, sort: \(sortBy)) {
                                        id
                                        title {
                                          native
                                        }
                                        coverImage {
                                          large
                                        }
                                    }
                                }
                """
                queryString += "\(genreTemplate)\n"
            }
            return """
                query {
                  \(queryString)
                }
                """
        case .fetchAnimeEpisodeDataByIDs(let ids):
            var query = ""
            for (index, animeID) in ids.enumerated() {
                query += """
              anime\(index): Media(id: \(animeID)) {
                id
                title {
                  native
                  romaji
                  english
                }
                nextAiringEpisode {
                  episode
                  timeUntilAiring
                }
                episodes
                coverImage {
                  large
                }
              }
            """
            }
            query = "{ \(query) }"
            return query
        case .fetchAnimeTimeLineInfoByID(let id):
            return """
            query {
              Media(id: \(id)) {
                id
                title {
                  native
                  romaji
                  english
                }
                nextAiringEpisode {
                  episode
                  timeUntilAiring
                }
                episodes
              }
            }
            """
        case .fetchThreadDataByMediaId(id: let id, page: let page):
            return """
            query {
              Page(page: \(page), perPage: 10) {
                pageInfo {
                  total
                  perPage
                  currentPage
                  lastPage
                  hasNextPage
                }
                threads(mediaCategoryId: \(id), sort: ID_DESC) {
                  id
                  title
                  replyCount
                  viewCount
                  replyCommentId
                  repliedAt
                  createdAt
                  categories {
                    id
                    name
                  }
                  user {
                    id
                    name
                    avatar {
                      large
                    }
                  }
                  replyUser {
                    id
                    name
                    avatar {
                      large
                    }
                  }
                }
              }
            }
            """
        case .fetchAnimeListBySeason(let year, let season, let page):
            return """
                query {
                Page(page: \(page), perPage: 50) {
                    media(type: ANIME, season: \(season), seasonYear: \(year), sort: POPULARITY_DESC) {
                      id
                      title {
                        romaji
                        native
                        english
                      }
                      coverImage {
                        extraLarge
                      }
                      status
                      nextAiringEpisode {
                        episode
                        timeUntilAiring
                        airingAt
                      }
                    }
                    pageInfo {
                      currentPage
                      hasNextPage
                    }
                  }
                }
                """
        }
    }
}
