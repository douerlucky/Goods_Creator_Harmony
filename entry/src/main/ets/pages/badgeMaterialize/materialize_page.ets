import { font, Font, prompt, router} from '@kit.ArkUI';
import http from '@ohos.net.http';
import {AsyncCallback} from '@ohos.base';
import { badgeDisplay, Updated_Badge } from '../../class/Badge';
import { search_user_Badges } from '../../page_compolents/searchData';
import { change_statue, get_info, get_order_list } from '../../page_compolents/materializeKits';
import { orderlist_information } from '../../class/order_list';

const scale_size = 1

@Entry
@Preview
@Component
struct materializePage {
  @StorageLink('uid') uid: string = '';
  @State hasNewMessage: boolean = true; // 新增消息状态变量，假设存在新消息
  @State totalPrice: number = 0; // 新增总价状态变量
  @State isShow_addMaterialize: boolean = false
  @State refreshing:boolean = false
  @State order_infos:orderlist_information[] = []
  @Builder addMaterialize() {
    addMaterialize({
      isShow: $isShow_addMaterialize // 使用 @Link 传递状态
    })
  }

  async aboutToAppear() {
    await this.refreshData()
  }

  build() {
    Stack() {
      Column() {
        // 最近订单部分
        Column() {
          Row() {
            Text("最近订单")
              .fontSize(28)
              .fontWeight(700)
              .margin({ bottom: 10 })
              .width('80%');
          }.width('100%')

          Refresh({
            refreshing: this.refreshing
          }) {
              Scroll() {
                Column()
                {

                  Column({ space: 20 }) {

                    ForEach(this.order_infos, (item: orderlist_information) => {
                      if (item.status != 3) {
                        Row() {
                          badgeDisplay({
                            scale_size: scale_size,
                            specification: item.badge_info.specification,
                            flash_bottom: item.badge_info.flash_bottom,
                            film_cover: item.badge_info.film_cover,
                            img_url: item.badge_info.img_url
                          })
                            .offset({ left: 10 })
                          Column({ space: 10 }) {
                            Text(item.badge_info.title)
                              .fontSize(20)
                              .fontWeight(FontWeight.Bold)
                            Row() {
                              Text(`${item.badge_info.specification}mm ${item.badge_info.fb_name} ${item.badge_info.fc_name}`)
                                .fontSize(10)
                            }
                            .padding(5)
                            .backgroundColor('#b3c8c8c8')
                            .borderRadius(16)

                            Text(`数量:${item.quantity}`)
                          }.justifyContent(FlexAlign.SpaceAround)
                          .height('100%')

                          Column({ space: 10 }) {
                            Text(`状态 ${(item.status == 0 ? "等待公司接单" :
                              item.status == 1 ? "等待发货" : item.status == 2 ? "等待签收" : "订单完成")}`)
                              .fontSize(12)
                            Text(`付款 ￥${item.total_price}`)
                              .fontSize(16)
                              .fontWeight(FontWeight.Bold)
                              .fontColor('#FEAC59')
                            if (item.status == 2) {
                              Button("确认收货")
                                .onClick(() => {
                                  change_statue(item.orderid, item.company_info.cid, 3)
                                  this.refreshData()
                                })

                            } else {
                              Blank()
                            }

                          }.justifyContent(FlexAlign.SpaceBetween)
                          .height('100%')
                        }
                        .justifyContent(FlexAlign.SpaceBetween)
                        .width('100%')
                        .padding(10)
                        .height(150)
                        .borderRadius(32)
                        .backgroundColor('#80f5f5f5')
                        .shadow(ShadowStyle.OUTER_DEFAULT_SM)
                        .margin(10)
                      }


                    })
                  }



                  // 查看所有订单按钮
                  Button("查看所有订单")
                    .width('100%')
                    .height(40)
                    .backgroundColor('#007AFF')
                    .borderRadius(32)
                    .onClick(() => {
                      router.pushUrl({
                        url: "pages/badgeMaterialize/allOrders"
                      })
                    })


                  // 购物车部分
                  Column() {
                    // 购物车标题
                    Column() {
                      Button({
                        type: ButtonType.Circle,
                        stateEffect: true
                      }) {
                        Text('+')
                          .fontSize(30)
                          .fontWeight(500)
                          .fontColor(Color.Gray)
                      }
                      .width(80)
                      .height(80)
                      .backgroundColor('#80f5f5f5')
                      .borderRadius(40)
                      .shadow({
                        radius: 2,
                        color: Color.Gray,
                        offsetX: 1,
                        offsetY: 1
                      })
                      .margin({ bottom: 10, top: 10 })
                      .bindSheet($$this.isShow_addMaterialize, this.addMaterialize(), {
                        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 350],
                        title: { title: "选择要实物化的徽章" }
                      })
                      .onClick(() => {
                        this.isShow_addMaterialize = true
                      })

                      Text("选择实物化的徽章")
                        .fontSize(14)
                        .opacity(0.5)


                    }.justifyContent(FlexAlign.Center)
                  }
                }
              }.height('100%')
              .padding({bottom:50})

          }.onRefreshing(async () => {
            this.refreshing = true;
            await this.refreshData();
            this.refreshing = false;
          })
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
    }
  }
  async refreshData() {
    if (this.uid !== '') {
      this.order_infos = await get_order_list(this.uid,0) as orderlist_information[]
    } else {
      prompt.showToast({ message: '还没有登录，请先登录' });
    }
  }
}

export default materializePage;

@Component
struct addMaterialize{
  dialogController: CustomDialogController = new CustomDialogController({
    builder: BadgeInfoDialog({
      badge_info: undefined
    })
  })

  scale_size:number = 1.3
  async aboutToAppear() {
    await this.refreshData();
  }
  @Link isShow:boolean
  @State refreshing: boolean = false
  @StorageLink('uid') uid: string = '';
  @State index:number = -1
  @State myBadge:Updated_Badge[] = []

  build() {
    Row()
    {
      Refresh({
        refreshing: this.refreshing
      }){
        Scroll(){
          Grid() {
            ForEach(this.myBadge, (item: Updated_Badge,index:number) => {
              GridItem() {
                Column({ space: 5 }){
                  Column() {
                    badgeDisplay({
                      scale_size:this.scale_size,
                      specification:item.specification,
                      flash_bottom:item.flash_bottom,
                      film_cover:item.film_cover,
                      img_url:item.img_url
                    })
                  }
                  .size({ width: 140, height: 140 })
                  .borderRadius(32)
                  .backgroundColor('#66f5f5f5')
                  .shadow(ShadowStyle.OUTER_DEFAULT_XS)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.index = index

                    const badge = this.myBadge[index]
                    this.dialogController = new CustomDialogController({
                      builder: BadgeInfoDialog({
                        badge_info: badge
                      })
                    })

                    this.dialogController.open()
                  })

                  Text(item.title)
                }
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(10)
          .layoutWeight(1)
          .margin({ top: 20 })
        }.height('100%')
    }.onRefreshing(async () => {
        this.refreshing = true;
        await this.refreshData();
        this.refreshing = false;
      })
    }
    .height('100%')
    .width('100%')
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  async refreshData() {
    if (this.uid !== '') {
      this.myBadge = await search_user_Badges(this.uid, '')
    } else {
      prompt.showToast({ message: '还没有登录，请先登录' });
    }
  }
}

@CustomDialog
struct BadgeInfoDialog {
  @StorageLink('uid') uid: string = '';
  scale_size=2
  @Prop badge_info:Updated_Badge
  @State quantity:number = 1
  @State unit_price:number = 1
  @State total_prices:number = this.quantity * this.unit_price
  controller: CustomDialogController = new CustomDialogController({ builder: null })

  aboutToAppear(): void {
    const per_mm_price = 0.06429
    this.unit_price= parseFloat((per_mm_price * this.badge_info.specification).toFixed(2))
    this.total_prices = parseFloat((this.unit_price * this.quantity).toFixed(2))
  }

  build() {
    Column({ space: 10 }) {
      Text("确认徽章和规格")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      Column({space:10}) {
        badgeDisplay({
          scale_size:this.scale_size,
          specification:this.badge_info.specification,
          flash_bottom:this.badge_info.flash_bottom,
          film_cover:this.badge_info.film_cover,
          img_url:this.badge_info.img_url
        })
      }
      Column({space:5}){
        Text(`徽章ID：${this.badge_info.bid}`)
          .fontSize(16)
          .width('100%')
        Text(`徽章名称：${this.badge_info.title}`)
          .fontSize(16)
          .width('100%')
        Text(`徽章制作者名：${this.badge_info.creator_username}`)
          .fontSize(16)
          .width('100%')
        Text(`规格：${this.badge_info.specification}mm`)
          .fontSize(16)
          .width('100%')
        Text(`闪底：${this.badge_info.fb_name}`)
          .fontSize(16)
          .width('100%')
        Text(`覆膜：${this.badge_info.fc_name}`)
          .fontSize(16)
          .width('100%')
      }.width('80%')

      Row({space:10})
      {
        Text("实物化数量")
          .fontSize(16)
        Button("-")
          .onClick(()=>{
            if(this.quantity==1)
            {
              prompt.showToast({message:"徽章实物化数量必须大于1"})
            }
            else
              this.quantity--
            this.total_prices = this.quantity * this.unit_price
          })
        Text(this.quantity.toString())
        Button("+")
          .onClick(()=>{
            if(this.quantity==99)
            {
              prompt.showToast({message:"徽章实物化数量太多啦"})
            }
            else
              this.quantity++
            this.total_prices = this.quantity * this.unit_price
          })
      }
      Column({space:15})
      {
        Text(`单价 ￥${parseFloat(this.unit_price.toFixed(1))}`)
        Text(`总价 ￥${parseFloat(this.total_prices.toFixed(1))}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FEAC59')
      }.width('80%')


      Row({ space: 20 }) {
        Button("关闭")
          .onClick(() => {
            if (this.controller) this.controller.close()
          })
          .backgroundColor('#eeeeee')
          .fontColor(Color.Black)
        Button("确认并下单")
          .onClick(() => {
            if (this.controller) this.controller.close()
            get_info(this.badge_info.bid.toString(),this.uid,this.quantity,this.total_prices)
          })
          .fontColor(Color.White)
      }
    }.height(600)
    .justifyContent(FlexAlign.Center)
  }
}
