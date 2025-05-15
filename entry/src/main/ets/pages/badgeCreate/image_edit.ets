import * as buttons from "../../page_compolents/buttons"
import { router } from '@kit.ArkUI'
import Badge from '../../class/Badge'
import { sendAI_CutRequest, sendAI_StyleRequest, sendSuperResolutionRequest} from '../../page_compolents/badgeTask'

@Entry
@Component
struct Image_edit {
  @StorageLink('badge_create') badge_create:Badge = { } as Badge
  @State now_img:string = ""
  @StorageLink('taskid') taskid:string = ''
  @State isButtonenabled:boolean = true
  private refreshInterval: number | null = null;
  aboutToAppear(): void {
    // 启动定时刷新任务
    this.refreshInterval = setInterval(() => {
      this.refreshImage();
    }, 1000);
  }

  aboutToDisappear(): void {
    // 页面消失时清除定时任务
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  }

  private refreshImage() {
    let timestamp = new Date().getTime();
    this.now_img = `${this.badge_create.modified_url}?t=${timestamp}`;
  }

  onBackPress(): boolean {
    // 返回 true 表示拦截返回事件，阻止默认行为
    return true;
  }

  build() {

    Stack({alignContent:Alignment.TopStart}){
      Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column(){
        Column(){
          buttons.back_button({ content: "上一步" }).alignSelf(ItemAlign.Start).padding({bottom:20}) .opacity(this.isButtonenabled ? 1 : 0.3)
            .onClick(()=>{
              router.back()
              router.back()
            })
            .enabled(this.isButtonenabled)
          Text("图片处理")
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .padding({bottom:20})
        }.width('100%')

        Column(){
          Image(this.now_img)
            .borderRadius(16)
            .width(256)
            .aspectRatio(1)
        }.width('100%')
        .padding({bottom:40})
        Column({space:10}){
          buttons.long_function_button(
            {text:"AI自动抠图",
              icon:$r("app.media.ai_cut")})
            .enabled(this.isButtonenabled) .opacity(this.isButtonenabled ? 1 : 0.7)
            .onClick(async ()=>{
              this.isButtonenabled = false
              console.log("发送AI抠图请求")
              await sendAI_CutRequest(this.taskid)
              // 添加时间戳参数来绕过缓存
              const timestamp = new Date().getTime();
              this.now_img = `${this.now_img}?t=${timestamp}`;
              console.log(this.now_img)
              this.isButtonenabled = true
            })


          buttons.long_function_button(
            {text:"提高分辨率",
              icon:$r("app.media.icon_SC")})
            .enabled(this.isButtonenabled) .opacity(this.isButtonenabled ? 1 : 0.7)
            .onClick(async ()=>{
              this.isButtonenabled = false
              console.log("发送提高分辨率请求")
              await sendSuperResolutionRequest(this.taskid)
              // 添加时间戳参数来绕过缓存
              const timestamp = new Date().getTime();
              this.now_img = `${this.now_img}?t=${timestamp}`;
              console.log(this.now_img)
              this.isButtonenabled = true
            })
          buttons.long_function_button(
            {text:"风格化",
              icon:$r("app.media.icon_drop")}
          ).enabled(this.isButtonenabled) .opacity(this.isButtonenabled ? 1 : 0.7)
            .onClick(async ()=>{
              this.isButtonenabled = false
              console.log("发送AI抠图请求")
              await sendAI_StyleRequest(this.taskid)
              // 添加时间戳参数来绕过缓存
              const timestamp = new Date().getTime();
              this.now_img = `${this.now_img}?t=${timestamp}`;
              console.log(this.now_img)
              this.isButtonenabled = true
            })
        }

        .padding({bottom:10})

        buttons.confirm_button()
          .onClick(()=>{
            router.pushUrl({ url: 'pages/badgeCreate/crop_image' })
            let timestamp = new Date().getTime();
            this.now_img = `${this.now_img}?t=${timestamp}`;
          }).enabled(this.isButtonenabled)
          .opacity(this.isButtonenabled ? 1 : 0.3)
      }.width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({left:20,right:20})
    }
  }
}