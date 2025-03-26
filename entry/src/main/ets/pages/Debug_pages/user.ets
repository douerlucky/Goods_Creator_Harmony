interface UserInfo {
  avatar: string;
  username: string;
  userId: string;
  coin: number;
}
@Entry
@Component
struct MyPage {
  @State userInfo: UserInfo = {
    avatar: 'Akie_Dream', // 替换为实际头像路径
    username: 'Sawako碎花',
    userId: 'uid_2044',
    coin: 30
  };

  build() {
    Column() {
      Row() {
        Image($r('app.media.Akie_Dream'))// 返回箭头图标，需准备资源
          .size({ width: 20, height: 20 })
          .fillColor(' #007AFF')
          .margin({ left: 16 })
        Text('主页')
          .fontSize(16)
          .fontWeight(500)
          .fontColor(' #007AFF')
          .margin({ left: 16 })
      }.width('90%')
      .margin({ bottom: 20 })


      Row() {
        Image($r('app.media.Akie_Dream'))
          .width(70)
          .height(70)
          .borderRadius(40)
          .margin({ left: 16 })

        Column() {
          // 用户名
          Text(this.userInfo.username)
            .fontSize(18)
            .fontWeight(500)
          // UID
          Text('1234567')
            .fontSize(14)
            .fontColor('#666666')
          // 谷币
          Row() {
            Image($r('app.media.Akie_Dream'))// 准备金币图标资源
              .width(20)
            Text(`${this.userInfo.coin} 谷币`)
              .fontSize(14)
              .margin({ left: 4 })
          }
          .backgroundColor('#FFC147')
          .padding({
            left: 8,
            right: 8,
            top: 2,
            bottom: 2
          })
          .borderRadius(12)
        }
        .margin({ left: 16 })


        Column() {
          // 账号设置按钮
          Button('账号设置')
            .width(80)
            .height(40)
            .fontSize(12)
            .borderRadius(20)

          // 退出登录按钮
          Button('账号设置')
            .width(80)
            .height(40)
            .fontSize(12)
            .borderRadius(20)
            .margin({ top: 8 })
        }
        .margin({ left: 20 })

      }.width('90%')
      .height('15%')
      .backgroundColor('#f5f5f5')
      .borderRadius(20)


      Row() {
        Text('所有素材')
          .fontSize(16)
          .padding({ left: 16, top: 12, bottom: 12 })
      }
      .margin({ top: 8 ,bottom:10})
      .backgroundColor('#f5f5f5')
      .width('90%')
      .borderRadius(20)

      // 历史浏览
      Row() {
        Text('历史浏览')
          .fontSize(16)
          .padding({ left: 16, top: 12, bottom: 12 })
        Blank()
        Image($r('app.media.Akie_Dream'))// 日历图标
          .size({ width: 20, height: 20 })
          .margin({ right: 16 })

      }
      .margin({ top: 4 })
      .backgroundColor('#f5f5f5')
      .width('90%')
      .borderRadius(20)

      // 所有收藏
      Row(){
        Text('所有收藏')
          .fontSize(16)
          .padding({ left: 16, top: 12, bottom: 12 })
        Blank()
        Image($r('app.media.Akie_Dream'))// 日历图标
          .size({ width: 20, height: 20 })
          .margin({ right: 16 })
      }
      .margin({ top: 4 })
      .backgroundColor('#f5f5f5')
      .width('90%')
      .borderRadius(20)

      // 所有发布的作品
      Row(){
        Text('所有发布的作品')
          .fontSize(16)
          .padding({ left: 16, top: 12, bottom: 12 })
        Blank()
        Image($r('app.media.Akie_Dream')) // 日历图标
          .size({ width: 20, height: 20 })
          .margin({ right: 16 })
      }
      .margin({ top: 4 })
      .backgroundColor('#f5f5f5')
      .width('90%')
      .borderRadius(20)

      Text('关于谷创......')
        .fontSize(16)
        .foregroundColor('#186AFF')
        .margin({ top: 16, left: 16 })
        .width("90%")

    }
    .width('100%')
  }
}