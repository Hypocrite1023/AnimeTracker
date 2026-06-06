# AnimeTracker

AnimeTracker 是一款 iOS 應用程式，旨在幫助使用者追蹤與管理他們喜愛的動漫系列。本應用程式提供最新熱門動漫資訊、強大的動漫搜尋功能，並能讓使用者建立個人的收藏清單與追蹤新番播出時間表。

## 核心功能

- **熱門動漫 (Trending Page)**：基於 SwiftUI 實作，以精美網格展示當前最受歡迎的動漫作品，並支援長按彈出式操作選單。
- **分類瀏覽 (Category Page)**：基於 SwiftUI 實作，依照不同類別與風格推薦熱門動漫。
- **動漫搜尋 (Search Page)**：支援依據類型（Genre）、標籤（Tags）、年份、季度等條件進行多維度搜尋。
- **個人收藏 (Favorite Page)**：顯示使用者收藏的動漫，並提供取消收藏或開啟/關閉新番更新通知的功能。
- **追蹤時間線 (Timeline Page)**：展示使用者收藏的動漫清單，並依據距離下一集播出的倒數時間進行排序。
- **詳細資訊頁面 (Anime Detail Page)**：提供豐富的動漫詳情，包含故事大綱、登場角色、聲優、製作團隊及相關作品等。

## 安裝與執行說明

本專案使用 **XcodeGen** 來管理 Xcode 專案結構，並採用 **Swift Package Manager (SPM)** 處理第三方套件。因此，請依照以下步驟在本地端設定並執行專案：

### 1. 複製專案庫
```bash
git clone https://github.com/Hypocrite1023/AnimeTracker.git
cd AnimeTracker
```

### 2. 安裝 XcodeGen
本專案不直接提交 `.xcodeproj` 與 `.xcworkspace` 檔案。你需要先在你的 macOS 上安裝 `xcodegen` 工具：
```bash
brew install xcodegen
```

### 3. 生成 Xcode 專案
在專案根目錄下，執行以下指令以根據 `project.yml` 設定檔來生成 Xcode 專案：
```bash
xcodegen generate
```
執行成功後，會在根目錄產生 `AnimeTracker.xcodeproj` 專案檔。

### 4. 使用 Xcode 開啟專案
雙擊開啟 `AnimeTracker.xcodeproj`。

### 5. 下載依賴並執行
- 開啟專案後，Xcode 會透過 **Swift Package Manager (SPM)** 自動下載所需的依賴套件。
- 下載完成後，選擇你想要運行的 iOS 模擬器或實體裝置，點擊 **Run** (或按下 `Cmd + R` 鍵) 即可建置並執行應用程式。

## 技術細節

- **開發語言與框架**：使用 **Swift 5** 開發，主要介面以 **UIKit** 實作，分類頁面等部分採用 **SwiftUI**。
- **軟體架構**：採用 **Model-View-ViewModel (MVVM)** 設計模式，確保介面邏輯與業務邏輯的分離。
- **反應式編程 (Reactive Programming)**：利用 Apple 的 **Combine** 框架，並結合 `CombineCocoa` 與 `CombineExt` 來處理 UI 事件與非同步資料綁定。
- **網路通訊**：使用 GraphQL 查詢與 AniList API (`https://graphql.anilist.co`) 進行高效的動漫數據檢索。
- **雲端整合**：使用 **Firebase** 套件：
  - **FirebaseAuth**：處理使用者註冊、登入與密碼重設。
  - **FirebaseFirestore**：用作雲端資料庫，即時同步使用者的收藏清單與通知設定。
- **第三方套件 (透過 SPM 管理)**：
  - [SnapKit](https://github.com/SnapKit/SnapKit.git)：以優雅的程式碼建構 AutoLayout。
  - [Kingfisher](https://github.com/onevcat/Kingfisher.git)：高效能的網絡圖片非同步下載與快取。
  - [Lottie](https://github.com/airbnb/lottie-ios.git)：解析與渲染豐富的向量動畫。
  - [SkeletonUI](https://github.com/CSolanaM/SkeletonUI.git)：在資料載入時提供流暢的骨架屏 (Skeleton) 載入動畫。
  - [LookinServer](https://github.com/QMUI/LookinServer.git)：輔助 iOS UI 視覺除錯工具（僅在 Debug 模式下啟用）。

關於詳細的架構說明，請參考 [ARCHITECTURE.md](file:///Users/rexchiu/AnimeTracker/ARCHITECTURE.md)。

## 開發紀錄

開發過程中的重點筆記與問題修復，請參考 [CHANGELOG.md](file:///Users/rexchiu/AnimeTracker/CHANGELOG.md)。