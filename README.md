# AnimeTracker

AnimeTracker is an iOS application that allows users to track their favorite anime series. The app provides information about trending anime, allows users to search for anime, and helps them keep track of their favorite shows.

<p align="center">
  <img src="https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/login.png" width="200">
  <img src="https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/register.png" width="200">
  <img src="https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/resetpass.png" width="200">
</p>

## Features

- **Trending Page**: Displays the most popular anime series at the moment.
- **Category Page**: Shows trending anime by category.
- **Search Page**: Allows users to search for anime by genre, tags, year, season, and more.
- **Favorite Page**: Displays a user's favorite anime series, with the ability to unfavorite or disable notifications.
- **Timeline Page**: Lists a user's favorite anime, sorted by the time remaining until the next episode airs.
- **Anime Detail Page**: Provides detailed information about a selected anime series.

<p align="center">
  <img src="https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/trending.png" width="200">
  <img src="https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/category.png" width="200">
  <img src="https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/animeDetail1.png" width="200">
</p>

## Installation

To run the AnimeTracker app on your local machine, follow these steps:

1. **Clone the repository**:

   ```
   git clone https://github.com/Hypocrite1023/AnimeTracker.git
   ```

2. **Install the dependencies**:

   The project uses CocoaPods to manage its dependencies. To install the required pods, run the following command in the project's root directory:

   ```
   pod install
   ```

3. **Open the project in Xcode**:

   Open the `AnimeTracker.xcworkspace` file in Xcode.

4. **Run the app**:

   Select a simulator or a physical device and click the "Run" button to build and run the app.

## Usage

Once the app is running, you can perform the following actions:

- **Browse trending anime**: The "Trending" tab displays the most popular anime series.
- **Search for anime**: The "Search" tab allows you to search for anime by various criteria.
- **View anime details**: Tap on an anime series to view its details, including a summary, characters, and more.
- **Add to favorites**: On the anime detail page, you can add an anime to your favorites list.
- **Track your favorite anime**: The "Favorite" tab displays your favorite anime, and the "Timeline" tab shows you when the next episode will air.

## Technical Details

- **Architecture**: The project follows the **Model-View-ViewModel (MVVM)** architectural pattern.
- **Frameworks**: The app is built using **Swift** and the **UIKit** framework.
- **Asynchronous Programming**: The app uses the **Combine** framework for handling asynchronous operations.
- **Dependencies**: The project uses **CocoaPods** for dependency management. The main dependencies include:
  - **Firebase**: For user authentication and other backend services.
  - **gRPC**: For communication with the backend.

For more information about the project's architecture, see the `ARCHITECTURE.md` file.

## Development Log

For a detailed log of the project's development, see the `CHANGELOG.md` file.