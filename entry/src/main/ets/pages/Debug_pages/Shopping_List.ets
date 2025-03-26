interface GoodsList{
  id: number,
  name: string,
  spec: string,
  price: number,
  count: number,
  image: Resource
}
@Entry
@Component
struct OrderPage {
  // 定义购物车商品数据（带状态管理）
  @State cartItems: Array<GoodsList> = [
    {
      id: 1,
      name: '海灵绘梦',
      spec: '58mm 无闪底 无覆膜',
      price: 39,
      count: 1,
      image: $r('app.media.Akie_Dream')
    },
    {
      id: 2,
      name: '确认徽章',
      spec: '标准规格',
      price: 29,
      count: 1,
      image: $r('app.media.Akie_Dream')
    }
  ];

  // 计算总价
  get totalPrice(): number {
    return this.cartItems.reduce((sum, item) => sum + (item.count * item.price), 0) + 3;
  }

  build() {
    Column({ space: 10 }) {
      // 最近订单部分
      Text('最近订单')
        .fontSize(28)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20 })

      // 订单示例
      Row({ space: 10 }) {
        Image($r('app.media.light_silver'))
          .width(60)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius(30)

        Column({ space: 5 }) {
          Text('商品名').fontSize(20).fontWeight(FontWeight.Medium)
          Text('商品规格').fontSize(16).fontColor('#666666')
          Text('数量: 1').fontSize(16).fontColor('#666666')
          Text('订单号: 20230317001').fontSize(16).fontColor('#666666')
          Text('状态: 已发货').fontSize(16).fontColor('#007DFF')
        }
      }
      .backgroundColor('#F5F5F5')
      .padding(20)
      .borderRadius(10)
      .margin({ top: 10 })

      Button('查看所有最近订单')
        .width('40%')
        .height(45)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .margin({ top: 10 })
        .borderRadius(8)

      // 购物车部分
      Text('购物车')
        .fontSize(28)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20 })

      List({ space: 10 }) {
        ForEach(this.cartItems, (item:GoodsList, index) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(item.image)
                .width(60)
                .height(60)
                .objectFit(ImageFit.Cover)
                .borderRadius(30)

              Column({ space: 5 }) {
                Text(item.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)

                Text(item.spec)
                  .fontSize(16)
                  .fontColor('#666666')

                Row({ space: 5 }) {
                  Text(`${item.count}`)
                    .fontSize(16)

                  Button('-')
                    .size({ width: 25, height: 25 })
                    .backgroundColor('#E0E0E0')
                    .fontColor('#666666')
                    .borderRadius(4)
                    .onClick(() => {
                      if (item.count > 1) {
                        this.cartItems[index].count--;
                      }
                    })

                  Button('+')
                    .size({ width: 25, height: 25 })
                    .backgroundColor('#E0E0E0')
                    .fontColor('#666666')
                    .borderRadius(4)
                    .onClick(() => {
                      this.cartItems[index].count++;
                    })
                }

                Text(`￥${item.count * item.price}`)
                  .fontSize(18)
                  .fontColor('#FF9900')
              }
            }
          }
        })
      }
      .margin({ top: 10 })
      .layoutWeight(1)

      // 底部操作栏
      Button('添加需要实物化的徽章')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 10 })

      Row({ space: 10 }) {
        Text(`总价 ￥${this.totalPrice}`)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FF9900')

        Button('结算')
          .size({ width: 100, height: 40 })
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
      }
      .margin({ top: 10, bottom: 20 })

      Text(`包含邮费￥3 已选${this.cartItems.length}项`)
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }
}