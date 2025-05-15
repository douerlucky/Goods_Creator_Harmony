import { router } from '@kit.ArkUI'

@Preview
@Component
struct back_button {
  content:string = "返回"
  isdouble:boolean = false
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
        if(this.isdouble)
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
  }
}

@Preview
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

@Preview
@Component
struct next_step_button{
  public state:boolean = true
  build() {
    Button()
    {
      Row({space:20})
      {
        Text("下一步")
          .fontColor(Color.White)
          .fontSize(20)
      }
    }
    .width(130)
    .height(50)
    .backgroundColor(this.state ? '' : Color.Gray)
  }
}

@Preview
@Component
struct short_function_button{
  text:string = '默认操作'
  icon: ResourceStr = ''
  build()
  {
    Button()
    {
      Row({space:5})
      {
        Image(this.icon)
          .width(16)
        Text(this.text)
          .fontSize(16)
      }
    }
      .width(130)
      .height(50)
      .backgroundColor('#f5f5f5')
      .opacity(0.75)
  }
}

@Preview
@Component
struct long_function_button{
  text:string = '默认操作'
  icon: ResourceStr = ''
  build()
  {
    Button()
    {
      Row({space:10})
      {
        Image(this.icon)
          .width(24)
        Text(this.text)
          .width('70%')
          .fontSize(16)
          .textAlign(TextAlign.Center)
      }
    }
    .width(260)
    .height(50)
    .backgroundColor('#f5f5f5')
    .opacity(0.75)
  }
}

@Preview
@Component
struct mini_button{
  text:string = '默认操作'
  icon: ResourceStr = ''
  build()
  {
    Button()
    {
      Column({space:5})
      {
        Image(this.icon)
          .width(24)
        Text(this.text)
          .width('70%')
          .fontSize(12)
          .textAlign(TextAlign.Center)
      }
    }
    .buttonStyle(ButtonStyleMode.TEXTUAL)
    .width(60)
    .height(60)
  }
}


export { back_button,big_button,confirm_button,next_step_button,short_function_button,long_function_button,mini_button}

