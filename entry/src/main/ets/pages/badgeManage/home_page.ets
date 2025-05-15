import { prompt, router} from '@kit.ArkUI'
import * as buttons from '../../page_compolents/buttons'
import { search_user_Badges } from '../../page_compolents/searchData'; // 假设此文件包含接口定义
import { badgeDisplay,Updated_Badge } from '../../class/Badge'; // 假设此文件包含接口定义
import { speechRecognizer } from '@kit.CoreSpeechKit';
import text from '@ohos.graphics.text';

const scale_size:number = 1.4


@Preview
@Component
struct home_page {
  @StorageLink('uid') uid:string = ''
  @State query_name:string = ''
  @State myBadge:Updated_Badge[] = []
  @State refreshing: boolean = false
  async aboutToAppear() {
    await this.refreshData();
  }

  async refreshData() {
    if (this.uid !== '') {
      this.myBadge = await search_user_Badges(this.uid, this.query_name)
    } else {
      prompt.showToast({ message: '还没有登录，请先登录' });
    }
  }

  build() {
    Stack(){
      Refresh({
        refreshing: this.refreshing
      }){

        Column()
        {
          // Button("debug room").onClick(()=>{
          //   router.pushUrl({
          //     url:"pages/Debug_pages/debug_room"
          //   })
          // })
          Search({placeholder:'搜索收藏'}).width('90%')
            .searchButton("搜索")
            .onChange(async (value:string)=>{
              this.query_name = value
            })
            .onSubmit(async ()=>{
              if(this.uid != '')
              {
                this.myBadge = await search_user_Badges(this.uid,this.query_name)
              }
              else
              {
                prompt.showToast({message:"还没有登录，请先登录"})
              }

            })
          Row({space : 15})
          {
            Text("我的收藏馆")
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
                  url: "pages/account_etc/user_info",
                })
              })

          }.width('100%')
          // 使用Grid布局主体内容
          if(this.myBadge.length==0)
          {
            Text("还没有徽章，请先创作吧")
              .width('100%')
              .height('100%')
              .fontSize(24).alignSelf(ItemAlign.Center)
              .textAlign(TextAlign.Center)
          }
          else
          {
            Grid() {
              ForEach(this.myBadge, (item: Updated_Badge) => {
                GridItem() {
                  Column({ space: 5 }){
                    Column() {
                      badgeDisplay({
                        scale_size:scale_size,
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
                    Text(item.title)
                  }.onClick(()=>{
                    router.pushUrl({
                      url:"pages/badgeManage/badgeDetails",
                      params: item // 添加params属性，传递自定义参数
                    })
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(10)
            .layoutWeight(1)
            .margin({ top: 20 })
          }
        }.padding({left:20,right:20})
        .width('100%')
        .height('100%')
      }.onRefreshing(async () => {
        this.refreshing = true;
        await this.refreshData();
        this.refreshing = false;
      })
    }


  }
}

export default home_page