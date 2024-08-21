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
```
let goToTrendingPageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 0)
trendingBtn.addGestureRecognizer(goToTrendingPageGesture)
let goToSearchingPageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 1)
searchingBtn.addGestureRecognizer(goToSearchingPageGesture)
let goToFavoritePageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 2)
favoriteBtn.addGestureRecognizer(goToFavoritePageGesture)
```
> 2024.08.07
>> 使用singleton pattern: 當同個物件會在整個project中不斷地使用．使用singleton pattern的物件只能有一個實例，被呼叫才會create  
>> Sandbox: rsync.samba(3701) deny(1) file-write-create /Users/rex/Library/Developer/Xcode/DerivedData/AnimeTracker-djkxbuuynisxwxgyttsguaxwcvps/Build/Products/Debug-iphonesimulator/AnimeTracker.app/Frameworks/openssl_grpc.framework/_CodeSignature  
>>> User Script Sandboxing Yes -> No  
  
> 2024.08.21  
>> 傳遞非同步資料該使用delegate or escape closure?  
>>> 我一開始寫的時候因為對escape closure還不熟，所以在傳遞從非同步的資料都是使用delegate，但後來需要傳遞的資料種類越來越多，每種傳遞的資料都需要寫一個protocol  
>>> 有時候又會忘記設定delegate的對象，後來對escape closure比較熟後，只要是非同步資料的傳遞我都喜歡使用escape closure，因為簡單而且不會忘記寫delegate的對象  
>> 當character preview 被 tap，要通知viewController使用api來獲得資料並在獲得資料後更新UI  
>> 使用delegate(利用protocol):  
>>> 1. character preview(UIView)透過UITapGestureRecognizer知道他被點了  
>>> 2. 透過delegate通知viewController要拿資料(MVC，view不處理資料)  
>>> 3. viewController透過AnimeDataFetcher拿到資料(需要實現相關的protocol)  
>>> 4. AnimeDataFetcher再透過delegate傳資料到viewController  
>>> 5. viewController拿到資料並更新UI  
>> 使用completion handler(escaping closure):  
>>> 1. character preview(UIView)透過UITapGestureRecognizer知道他被點了  
>>> 2. 透過delegate通知viewController要拿資料(MVC，view不處理資料)  
>>> 3. viewController透過AnimeDataFetcher拿到資料再經由completion handler更新UI  
>>>> 從上面例子可以看到 delegate 會比 completion handler 使用上來的複雜一點，不過當一次抓的資料種類比較多，使用delegate可以為不同的資料加入不同的function，
比如說我同時獲得了character和voice actor的資料，這兩種資料更新的UI是不同的，這時候就可以透過不同的function處理，使用completion handler時，處理不同資料的程式碼
都混再一起，所以使用delegate程式碼的結構會比較清楚  
