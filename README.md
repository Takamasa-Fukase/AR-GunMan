# AR-GunMan

AR-GunManはターゲットに向かって端末を振ったり、回転させたりすることで直感的に武器を操作できるARシューティングゲームです。

iOSプラットフォーム向けにSwiftとARKit、CoreMotionを用いて開発されています。

### See Also
* [AR-GunMan-Android](https://github.com/Takamasa-Fukase/AR-GunMan-Android)
* [AR-GunMan-Unity](https://github.com/Takamasa-Fukase/AR-GunMan-Unity)

# Demo

### Video
https://github.com/user-attachments/assets/d0370886-e9ef-4480-a99f-7301d9929bb8

### Images
![AR-GunMan_demo_image1](https://user-images.githubusercontent.com/58412688/155363994-46f9a5df-e486-4c1d-ad46-dea487d13d77.png)
![AR-GunMan_demo_image2](https://user-images.githubusercontent.com/58412688/155363998-05b6b3b9-5335-450e-b3f5-99ffac815314.png)
![AR-GunMan_demo_image3](https://github.com/user-attachments/assets/c65abc43-169d-47ea-84f1-5da72d3553c9)
![AR-GunMan_demo_image4](https://github.com/user-attachments/assets/d5d1a41f-e3f0-4097-88fc-12fb98d8f4e6)
![AR-GunMan_demo_image5](https://github.com/user-attachments/assets/ab826857-b46f-495e-a70e-36f8d7562e32)

# Download

[AppStoreでAR-GunManをダウンロード](https://apps.apple.com/jp/app/ar-gunman/id1542082005)

[![AR-GunMan_appicon](https://github.com/user-attachments/assets/6e4635c5-474c-4d6a-8adc-ede5ee721eee)](https://apps.apple.com/jp/app/ar-gunman/id1542082005)



# Architecture

### モジュール構成
SwiftPackageを用いたマルチモジュール構成になっています。

Data層・Domain層、大きな機能であるAR実装部分、CoreMotionによる武器の操作モーション関連をパッケージとして切り出してそれぞれメインプロジェクトから呼び出して使用しています。

![AR-GunManモジュール構成図](https://github.com/user-attachments/assets/93ed7f0a-031d-40fe-8209-ab20fa7f3187)

### アーキテクチャ構成
クリーンアーキテクチャをベースとし、Presentation層はSwiftUIとObservation+Combineを用いたMVVM構成としています。

![AR-GunManアーキテクチャ図](https://github.com/user-attachments/assets/e00a1757-1a06-4f7f-8caf-942ef981f108)

# Author

* Takamasa Fukase (Ultra-Fukase)
* https://www.instagram.com/takamasa_fukase/
* https://www.youtube.com/@UltraFukaseGekishibu
