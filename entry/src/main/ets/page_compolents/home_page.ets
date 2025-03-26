import {router} from '@kit.ArkUI'
import * as buttons from '../page_compolents/buttons'
@Preview
@Component
struct home_page {

  build() {

      Column()
      {
        Button("debug room").onClick(()=>{
          router.pushUrl({
            url:"pages/Debug_pages/debug_room"
          })
        })
        Search({placeholder:'搜索收藏'}).width('80%')
          .searchButton("搜索")
        Row({space : 15})
        {
          Text("我的收藏馆")
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
          Image($r('app.media.more'))
            .width(10)
          Blank().width(60)
          Button("添加")
        }.width('100%')

      }.padding({left:20,right:20})
    .width('100%')
    .height('100%')
  }
}

export default home_page