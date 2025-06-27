## Project Architecture

This document outlines the architecture of the AnimeTracker iOS project.

### High-Level Overview

The project is an iOS application built using Swift and the UIKit framework. It follows the **Model-View-ViewModel (MVVM)** architectural pattern to ensure a clear separation of concerns and to facilitate testing and maintenance. The application uses Firebase for backend services, including user authentication, and relies on CocoaPods for managing third-party dependencies.

### Directory Structure

The project is organized into the following main directories:

- **AnimeTracker/**: Contains the core source code of the application.
- **AnimeTracker.xcodeproj/**: Xcode project configuration files.
- **AnimeTrackerTests/**: Unit tests for the application logic.
- **AnimeTrackerUITests/**: UI tests for the application.
- **Pods/**: Third-party libraries managed by CocoaPods.
- **fastlane/**: Automation scripts for building and releasing the application.
- **vendor/**: Additional third-party dependencies.

### Architectural Pattern: MVVM

The application's architecture is based on the MVVM pattern, which is composed of three main components:

- **Model**: The `Model/` directory contains the data models for the application, such as `AnimeSummary`, `CharacterDetail`, and `MediaRanking`. These models define the structure of the data used throughout the application.
- **View**: The `View/` directory contains the UI components, including custom views like `CharacterView` and `OverviewView`. The application also uses Storyboards for designing the user interface and defining the navigation flow.
- **ViewModel**: The ViewModels, such as `AnimeDetailPageViewModel` and `SearchPageViewModel`, are responsible for the business logic of the application. They fetch data from the Model, process it, and expose it to the View for display.

### Key Components and Technologies

- **Networking**: The `Api/AnimeDataFetcher.swift` class handles all network requests to the anime data API. The `Api/Response/` directory contains the data models for the API responses.
- **Firebase Integration**: The `Firebase/FirebaseManager.swift` class manages the integration with Firebase services, including user authentication.
- **UI and Navigation**: The application uses a `TabBarController` for the main navigation and a custom `NavigationController` for managing the navigation stack. Storyboards are used to design the UI and the navigation flow.
- **Data Persistence**: The `UserCache/UserCache.swift` class is used for caching user data locally.
- **Asynchronous Programming**: The project uses the **Combine framework** for handling asynchronous operations, such as network requests and user input events. This is evident from the use of `PassthroughSubject` and `cancellables` in the codebase.
- **Dependency Management**: The project uses **CocoaPods** to manage its third-party dependencies, which are listed in the `Podfile`.
- **Testing**: The project includes both unit tests (`AnimeTrackerTests/`) and UI tests (`AnimeTrackerUITests/`) to ensure the quality and correctness of the code.

### Conclusion

The AnimeTracker project is a well-structured and modern iOS application that follows best practices for mobile development. The use of the MVVM pattern, the Combine framework, and a comprehensive testing suite makes the codebase maintainable, scalable, and robust.
