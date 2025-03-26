interface OrderItem {
  orderNumber: string;
  status: string;
  productName: string;
  productSpec: string;
  price: string;
  imageUrl:string;
  canApplyAfterSale: boolean;
  canConfirmReceipt: boolean;
}
@Entry
@Component
struct dd{
  @State orderData: OrderItem[] = [
    {
      orderNumber: '123456712312',
      status: '工厂正在制作中',
      productName: '波奇喝水',
      productSpec: '75mm 无闪底 无覆膜 x1',
      price: '5.6',
      imageUrl: 'app.media.t011571d167e97e17b6', // 替换为实际图片地址
      canApplyAfterSale: true,
      canConfirmReceipt: false
    },
    {
      orderNumber: '1234566',
      status: '正在运输',
      productName: '表情包',
      productSpec: '58mm 无闪底 无覆膜 x1',
      price: '3.8',
      imageUrl: 'app.media.t04379269478a726702',
      canApplyAfterSale: true,
      canConfirmReceipt: true
    },
    {
      orderNumber: '1234565',
      status: '已签收完成',
      productName: '好耶',
      productSpec: '75mm 无闪底 无覆膜 x1',
      price: '5.6',
      imageUrl: 'app.media.t013632568a645029ad',
      canApplyAfterSale: true,
      canConfirmReceipt: false
    }
  ];

  build() {
    Column({ space: 16 }) {
      // 标题栏
      Row() {
        Image($r('app.media.startIcon'))// 返回箭头图标，需准备资源
          .size({ width: 20, height: 20 })
          .fillColor(' #007AFF')
          .margin({ left: 16 })
        Text('实物化')
          .fontSize(16)
          .fontWeight(500)
          .fontColor(' #007AFF')
          .margin({ left: 16 })
      }.width('90%')
      .margin({ bottom: 20 })
      //搜索栏
      Row() {
        TextInput({ 'placeholder': '输入文本内容', 'text': '' })
          .height(50)
          .backgroundColor('#EAEAEB')
      }.width('90%')
      .justifyContent(FlexAlign.Center)

      ForEach(this.orderData, (item: OrderItem,index:number) => {
        Column() {
          Row({ space: 12}) {
            Column() {
              Text(`订单号:${item.orderNumber}`)
                .fontSize(8)
                .width(100)
              Image($r(item.imageUrl))
                .width(80)
                .height(80)
                .borderRadius(40)
            }.width('30%')

            Column(){
              Text(item.productName)
                .fontSize(16).fontWeight(800)
              Text(item.productSpec)
                .fontSize(12).margin({ top: 10 }).opacity(0.6)
              Text(`¥${item.price}`)
                .fontSize(20)
                .margin({top:10})
            }
            .width('40%')
            Column() {
              Text(item.status)
                .fontSize(12)
                .fontColor('#FF9900')

              Button('申请售后')
                .margin({ top: 10 })
                .width(80)
                .height(30)

              if (item.status === '正在运输') {
                Button('确认收货')
                  .margin({ top: 10 })
                  .width(80)
                  .height(30)
              }
            }.width('35%')
            .height('100%')
            .alignItems(HorizontalAlign.End)

          }
          .width('90%')
        }
        .backgroundColor('#FFFFFF')
        .width('90%')
        .height('15%')
        .margin({bottom:10})
      })
    }
    .backgroundColor('#FAFAFA')
  }
}