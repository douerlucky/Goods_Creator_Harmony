import { font, Font, prompt, router} from '@kit.ArkUI';
import http from '@ohos.net.http';
import {AsyncCallback} from '@ohos.base';
import { badgeDisplay, Updated_Badge } from '../../class/Badge';
import { search_user_Badges } from '../../page_compolents/searchData';
import { change_statue, get_info, get_order_list } from '../../page_compolents/materializeKits';
import { orderlist_information } from '../../class/order_list';
import * as buttons from "../../page_compolents/buttons";
const scale_size = 0.9

@Entry
@Preview
@Component
struct materializePage {
  @StorageLink('uid') uid: string = '';
  @State refreshing:boolean = false
  @State order_infos:orderlist_information[] = []

  async aboutToAppear() {
    await this.refreshData()
  }

  build() {
    Stack() {
      Column() {
        // 最近订单部分
        Column() {
          Column() {
            buttons.back_button({ content: "最近订单" }).alignSelf(ItemAlign.Start).padding({bottom:20})
            Text("所有订单")
              .fontSize(28)
              .fontWeight(700)
              .margin({ bottom: 10 })
              .width('80%');
          }.width('100%')

          Refresh({
            refreshing: this.refreshing
          }) {
            Column() {

              Scroll() {
                Column({ space: 20 }) {

                  ForEach(this.order_infos, (item: orderlist_information) => {

                    Row() {
                      badgeDisplay({
                        scale_size: scale_size,
                        specification: item.badge_info.specification,
                        flash_bottom: item.badge_info.flash_bottom,
                        film_cover: item.badge_info.film_cover,
                        img_url: item.badge_info.img_url
                      }).offset({left:10})
                      Column({space:10}) {
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
                      }.justifyContent(FlexAlign.SpaceBetween)
                      .height('100%')

                      Column({space:10}) {
                        Text(`状态 ${(item.status == 0 ? "等待公司接单": item.status == 1 ? "等待发货": item.status == 2 ? "等待签收" : "订单完成")}`)
                          .fontSize(12)
                        Text(`付款 ￥${item.total_price}`)
                          .fontSize(16)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#FEAC59')
                        if(item.status == 2)
                        {
                          Button("确认收货")
                            .onClick(()=>{
                              change_statue(item.orderid,item.company_info.cid,3)
                              this.refreshData()
                            })

                        }
                        else
                        {
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
                  })
                }
              }.height('100%')
              .padding({left:10,right:10,bottom:50})
            }
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
