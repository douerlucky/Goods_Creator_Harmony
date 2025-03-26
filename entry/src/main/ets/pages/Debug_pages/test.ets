@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        alignItems: ItemAlign.Center
      }) {
        Image($r('app.media.cover'))
          .width(60)
          .height(60)
          .borderRadius(15)
        Column() {
          Text('致川流的无名诗')
            .fontSize(16)
          Text('Akie秋绘')
            .fontSize(10)
        }
        .margin({ left: 10, right: 10 })
        Image($r('app.media.control'))
          .height(20)
      }
      .backgroundColor(Color.Gray)
      .padding(10)
      .borderRadius(15)
    }
    .width('90%')
    .height(100)
    .margin(20)
  }
}