import { router } from '@kit.ArkUI';
import { companyOrders } from './companyOrderInfo';

@Entry
@Component
struct CompanyPage {
  @StorageLink('cid') cid:string = ''

  build() {
    Column(){
      Row({space : 15})
      {
        Text("当前待处理的订单")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.more'))
          .width(10)
        Blank().width(60)
        //Image($r('app.media.add_folder'))
        //  .width(36)
        Image($r('app.media.user_info'))
          .width(45)
          .onClick(()=>{
            router.pushUrl({
              url: "pages/companyPages/companyInfo",
            })
          })

      }.width('100%')
      companyOrders().width('100%').height('100%')
    }.width('100%')
    .height('100%')
  }
}