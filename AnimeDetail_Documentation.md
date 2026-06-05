# AnimeDetail 資料模型文件 (AnimeDetail Data Model Documentation)

此文件描述了 `AnimeTracker` 中所使用的 `AnimeDetail` 資料模型。此模型主要用於解析來自 AniList GraphQL API 的動漫（包含漫畫與小說）詳細資訊。

## 結構 (Structure)

`AnimeDetail` 結構是 `MediaData` 的包裝器，其中包含實際的 `Media` 物件。

```swift
struct AnimeDetail: Decodable {
    let data: MediaData
}

struct MediaData: Decodable {
    let media: Media
}
```

## Media 屬性 (Media Properties)

`Media` 結構包含了實際的動漫資料欄位。以下是各屬性的詳細說明：

| 屬性名稱 | 資料型別 | 中文說明與範例 |
| :--- | :--- | :--- |
| `id` | `Int` | 媒體的唯一識別碼。（例如：`88369`） |
| `title` | `MediaTitle` | 各種語言版本的官方標題。 |
| `coverImage` | `MediaCoverImage?` | 媒體的封面圖片資訊。 |
| `seasonYear` | `Int?` | 媒體發行/播出的年份。 |
| `season` | `String?` | 媒體播出的季節（例如：`SPRING` 春, `SUMMER` 夏, `FALL` 秋, `WINTER` 冬）。 |
| `description` | `String?` | 動漫故事大綱與角色的簡短描述。 |
| `streamingEpisodes` | `[StreamingEpisodes]` | 可供線上看（串流）的集數列表。 |
| `bannerImage` | `String?` | 媒體的橫幅背景圖片 URL。 |
| `nextAiringEpisode` | `NextAiringEpisode?` | 下一集即將播出的相關資訊。 |
| `format` | `String?` | 播放媒介格式（例如：`TV` 電視版, `MOVIE` 電影版, `OVA` 原創動畫錄影帶, `NOVEL` 小說）。 |
| `episodes` | `Int?` | 動漫完結時的總集數。 |
| `duration` | `Int?` | 每集的大致時長（以分鐘為單位）。 |
| `status` | `String?` | 當前的發行狀態（例如：`FINISHED` 已完結, `RELEASING` 連載中, `NOT_YET_RELEASED` 尚未發行, `CANCELLED` 已取消）。 |
| `startDate` | `StartDate?` | 媒體的首次官方發行/開播日期。 |
| `averageScore` | `Int?` | 所有使用者評分的加權平均分數（百分制）。 |
| `meanScore` | `Int?` | 所有使用者評分的算術平均分數（百分制）。 |
| `popularity` | `Int?` | 將此媒體加入清單的使用者總數。 |
| `favourites` | `Int?` | 將此媒體加入收藏的使用者總數。 |
| `studios` | `Studios?` | 負責製作此動漫的動畫工作室/公司資訊。 |
| `source` | `String?` | 改編來源類型（例如：`ORIGINAL` 原創, `MANGA` 漫畫, `LIGHT_NOVEL` 輕小說）。 |
| `hashtag` | `String?` | 官方 Twitter (X) 主題標籤。 |
| `genres` | `[String]?` | 媒體的類型/題材列表（例如：冒險、奇幻等）。 |
| `synonyms` | `[String]?` | 媒體的別名/其他常用標題。 |
| `relations` | `Relations?` | 同一 IP 家族下的其他關聯媒體（如前傳、後續作品等）。 |
| `characterPreview` | `CharacterPreview?` | 媒體中的角色資訊預覽。 |
| `staffPreview` | `StaffPreview?` | 參與此媒體製作的工作人員資訊預覽。 |
| `stats` | `Stats?` | 觀看狀態分佈與評分分佈統計。 |
| `recommendations` | `Recommendations?` | 使用者推薦的其他相似媒體。 |
| `reviewPreview` | `ReviewPreview?` | 使用者的評價/評論預覽。 |
| `externalLinks` | `[ExternalLinks]?` | 與此媒體相關的外部官方網站或串流平台連結。 |
| `tags` | `[Tag]?` | 描述此媒體元素、屬性與題材的標籤列表。 |

## 嵌套結構 (Nested Structures)

### MediaTitle
包含不同語言/格式的標題。
- `romaji`: 羅馬拼音標題。
- `english`: 官方英文標題。
- `native`: 官方原始語言標題（例如日文）。

### MediaCoverImage
包含封面圖片的 URL。
- `extraLarge`: 超大尺寸封面圖片的 URL。

### StreamingEpisodes
可線上看集數的詳細資訊。
- `site`: 串流播放平台的名稱。
- `title`: 該集數的標題。
- `thumbnail`: 該集數預覽縮圖的 URL。
- `url`: 線上觀看的連結。

### NextAiringEpisode
即將播出的下一集資訊。
- `airingAt`: 下一集播出的時間戳記（Timestamp）。
- `timeUntilAiring`: 距離下一集播出還剩多少秒。
- `episode`: 下一集的集數。

### StartDate
日期組成元件。
- `year`: 發行年份。
- `month`: 發行月份.
- `day`: 發行日期。

### Studios
參與製作的工作室列表。
- `edges`: 工作室關聯列表，包含 `node`（工作室名稱）以及布林值 `isMain`（是否為主導製作工作室）。

### Relations
關聯媒體作品。
- `edges`: 關聯媒體列表，包含 `relationType`（關聯類型，如續集、前傳等）與 `node`（基本媒體資訊）。

### CharacterPreview
登場角色列表。
- `edges`: 角色關聯列表，包含 `role`（主角/配角）、`name`（角色名稱）、`voiceActors`（聲優列表）與 `node`（角色詳細資訊）。

### StaffPreview
工作人員列表。
- `edges`: 工作人員關聯列表，包含 `role`（職位，如導演、編劇）與 `node`（工作人員詳細資訊）。

### Stats
媒體的統計數據。
- `statusDistribution`: 各種觀看狀態（想看、在看、已看等）的使用者人數分佈。
- `scoreDistribution`: 各評分區間的評分數量分佈。

### Recommendations
相似作品推薦。
- `nodes`: 推薦節點列表，包含 `rating`（評分）、`userRating`（使用者評分）、`mediaRecommendation`（被推薦的媒體）與 `user`（推薦者）。

### ReviewPreview
使用者短評。
- `nodes`: 評價節點列表，包含 `summary`（簡介/摘要）、`rating`（評價分數）、`ratingAmount`（評價總數）與 `user` / `reviewer` （評價者）。

### ExternalLinks
外部連結。
- `id`: 連結的唯一識別碼。
- `site`: 網站名稱（例如：Crunchyroll, Netflix）。
- `url`: 外部連結的 URL。
- `type`: 連結類型（如官方網站、串流播放）。
- `language`: 網站所屬語言。
- `color`: 網站對應的品牌代表色。
- `icon`: 網站圖示的 URL。
- `notes`: 備註說明。
- `isDisabled`: 是否已停用。

### Tag
媒體標籤。
- `id`: 標籤的唯一識別碼。
- `name`: 標籤名稱。
- `description`: 標籤的內容描述。
- `rank`: 該標籤與此作品的關聯度排名（百分比）。
- `isMediaSpoiler`: 此標籤是否涉及作品劇透。
- `isGeneralSpoiler`: 此標籤是否為一般性劇透。
- `userId`: 建立此標籤的使用者 ID。
