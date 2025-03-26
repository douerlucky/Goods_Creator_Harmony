@Entry
@Component
struct Select_Creat {

  build() {
    Stack({alignContent:Alignment.TopStart})
    {
      Column()
      {
        Blank()
          .height(80)
        Text("创作")
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        Blank()
          .height(80)
        Row({space:15})
        {
          Image($r("app.media.create_budge_icon"))
            .width(96)
          Column()
          {
            Text("创作吧唧")
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
            Text("上传图片\n" +
              "选择柄底\n" +
              "体验制作一颗徽章的过程").textAlign(TextAlign.Center)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
          }
        }
        .width(320)
        .backgroundColor('#80f5f5f5')
        .padding(30)
        .borderRadius(32)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
      }.padding({left:20,right:20})
    }

  }
}