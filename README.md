# Screenshots:

<p align='center'>
<img src='https://github.com/DucaturFw/cold-crypto-mobile/raw/master/screens/img1.png' height='450' alt='screenshot' />
<img src='https://github.com/DucaturFw/cold-crypto-mobile/raw/master/screens/img2.png' height='450' alt='screenshot' />
<br/>
<img src='https://github.com/DucaturFw/cold-crypto-mobile/raw/master/screens/img3.png' height='450' alt='screenshot' />
<img src='https://github.com/DucaturFw/cold-crypto-mobile/raw/master/screens/img4.png' height='450' alt='screenshot' />
</p>

# Requirements:

* Mac OS X
* xCode 10
* git
* swift 4.2

# Installation:

1. open `Terminal.app`
2. install `cocoapods` by `sudo gem install cocoapods` or via https://guides.cocoapods.org/using/getting-started.html#getting-started
3. install `carthage` by `brew install carthage` or via https://github.com/Carthage/Carthage#quick-start
4. create new folder `mkdir ./cold`
5. open it `cd ./cold`
6. run `git clone https://github.com/DucaturFw/cold-crypto-mobile.git`
7. run `cd ./cold-crypto-mobile`
8. run `pod install`
9. open `EthereumKit` folder by `cd ./EthereumKit`
10. run `carthage update --platform ios`
11. move back `cd ../`
12. open xCode workspace by `open ColdCrypto.xcworkspace`
13. select `ColdCrypto` in targets in top left corners
14. clear project by `shift + cmd + K`
15. run project (by default it's `cmd + R`) on a device (required Apple developer account) or in simulator
