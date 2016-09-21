# FireAce (iOS)

[Firebase](https://firebase.google.com/) を試してみるためのアプリとその記録

現時点ではXcode 7.3.1で確認中

## Firebaseのセットアップ（各機能共通）

#### Firebaseコンソール

- プロジェクトを追加
  - プロジェクト名
  - 組織/会社の国や地域
- プロジェクト内にiOSアプリを追加
  - バンドルID
- 追加したiOSアプリの `GoogleService-Info.plist` ファイルをダウンロードしておく

#### Xcodeプロジェクト

- `GoogleService-Info.plist` ファイルをプロジェクトに追加しておく
- CocoaPodsでSDKを組み込む
  - 必要に応じて `pod init`
  - Podfileに `pod 'Firebase/Core'`
  - `pod install`
- `application(_:didFinishLaunchingWithOptions:)` の中に次のコードを書く（※要 `import Firebase`)
  ```swift
  FIRApp.configure()
  ```

## Analytics

ユーザーが起こした行動（イベント）を記録して解析。
ユーザーにプロパティを設定しておくことで、イベントを起こしたユーザーのプロパティで絞り込んだりできる。

#### イベント

- 何もしなくても [ある程度のイベント](https://support.google.com/firebase/answer/6317485) は自動的に取得されている。
- 次のようにして特定のイベントを埋め込むこともできる。
  ```swift
  FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
      kFIRParameterContentType: "root_item",
      kFIRParameterItemID: item.id,
  ])
  ```
- 独自のイベント名・パラメータを送ることもできるけど、BigQueryにエクスポートしないと詳細は確認できない？
  ```swift
  FIRAnalytics.logEventWithName("ace_event", parameters: [
      "value": value,
  ])
  ```

#### ユーザープロパティ

- 何もしなくても [ある程度のユーザープロパティ](https://support.google.com/firebase/answer/6317486) は自動的に設定されている。
- 次のようにして独自のプロパティを設定することもできる。
  ```swift
  FIRAnalytics.setUserPropertyString(value, forName: "fav_ice_cream")
  ```
- プロパティはその後に送られるイベントに付加される。（`setUserPropertyString(_:forName:)`を呼んだだけでは何も起こらない）


#### ユーザーリスト (audience)

過去に特定のイベントを起こしたり、特定のユーザープロパティがついたイベントを起こしたことのある人をまとめたユーザーリストを作れる。
このリストをRemote ConfigやCloud Messagingで使うことができる。

Firebaseコンソール Analytics のユーザータブで条件を指定したリストを作るだけ。

#### ハマりポイント

- イベントはアップロードされてもすぐにはコンソールに反映されない。（1日1回くらい反映タイミングがある？次の日くらいに反映されている）
- ある程度（10人？）以上ユーザーがいないとユーザーリストには表示されない。[→参考](http://qiita.com/chanibarin/items/48d5f5946b1e6c97e379#%E3%83%8F%E3%83%9E%E3%82%8A%E3%83%9D%E3%82%A4%E3%83%B3%E3%83%88-all-users%E4%BB%A5%E5%A4%96%E3%81%AE%E3%82%A4%E3%83%99%E3%83%B3%E3%83%88%E3%81%AE%E3%83%A6%E3%83%BC%E3%82%B6%E3%81%8C0%E3%81%A0%E3%81%91%E3%81%A9%E4%BD%95%E3%81%A7)
- 一度ユーザーリストに載った人は、そのリストからなくなることはない。 [→参考](http://stackoverflow.com/questions/37450256/is-there-a-way-to-create-an-audience-of-developer-builds/37473026#comment62445594_37473026)


## Authentication

ユーザーのサインアップ、サインイン・サインアウト。
[FirebaseUI](https://github.com/firebase/FirebaseUI-iOS) を使えば、かんたんに実現できる。


## Remote Config

アプリで扱う値（動作のパラメーター）をサーバーで後から上書きできる。
特定の条件のユーザーだけ上書きしたりも可能。

- アプリ側のコードでデフォルト値を設定
  ```swift
  let remoteConfig = FIRRemoteConfig.remoteConfig()
  remoteConfig.setDefaults([
      "type": "Type-A",
      "level": 1,
  ])  
  ```
- 値の取得
  ```swift
  let typeValue = remoteConfig["type"].stringValue ?? ""
  ```
- FirebaseコンソールのRemove Configで上書き
  - Conditionを作れば、その条件に合致する場合の値を設定できる
- アプリ側コードでfetchすることでサーバーの設定をキャッシュ（フェッチ間隔以上経ってなければサーバーは見に行かない）し、activateしたときにその設定を反映。その後に値を取得すると新しい値に変わる。

## Cloud Messaging

#### 2種類のメッセージ

- 通知用（ユーザーに表示するメッセージ）
  - APNを使って実現されるので、アプリが起動していないときはOSの通知として表示される。
- データ（アプリが扱うデータ）
  - Firebase Cloud Messaging (FCM)と接続している間だけ受け取ることができる。（アプリが前面にいないときは受け取れない）

FireAceでは通知の方しか試してない。

#### APN用のクライアント証明書を設定

- Member Centerにアプリを登録
- Member CenterでアプリのPush Notificationsを有効にしてSSL証明書を作成する
  - キーチェーンアクセスで証明書要求を作成（Member CenterでCreate Certificateボタンを押したら作成方法の案内が書かれている）
  - 作成した証明書要求（.certSigningRequestファイル）をアップロード
  - 証明書をダウンロード → ダブルクリックでキーチェーンアクセスへ
- キーチェーンアクセスで証明書の鍵を右クリックして書き出し → パスワードを入力 → (.p12ファイルができる)
- Firebaseコンソールでプロジェクトの設定→クラウド メッセージングから証明書をアップロード

#### アプリのコード

デフォルトではmethod swizzlingを使ってトークンの結びつけなどをFirebase SDK側が自動的にやってくれているらしい。

- `application(_:didFinishLaunchingWithOptions:)` にRemote Notificationの要求・登録を行う
- `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` をオーバーライドして、アプリ起動中にRemote Notificationがやってきたときの動作を記述。

※iOS 10以降（要Xcode 8）では登録・受け取り方法が変わってるので注意。（Firebaseに限った話ではない）

#### 通知

FirebaseコンソールのNotificationsから通知を作成。時間設定などもできる。

- 特定の端末へ通知
  - トークンID
- ユーザーセグメントへ通知（次の条件で絞込）
  - ユーザー層（audience) … Analyticsで設定したもの
  - 言語
  - バージョン
- トピックへ通知
  - アプリ側で `FIRMessaging.messaging().subscribeToTopic()` で購読しているユーザーに通知
