NYTimes-Bestseller is an iOS app developed in Swift language for practicing purpose. This app supports iOS 10 and above.

Features:
- View all best seller book categories.
- View all best seller books by categories: title, description, amazon link, review link.
- Sort by rank or weeks on best seller list.
- Offline mode.

Steps to test app:
1. Use your XCode to build app to your device.
2. First time, app will retrieve book categories from server side and save it locally for caching.
3. Tap to any category to retrieve books data for the first time and data will be saved locally for caching.
4. Tap to sort button (top right button on navigation bar), try to sort by rank or weeks on list.
5. Terminate app then open it again and you will see the last sort option you selected is saved.
6. Turn off internet to test offline mode, now you can view all categories and all books which you viewed on step 3
7. Turn on internet, go to Setting - General - Date & Time, switch off "Set Automatically", then set the time to next 7 days or more.
8. Open file APIService.swift on Xcode project, set break point inside 2 methods: getBookCategories, getBookListsWith
9. Build app again, app open - try to select some category . You will see debugging process will stop at these 2 breakpoints. 
That means local data will be updated every 7 days.

Techonology:
- Swift 4.2
- CoreData
- iOS SDK
