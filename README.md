#  AnimeTracker
### Trending Page
<img src = "https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-07-18%20at%2021.47.05.png" width = "200">

### Searching Page
<img src = "https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-07-17%20at%2022.38.56.png" width = "200">

### Anime Detail Page
[![Watch the video](https://img.youtube.com/vi/9i-IkybcsOQ/0.jpg)]
(https://youtube.com/shorts/9i-IkybcsOQ?si=AVUDLoM01vDf2PCn)
<img src = "https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/screenshot%202024-07-24%2023.02.45.png" width = "200">

#### 遇到的問題及紀錄
> 2024.07.20
>> UIScrollView沒辦法上或下滑動，後來發現如果是使用AutoLayout 加入UIScrollView的最後一個物件，他的trailing anchor一定要設成那個UIScrollView的trailing anchor  
>> 這個問題是我在寫動畫詳細介紹頁面的時候遇到的，有６個按鈕但我怕一般直立的裝置沒辦法全部擠進去，所以使用了scroll view
   
> 2024.07.24
>> storyboard中的UIScrollView有content layout guide 和 frame layout guide  
>> content layout guide  
>> 定義:
	•	表示捲動視圖中可捲動內容的大小和位置。  
	•	約束這個 guide 可以用來確定捲動視圖內容的大小和位置。  
	•	換句話說，它代表的是捲動視圖的整個內容區域，包括所有可捲動的部分，而不僅僅是目前可見的部分。  
>> 用途:  
	•	如果你需要設置捲動視圖的內容大小，比如確定內容的總高度或寬度，你需要使用這個 guide。  
>> frame layout guide
>> 定義:  
	•	表示捲動視圖本身的邊界和位置。  
	•	約束這個 guide 可以用來確定捲動視圖的實際大小和位置。  
	•	它代表的是捲動視圖的可見區域，即不包含任何超出邊界的捲動內容部分。  
>> 用途:  
	•	這個 guide 用於約束捲動視圖本身的大小和位置。

> 2024.07.25
>> frame layout guide的用途：
>> 如果在scroll view中想讓某個view不要離開畫面，便可以利用這個屬性

> 2024.08.06
>> 自己寫code需要更細心，今天寫浮動按鈕跳轉頁面，我想說明明tabBarController selectedIndex是設定正確的，但每次跳到的頁面都是同一頁，問了chatgpt也不知道哪裡有問題  
後來發現原來是我設定的page不對，越簡單的code越需要細心啊
'''
let goToTrendingPageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 0)
trendingBtn.addGestureRecognizer(goToTrendingPageGesture)
let goToSearchingPageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 1)
searchingBtn.addGestureRecognizer(goToSearchingPageGesture)
let goToFavoritePageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 2)
favoriteBtn.addGestureRecognizer(goToFavoritePageGesture)
'''

