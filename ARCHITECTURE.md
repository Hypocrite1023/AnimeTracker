## 專案架構說明 (Project Architecture)

此文件說明了 AnimeTracker iOS 專案的軟體架構、目錄結構、關鍵元件及所使用的技術。

### 架構概述

本專案是一款基於 Swift 與 UIKit 框架開發的 iOS 應用程式，並在特定頁面（如 `CategoryPage`）融入了 SwiftUI。
專案遵循 **Model-View-ViewModel (MVVM)** 架構模式，以實現清晰的關注點分離 (Separation of Concerns)，提升程式碼的可維護性與可測試性。
專案使用 **XcodeGen** 作為專案配置與生成工具，並採用 **Swift Package Manager (SPM)** 作為套件依賴管理系統，透過 Firebase 提供後端雲端同步服務。

### 目錄結構

專案目錄結構非常清晰明瞭，重要檔案及目錄如下：

- **[AnimeTracker/](file:///Users/rexchiu/AnimeTracker/AnimeTracker)**：包含應用程式的所有核心原始碼與資源檔案。
  - **[Api/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/Api)**：處理 GraphQL 網路請求、API 回應資料結構（Response Models）的解碼。
  - **[Model/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/Model)**：定義專案內部的資料模型。
  - **[Firebase/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/Firebase)**：Firebase Manager 實作，負責 Auth 驗證與 Firestore 雲端資料庫操作。
  - **[UserCache/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/UserCache)**：本地使用者狀態的快取管理。
  - **各功能頁面資料夾**（例如 [TrendingPage/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/TrendingPage), [SearchPage/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/SearchPage), [CategoryPage/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/CategoryPage), [FavoritePage/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/FavoritePage), [AnimeDetailPage/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/AnimeDetailPage) 等）：各自包含該模組的 ViewController, View 與 ViewModel，展現模組化設計。
  - **[Component/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/Component)** & **[View/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/View)**：通用的 UI 元件與客製化視圖。
  - **[Extension/](file:///Users/rexchiu/AnimeTracker/AnimeTracker/Extension)**：對系統類別的擴充（Extensions）。
- **[project.yml](file:///Users/rexchiu/AnimeTracker/project.yml)**：XcodeGen 的專案配置定義檔，用來聲明專案 Target、編譯設定與 SPM 套件依賴。
- **[AnimeTrackerTests/](file:///Users/rexchiu/AnimeTracker/AnimeTrackerTests)**：針對業務邏輯的單元測試。
- **[AnimeTrackerUITests/](file:///Users/rexchiu/AnimeTracker/AnimeTrackerUITests)**：針對使用者介面的 UI 測試。
- **[*.xcconfig](file:///Users/rexchiu/AnimeTracker/)** (例如 `AnimeTracker-Shared.xcconfig` 等)：儲存專案環境編譯參數的設定檔。

### 架構設計模式：MVVM

專案全面採用 MVVM 模式進行開發：

1. **Model (模型)**：
   - 定義資料結構與解碼邏輯（例如 `AnimeDetail`, `Media`, `FavoriteAnime` 等）。這些模型負責承載純粹的資料，不涉及任何 UI 的呈現。
2. **View (視圖)**：
   - 負責畫面的顯示與使用者的直接互動。包含 `ViewController`（如 `TrendingPageViewController`）、自訂 `UIView`（如 `OverviewView`）以及 SwiftUI 的 `CategoryView`。
   - 視圖元件不處理業務邏輯，僅透過 Combine 訂閱 ViewModel 的狀態變更，或透過 UI 事件觸發 ViewModel 的動作。
3. **ViewModel (視圖模型)**：
   - 負責處理各頁面的業務邏輯（例如 `SearchPageViewModel`）。
   - ViewModel 會從 API 資料抓取器（`AnimeDataFetcher`）或 Firebase（`FirebaseManager`）獲取資料，經過加工轉換後，透過 Combine 的發佈者（Publishers，例如 `@Published` 屬性或 `PassthroughSubject`）將狀態暴露給 View。

### 關鍵元件與技術

- **網路通訊 (GraphQL)**：
  - 專案未採用傳統 RESTful API 或 gRPC，而是使用 GraphQL 查詢與 AniList API 伺服器 (`https://graphql.anilist.co`) 通訊。
  - 透過自訂的 `AnimeDataFetcher` 統一發送 GraphQL 請求，並透過 Combine 傳遞回應。
- **反應式編程 (Combine)**：
  - 本專案的核心。利用 Swift 自帶的 Combine 框架實作響應式資料綁定。
  - 引入了 `CombineCocoa` 來簡化 UIKit 控制項（如按鈕點擊、滾動事件）的 Combine 整合，並使用 `CombineExt` 擴充 Combine 的操作符（如處理頻繁觸發 API 請求的 `throttle`）。
- **資料儲存與使用者驗證 (Firebase)**：
  - `FirebaseManager` 單例封裝了與 Firebase 的交互邏輯。
  - **FirebaseAuth** 用於管理使用者的帳號登入與註冊狀態。
  - **FirebaseFirestore** 用於即時儲存和同步使用者的收藏清單與通知喜好，並利用分頁機制（Pagination）加載大量收藏資料。
- **版面配置 (SnapKit)**：
  - 棄用繁瑣的系統 AutoLayout 原生 API，改以 `SnapKit` 在程式碼中定義流暢的約束條件。
- **專案管理 (XcodeGen)**：
  - 為避免團隊協作時常見的 `.xcodeproj` 衝突，專案檔案透過 `project.yml` 統一描述，並在本地運行 `xcodegen generate` 產生 Xcode 專案檔案，真正做到專案配置的「程式碼化」。

### 結論

AnimeTracker 的架構設計高度模組化且現代化。透過 XcodeGen 與 SPM 確保了專案配置與依賴的乾淨透明；藉由 MVVM 與 Combine 實現了清晰的資料流與狀態綁定；同時結合了 UIKit 的穩定與 SwiftUI 的現代化 UI 宣告方式，為專案的後續擴充奠定了極佳的基礎。
