import {router} from '@kit.ArkUI'
import * as buttons from '../../page_compolents/buttons'
import {createTempTask} from '../../page_compolents/badgeTask'
@Preview
@Component
struct Select_Creat {
  @StorageLink('uid') uid:string = ''
  @StorageLink('taskid') taskid:string = ''
  aboutToAppear(): void {
    this.taskid = ""
  }
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
        if(this.uid=='')
        {
          Button("请先登录再进行创作哦")
            .onClick(()=>{
              router.pushUrl({
                url:"pages/account_etc/Login_in"
              })
            })
        }
        else
        {
          buttons.big_button({title:"创作吧唧",
            desc:"上传图片\n选择柄底\n体验制作一颗徽章的乐趣" ,
            image_source:$r("app.media.create_budge_icon"),
          }).onClick(async ()=>{
            this.taskid = await createTempTask(parseInt(this.uid))
            router.pushUrl( {
              url:"pages/badgeCreate/choose_a_badge_specification"
            })
          })
        }

      }
      .padding({left:20,right:20})
    }

  }
}

export default Select_Creat