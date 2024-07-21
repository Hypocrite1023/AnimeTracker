#  AnimeTracker
### Trending Page
<img src = "https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-07-18%20at%2021.47.05.png" width = "200">

### Searching Page
<img src = "https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-07-17%20at%2022.38.56.png" width = "200">

### Anime Detail Page
<img src = "https://github.com/Hypocrite1023/AnimeTracker/blob/main/demo/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-07-20%20at%2023.33.46.png" width = "200">

#### 遇到的問題紀錄
> 2024.07.20
>> UIScrollView沒辦法上或下滑動，後來發現如果是使用AutoLayout 加入UIScrollView的最後一個物件，他的trailing anchor一定要設成那個UIScrollView的trailing anchor
>> 這個問題是我在寫動畫詳細介紹頁面的時候遇到的，有６個按鈕但我怕一般直立的裝置沒辦法全部擠進去，所以使用了scroll view

