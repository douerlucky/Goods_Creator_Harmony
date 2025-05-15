import { badgeDisplay,Updated_Badge } from '../../class/Badge'
import * as buttons from '../../page_compolents/buttons'
import { Font } from '@ohos.arkui.UIContext'
import { prompt, promptAction, router } from '@kit.ArkUI'
import { deleteBadge } from '../../page_compolents/deleteImage'
import { AVPlayerDemo } from "../../page_compolents/audio_play"
import axios, { AxiosHeaders, AxiosResponse } from "@ohos/axios"
import * as server from '../../class/ServerKits'

// 定义谷子信息接口
const scale_size:number = 3.5
let badge: Updated_Badge = router.getParams() as Updated_Badge; // 获取传递过来的参数对象

// interface GeneratedObjectLiteralInterface_1 {
//   bid: number;
//   specification: number;
//   title: string;
//   img_url: string;
//   flash_bottom: string;
//   film_cover: string;
//   lyric_url: string;
//   BGM_url: string;
//   video_url: string;
//   update_time: string;
// }
//
// let badge: Updated_Badge={
//   bid: 1,
//   specification:56,
//   title:'123',
//   img_url:'https://goods-creator-data.oss-cn-hangzhou.aliyuncs.com/images/badge_images/1_yll.png',
//   flash_bottom:'',
//   film_cover:'',
//   lyric_url:'',
//   BGM_url:'',
//   video_url:'',
//   update_time:''
//
// } as Updated_Badge

@Entry
@Component
struct MyGoodsPage {
  @StorageLink('uid') uid:string = ''
  @State private isMenuVisible: boolean = false;
  @State lyric_audio:AVPlayerDemo = new AVPlayerDemo
  @State bgm_audio:AVPlayerDemo = new AVPlayerDemo
  @State islyricPlay:boolean =  false
  @State isBGMPlay:boolean = false
  @State isVideoPlay:boolean = false
  private controller: VideoController = new VideoController()

  onPageHide() {
    // 页面隐藏时释放音频资源
    this.lyric_audio.release()
    this.bgm_audio.release()
  }

  // 显示确认删除对话框
  private showDeleteDialog() {
    const dialog: AlertDialogParamWithConfirm = {
      title: "确认删除",
      message: "您确定要删除此项吗？",
      confirm: {
        value: "确定",
        action: async () => {
          // 执行删除操作
          this.lyric_audio.release()
          this.bgm_audio.release()
          promptAction.showToast({ message: "已删除" });
          if(badge.creator_uid == badge.uid)
            await deleteBadge(badge.bid.toString(),this.uid,0 )
          else
            await deleteBadge(badge.bid.toString(),this.uid,1 )

          router.clear()
          router.pushUrl({url: "pages/Index"})
          router.clear()
        }
      },
      cancel: () => {
        // 取消删除操作
        promptAction.showToast({ message: "已取消删除" });
      }
    };
    AlertDialog.show(dialog);
  }
  @State isShow_moreinfo: boolean = false
  @Builder more_info() {
    more_info({
      badge_info: badge, // 使用 @Link 传递状态
      isShow: $isShow_moreinfo // 使用 @Link 传递状态
    })
  }

  @State isShow_Edit: boolean = false
  @Builder edit() {
    edit({
      badge_info: badge, // 使用 @Link 传递状态
      isShow: $isShow_Edit // 使用 @Link 传递状态
    })
  }

  build() {
    Stack(){
      Image($r('app.media.badgeDetail'))
        .expandSafeArea()
      Column(){
        Column()
        {
          Row() {
            buttons.back_button()
              .layoutWeight(1)
            Text(badge.title)
              .width('100%')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .layoutWeight(3)
            Blank().layoutWeight(1)
          }
          .width('90%')
          .height(50)
          .borderRadius(32)
          .shadow(ShadowStyle.OUTER_DEFAULT_MD)
          .backgroundColor('#99f5f5f5')
          .padding({left:10})

        }


        Column() {

          Stack()
          {
            if(badge.img_url=='')
            {
              Text("徽章无法正常显示，可能是作者已将其删除，请点击删除徽章").fontSize(24)
            }
            badgeDisplay({
              scale_size:scale_size,
              specification:badge.specification,
              flash_bottom:badge.flash_bottom,
              film_cover:badge.film_cover,
              img_url:badge.img_url
            }).onClick(()=>{
              if(badge.lyric_url)
              {
                  this.lyric_audio.setPlayUrl(badge.lyric_url)
              }
              if(badge.video_url && (this.isVideoPlay == false))
              {
                this.controller.start()
                this.isVideoPlay = true
              }
            })
            if(badge.video_url && this.isVideoPlay)
            {
              Video({src:badge.video_url,controller: this.controller,previewUri:badge.img_url})
                .controls(false) // 设置是否显示默认控制条
                .autoPlay(true) // 设置是否自动播放
                .onFinish(()=>{
                  this.controller.setCurrentTime(0)
                  this.isVideoPlay = false
                })
                .size({ width: badge.specification * scale_size, height: badge.specification * scale_size })
                .clipShape(new Circle({
                  width: badge.specification * scale_size,
                  height: badge.specification * scale_size
                }))
              Image($r(badge.film_cover))
                .size({ width: badge.specification * scale_size, height: scale_size * scale_size })
                .clipShape(new Circle({
                  width: badge.specification * scale_size,
                  height: badge.specification * scale_size
                }))
                .aspectRatio(1)
                .opacity(1) // 50% 透明度，可根据效果调整
                .blendMode(BlendMode.DARKEN) // 混合模式（可选：Screen、Overlay 等）
                .draggable(false)

            }
          }


        }
        .width('100%')
        .margin({ top:25,bottom:25 })
        Row(){
          if(this.uid == badge.uid.toString()) {
            //buttons.mini_button({icon:$r('app.media.ic_public_download'),text:"下载"}) //暂未实现保存到相册
          }
          else
            buttons.mini_button({icon:$r('app.media.ic_public_add_norm'),text:"添加"})
              .onClick(async ()=>{
                await this.addMyGallery()
              })
          if(this.uid == badge.uid.toString())
          buttons.mini_button({icon:$r('app.media.ic_public_edit'),text:"编辑"})
            .onClick(() => {
              this.isShow_Edit = true
            })
            .bindSheet($$this.isShow_Edit, this.edit(), {
              detents: [SheetSize.MEDIUM, SheetSize.LARGE, 350],
              title: { title: "编辑" }
            })
          buttons.mini_button({icon:$r('app.media.ic_public_more'),text:"详情"})
            .onClick(() => {
              this.isShow_moreinfo = true
            })
            .bindSheet($$this.isShow_moreinfo, this.more_info(), {
              detents: [SheetSize.MEDIUM, SheetSize.LARGE, 350],
              title: { title: "徽章信息" }
            })
          if(this.uid == badge.creator_uid.toString() || badge.isPublic == 3)
          {
            buttons.mini_button({icon:$r('app.media.delete'),text:"删除"})
              .bindMenu([
                {
                  value: "确认删除",
                  action: () => {
                    this.showDeleteDialog();
                  }
                }
              ])
          }

        }.width('80%')
        .height(60)
        .backgroundColor('#99f5f5f5')
        .borderRadius(32)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
        .justifyContent(FlexAlign.SpaceEvenly)
      }.height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({space:10})
      {
        if(badge.lyric_url)
         Image($r("app.media.icon_dialog")).size({width:20,height:20})
        if(badge.BGM_url)
          Image($r("app.media.icon_bgm")).size({width:20,height:20})
        if(badge.video_url)
          Image($r("app.media.icon_dynamic")).size({width:20,height:20})
      }.offset({y:-290})
      .borderRadius(32)
      .backgroundColor('#66f5f5f5')
      .padding(10)
      .shadow(ShadowStyle.OUTER_DEFAULT_MD)
      if(badge.BGM_url)
      {
        Button()
        {Row({space:5}){
          Image($r("app.media.identify_song")).size({width:20,height:20})
          if(!this.isBGMPlay)
            Text("播放背景音乐")
              .fontColor( Color.White)
          else
            Text("暂停背景音乐")
              .fontColor( Color.White)
        }}
        .padding(5)
        .onClick(()=>{
          if(this.isBGMPlay)
          {
            this.bgm_audio.togglePlayPause()
            this.isBGMPlay = !this.isBGMPlay
          }
          else
          {
            this.bgm_audio.setPlayUrl(badge.BGM_url)
            this.isBGMPlay = !this.isBGMPlay
          }

        }).offset({y:250})
        .borderRadius(32)
        .padding({left:20,right:20,top:10,bottom:10})
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
      }
    }
    }

  async addMyGallery()
    {
    try {
      // 构建请求数据
      const data: addBadgeData = {
        uid:parseInt(this.uid),
        bid:badge.bid
      };


    // 发送POST请求
    const response: AxiosResponse<Response> = await axios.post(
      `${server.postBaseUrl}${server.databasePort}/api/db/add_badge`,
      data,
      { headers: headers }
    );

    if (response.status === 200 && response.data) {
      console.log('添加成功:', response.data);
      prompt.showToast({ message: '添加成功' });
    } else {
      throw new Error(response.data.message || '添加失败');

    }

  } catch (error) {
    prompt.showToast({ message: '添加失败' });
    console.error('添加失败:', error);
    // 显示Toast提示（需引入Toast模块）
  }
}
}

interface addBadgeData
{
  uid:number
  bid:number
};

class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 10
  color: ResourceColor = '#ffe9f0f0'

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}


@Component
struct more_info {
  @State egDivider: DividerTmp = new DividerTmp(1, 60, 10, '#ffe9f0f0')
  @Prop badge_info: Updated_Badge; // 使用 @Link 接收父组件的状态
  @Link isShow: boolean; // 使用 @Link 接收父组件的状态
  @Builder itemHead(text: string) {
    // 列表分组的头部组件，对应联系人分组A、B等位置的组件
    Text(text)
      .fontSize(20)
      .backgroundColor('#fff1f3f5')
      .width('100%')
      .padding(5)
  }
  build() {
    List() {
      ListItemGroup({ header: this.itemHead('基本信息') }){
        ListItem(){
          Column({space:5}){
            infos({title:"徽章ID",content:this.badge_info.bid.toString()})
            infos({title:"制作人ID",content:this.badge_info.creator_uid.toString()})
            infos({title:"制作人昵称",content:this.badge_info.creator_username})
            infos({title:"规格",content:`${this.badge_info.specification.toString()} mm`})
            infos({title:"名称",content:this.badge_info.title})
            infos({title:"上传时间",content:this.badge_info.update_time.slice(0,-5)})
            infos({title:"是否公开",content:this.badge_info.isPublic ? "公开":"私密"})
          }
        }
      }
      ListItemGroup({ header: this.itemHead('高级信息') }){
        ListItem(){
          Column({space:5}){
            infos({title:"闪底名称",content:this.badge_info.fb_name})
            infos({title:"覆膜名称",content:this.badge_info.fc_name})
            infos({title:"台词名称",content:this.badge_info.lyric_name})
            infos({title:"背景音乐名称",content:this.badge_info.BGM_name})
            infos({title:"是否为动态徽章",content:(this.badge_info.video_url ? "是" : "否")})
          }
        }
      }
    }
    .width('90%')
    .divider(this.egDivider)
    .scrollBar(BarState.Auto)
    }
}

@Component
struct infos{
  public title:string = ''
  public content:string = ''
  build() {
    Row()
    {
      Text(this.title).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center).width('50%')
      Text(this.content).textAlign(TextAlign.Center).width('50%')
    }
    .backgroundColor(Color.White)
    .height(30)
    .width('100%')
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}


@Component
struct edit {
  @Prop badge_info: Updated_Badge; // 使用 @Link 接收父组件的状态
  @Link isShow: boolean; // 使用 @Link 接收父组件的状态
  @State mod_title: string = this.badge_info.title
  @State mod_public: number = this.badge_info.isPublic
  build() {
    Column({space:20}){
      Column({space:10})
      {
        Text("修改徽章名称").fontSize(18).width('100%')
        TextInput({placeholder:this.badge_info.title}).onChange((content:string)=>{this.mod_title = content})

      }.width('80%')


      //Text(`isPublic${badge.isPublic}`)
      if(badge.isPublic != 3)
      {
        Row({space:10})
        {
          Text("公开到广场").fontSize(18)
          Toggle({type:ToggleType.Switch,isOn:(this.badge_info.isPublic) ? true:false})
            .selectedColor('#007DFF')
            .switchPointColor('#FFFFFF')
            .onChange((isOn:boolean)=>{ this.mod_public = (isOn ? 1:0)
            }).size({width:48,height:24})
        }.width('80%')
      }
      Blank().height(50)

      buttons.confirm_button()
        .onClick(async ()=>{
          this.badge_info.title = this.mod_title
          this.isShow = false
          this.badge_info.isPublic = this.mod_public
          await this.submitChange()
          router.clear()
          router.pushUrl({ url: 'pages/Index' })
        })
    }
  }

  async submitChange() {
    try {
      // 构建请求数据
      const data: Data = {
        bid:this.badge_info.bid,
        new_title:this.mod_title,
        new_public:(this.mod_public ? 1:0)
      };


      // 发送POST请求
      const response: AxiosResponse<Response> = await axios.post(
        `${server.postBaseUrl}${server.databasePort}/api/db/modify_badge`,
        data,
        { headers: headers }
      );

      if (response.status === 200 && response.data) {
        console.log('修改成功:', response.data);
        prompt.showToast({ message: '修改成功' });
      } else {
        throw new Error(response.data.message || '修改失败');

      }

    } catch (error) {
      prompt.showToast({ message: '修改失败' });
      console.error('修改失败:', error);
      // 显示Toast提示（需引入Toast模块）
    }
  }
}

interface Data{
  bid:number
  new_title:string
  new_public:number
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

