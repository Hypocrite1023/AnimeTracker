# AnimeDetail Data Model Documentation

This document describes the `AnimeDetail` data model used in `AnimeTracker`. This model is used to parse the detailed information of an anime (or manga/novel) from the AniList GraphQL API.

## Structure

The `AnimeDetail` struct is a wrapper around `MediaData`, which contains the `Media` object.

```swift
struct AnimeDetail: Decodable {
    let data: MediaData
}

struct MediaData: Decodable {
    let media: Media
}
```

## Media Properties

The `Media` struct contains the actual data fields. Below is a detailed description of each property.

| Property | Type | Description |
| :--- | :--- | :--- |
| `id` | `Int` | The unique identifier of the media. (e.g., `88369`) |
| `title` | `MediaTitle` | The official titles of the media in various languages. |
| `coverImage` | `MediaCoverImage?` | The cover image of the media. |
| `seasonYear` | `Int?` | The season year the media was released. |
| `season` | `String?` | The season the media was released (e.g., `SPRING`, `SUMMER`, `FALL`, `WINTER`). |
| `description` | `String?` | Short description of the media's story and characters. |
| `streamingEpisodes` | `[StreamingEpisodes]` | List of streaming episodes available. |
| `bannerImage` | `String?` | The banner image of the media. |
| `nextAiringEpisode` | `NextAiringEpisode?` | The next episode to air. |
| `format` | `String?` | The format of the media (e.g., `TV`, `MOVIE`, `OVA`, `NOVEL`). |
| `episodes` | `Int?` | The amount of episodes the anime has when complete. |
| `duration` | `Int?` | The general length of each episode in minutes. |
| `status` | `String?` | The current releasing status of the media. (e.g., `FINISHED`, `RELEASING`, `NOT_YET_RELEASED`, `CANCELLED`). |
| `startDate` | `StartDate?` | The first official release date of the media. |
| `averageScore` | `Int?` | A weighted average score of all the user's scores of the media. |
| `meanScore` | `Int?` | Mean score of all the user's scores of the media. |
| `popularity` | `Int?` | The number of users with the media on their list. |
| `favourites` | `Int?` | The number of users that have favourited the media. |
| `studios` | `Studios?` | The companies that produced the anime. |
| `source` | `String?` | Source type the media was adapted from (e.g., `ORIGINAL`, `MANGA`, `LIGHT_NOVEL`). |
| `hashtag` | `String?` | Official Twitter hashtags for the media. |
| `genres` | `[String]?` | List of genres of the media. |
| `synonyms` | `[String]?` | Alternative titles of the media. |
| `relations` | `Relations?` | Other media in the same franchise. |
| `characterPreview` | `CharacterPreview?` | Preview of characters in the media. |
| `staffPreview` | `StaffPreview?` | Preview of staff that worked on the media. |
| `stats` | `Stats?` | Status and score distribution statistics. |
| `recommendations` | `Recommendations?` | User recommendations for similar media. |
| `reviewPreview` | `ReviewPreview?` | Preview of reviews for the media. |
| `externalLinks` | `[ExternalLinks]?` | External links to another site related to the media. |
| `tags` | `[Tag]?` | List of tags that describes elements and themes of the media. |

## Nested Structures

### MediaTitle
Contains title variations.
- `romaji`: The romanized Japanese title.
- `english`: The official English title.
- `native`: The official native title.

### MediaCoverImage
Contains cover image URLs.
- `extraLarge`: The URL for the extra large cover image.

### StreamingEpisodes
Details about available streams.
- `site`: The site where the stream is hosted.
- `title`: The title of the episode.
- `thumbnail`: The URL for the thumbnail image.
- `url`: The URL to watch the episode.

### NextAiringEpisode
Information about the next episode.
- `airingAt`: The timestamp when the episode will air.
- `timeUntilAiring`: Seconds until the episode airs.
- `episode`: The episode number.

### StartDate
Date components.
- `year`: Year of release.
- `month`: Month of release.
- `day`: Day of release.

### Studios
List of studios involved.
- `edges`: List of studio edges containing `node` (Studio name) and `isMain` boolean.

### Relations
Related media.
- `edges`: List of relation edges containing `relationType` and `node` (Basic media info).

### CharacterPreview
List of characters.
- `edges`: List of character edges containing `role`, `name`, `voiceActors`, and `node` (Character details).

### StaffPreview
List of staff members.
- `edges`: List of staff edges containing `role` and `node` (Staff details).

### Stats
Statistics about the media.
- `statusDistribution`: List of `StatusDistribution` (status and amount).
- `scoreDistribution`: List of `ScoreDistribution` (score and amount).

### Recommendations
User recommendations.
- `nodes`: List of recommendation nodes containing `rating`, `userRating`, `mediaRecommendation` (Recommended media), and `user`.

### ReviewPreview
User reviews.
- `nodes`: List of review nodes containing `summary`, `rating`, `ratingAmount`, and `user`.

### ExternalLinks
External links.
- `id`: The id of the link.
- `site`: The site name.
- `url`: The URL.
- `type`: The type of link.
- `language`: The language of the site.
- `color`: The color associated with the site.
- `icon`: The icon URL.
- `notes`: Any notes.
- `isDisabled`: Whether the link is disabled.

### Tag
Media tags.
- `id`: The id of the tag.
- `name`: The name of the tag.
- `description`: A description of the tag.
- `rank`: The relevance rank of the tag.
- `isMediaSpoiler`: If the tag spoils the media.
- `isGeneralSpoiler`: If the tag is a general spoiler.
- `userId`: The user who added the tag.
