import * as buttons from "../../page_compolents/buttons"
import { router } from '@kit.ArkUI'
import Badge, { badgeDisplay } from '../../class/Badge'
import axios, { AxiosHeaders, AxiosResponse } from "@ohos/axios"
import * as server from '../../class/ServerKits'

const scale_size =3.5
@Entry
@Component
struct Complete {
  @StorageLink('badge_create') badge_create:Badge = { } as Badge
  @State title:string = ''
  @StorageLink('taskid') taskid:string = ''
  @StorageLink('uid') uid:string = ''


  build() {
    Stack() {
      Image($r("app.media.complete_back")).expandSafeArea()
      Column({ space: 20 }) {
        Column()
        {
        buttons.back_button({ content: "上一步" }).alignSelf(ItemAlign.Start).padding({bottom:20})
          Text("大功告成！")
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
        }.width('100%')

        Column()
        {
          badgeDisplay({
            scale_size:scale_size,
            specification:this.badge_create.specification,
            flash_bottom:this.badge_create.flash_bottom,
            film_cover:this.badge_create.film_cover,
            img_url:this.badge_create.modified_url
          }).height(300)
          TextInput({placeholder:"我的谷子_001"})
            .width('80%')
            .onChange((content:string)=>{
              this.title = content
            })
          }.width('100%')
        .height(400)


        // Row({space:10})
        // {
        //   buttons.short_function_button({
        //     text:"保存并分享",
        //     icon:$r('app.media.icon_download')
        //   })
        //   buttons.short_function_button({
        //     text:"上传到广场",
        //     icon:$r('app.media.icon_upload')
        //   })
        // }

        buttons.next_step_button()
          .onClick(async ()=>{

            await this.submitBadge()

            router.clear()
            router.pushUrl({ url: 'pages/Index' })

          })


      }.width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
    }

  }

  async submitBadge() {
    try {
      // 构建请求数据
      const data: Data = {
        taskid: this.taskid,
        uid: this.uid,
        creator_uid:this.uid,
        title: this.title || '我的谷子',
        specification: this.badge_create.specification,
        img_url: this.badge_create.modified_url,
        flash_bottom: this.badge_create.flash_bottom,
        fb_name: this.badge_create.fb_name,
        film_cover: this.badge_create.film_cover,
        fc_name: this.badge_create.fc_name,
        lid: this.badge_create.lid,         // ✅ 提交ID
        bgmid: this.badge_create.bgmid,     // ✅ 提交ID
        video_url: this.badge_create.video_url
      };


      // 发送POST请求
      const response: AxiosResponse<Response> = await axios.post(
        `${server.postBaseUrl}${server.databasePort}/api/db/update_badge`,
        data,
        { headers: headers }
      );

      if (response.status === 200 && response.data) {
        console.log('上传成功:', response.data);
        router.clear()
        // 清空Storage数据（可选）
        this.badge_create = new Badge();
        this.taskid = '';
      } else {
        throw new Error(response.data.message || '上传失败');
      }

    } catch (error) {
      console.error('上传失败:', error);
      // 显示Toast提示（需引入Toast模块）
    }
  }


}

interface Data {
  taskid: string
  uid: string
  creator_uid:string
  title: string
  specification: number
  img_url: string
  flash_bottom: string
  fb_name: string
  film_cover: string
  fc_name: string
  lid: number
  bgmid: number
  video_url: string
}

interface Headers{
  'Content-Type': 'application/json'
}
const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

interface Response {
  message: string;
  newBid: string;
  badge_url: string;
}