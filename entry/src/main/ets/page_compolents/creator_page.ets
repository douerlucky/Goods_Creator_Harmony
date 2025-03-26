import {router} from '@kit.ArkUI'
import * as buttons from '../page_compolents/buttons'
@Preview
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
        buttons.big_button({title:"创作吧唧",
          desc:"上传图片\n选择柄底\n体验制作一颗徽章的乐趣" ,
        image_source:$r("app.media.create_budge_icon"),
          push_router_url:"pages/Budget_Create_pages/choose_a_budget_specification"
        })
      }
      .padding({left:20,right:20})
    }

  }
}

export default Select_Creat