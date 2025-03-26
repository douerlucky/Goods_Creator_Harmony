import { router } from '@kit.ArkUI'

@Preview
@Component
struct back_button {
  content:string = "返回"
  build() {
    Button()
    {
      Row()
      {
        Image($r("app.media.back")).width(12)
        Blank().width(10)
        Text(this.content).fontSize(20)
      }
    }
      .onClick(()=>{
      router.back()
    }).buttonStyle(ButtonStyleMode.TEXTUAL)
  }
}

@Preview
@Component
struct big_button {
  image_source: ResourceStr = ''
  title: string = '默认标题'
  desc: string = '默认描述'
  push_router_url: string = ''
  build()
  {
    Row({space:15})
    {
      Image(this.image_source)
        .width(96)
      Column()
      {
        Text(this.title)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
        Text(this.desc).textAlign(TextAlign.Center)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
      }
    }
    .width(320)
    .backgroundColor('#50f5f5f5')
    .padding(30)
    .borderRadius(32)
    .shadow(ShadowStyle.OUTER_DEFAULT_LG)
    .onClick(()=>{
      router.pushUrl({
        url:this.push_router_url
      })
    })
  }
}

@Component
struct confirm_button{
  build() {
    Button()
    {
      Row({space:20})
      {
        Image($r("app.media.complete"))
          .width(24)
        Text("确认")
          .fontColor(Color.White)
          .fontSize(20)
      }
    }.width(130)
    .height(50)
  }
}

@Component
struct next_step_button{
  push_router_url: string = ''
  build() {
    Button()
    {
      Row({space:20})
      {
        Text("下一步")
          .fontColor(Color.White)
          .fontSize(20)
      }
    }.width(130)
    .height(50)
    .onClick(()=>{
      router.pushUrl({
        url:this.push_router_url
      })
    })
  }
}

export { back_button,big_button,confirm_button,next_step_button}

