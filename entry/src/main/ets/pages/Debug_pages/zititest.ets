@Entry
@Component
struct TextTest {
  @State message: string = '中华人民共和国万岁';

  build() {
    RelativeContainer() {
      Column() {
        Text(this.message)
          .id('TextTestHelloWorld')
          .fontSize(33)
          .fontWeight(FontWeight.Bold)
          .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
      }
      .linearGradient({
        angle: 135,
        colors: [['#B65EBA', 0], ['#78F2E9', 1]]
      })
      .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
    }
    .height('100%')
    .width('100%')
  }
}