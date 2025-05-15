//hyj模版
import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import * as buttons from '../../page_compolents/buttons'
import prompt from '@system.prompt';
import { router } from '@kit.ArkUI';
import * as server from '../../class/ServerKits';

interface UserInfo {
  profile: string; //头像
  username: string;
  userId: string;
  coin: number;
}

interface Data{
  uid:string
}

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

@Entry
@Component
struct user_info {

  @StorageLink('uid') uid:string = ''
  @State userInfo: UserInfo = {
    profile: '', // 替换为实际头像路径
    username: '未登录',
    userId: '',
    coin: 0
  };
  aboutToAppear() {
    this.get_info();
  }

  build() {
    Column() {
      Row() {
        buttons.back_button({content:"收藏馆"})
      }.width('90%')
      .margin({ bottom: 20 })


      Row() {
        Image(this.userInfo.profile == '' ? $r('app.media.default_profile') : this.userInfo.profile)
          .width(70)
          .height(70)
          .borderRadius(40)
          .onClick(()=>{
            if(this.uid == '')
            {
              router.pushUrl({
                url: "pages/account_etc/Login_in",
              })
            }
          })

        Column({space:5}) {
          // UID
          if(this.uid != '')
          {
            Text(this.userInfo.username)
            .fontSize(18)
            .fontWeight(500)

            Text(`UID:${this.userInfo.userId}`)
              .fontSize(14)
              .fontColor('#666666')
            // 谷币
            Row() {
              Image($r('app.media.good_coin'))// 准备金币图标资源
                .width(20)
              Text(`${this.userInfo.coin} 谷币`)
                .fontSize(14)
                .margin({ left: 4 })
            }
            .backgroundColor('#FFC147')
            .padding({
              left: 8,
              right: 8,
              top: 2,
              bottom: 2
            })
            .borderRadius(12)
          }
          else {
            Text("未登录")
              .fontSize(18)
              .fontWeight(500)
              .onClick(()=>{
                if(this.uid == '')
                {
                  router.pushUrl({
                    url: "pages/account_etc/Login_in",
                  })
                }
              })
          }
        }

        Column({space:10}) {
          // 账号设置按钮
            if(this.uid!='')
            {
              Button('账号设置')
                .width(80)
                .height(40)
                .fontSize(12)
                .borderRadius(20)
                .backgroundColor('#FFFF')
                .fontColor(Color.Black)
                .height(30)
                .onClick(()=>{
                  router.pushUrl({
                    url: "pages/account_etc/user_info_edit",
                  })
                })
              Button('退出登录')
                .buttonStyle(ButtonStyleMode.TEXTUAL)
                .backgroundColor('#FFFF')
                .fontColor(Color.Red)
                .fontSize(12)
                .height(30)
                .onClick(()=>{
                  this.exit()
                  router.clear()
                  router.pushUrl({
                    url:"pages/Index"
                  })
                  router.clear()
                })
            }
        }

      }.width('90%')
      .height('15%')
      .backgroundColor('#f5f5f5')
      .borderRadius(20)
      .justifyContent(FlexAlign.SpaceAround)


     if(this.uid == '')
     {
       Blank().height(20)
        Image($r("app.media.Akie_Hello"))
          .width(128)
       Text("快来登录吧!")


     }
     else {
       // Row() {
       //   Text('所有素材')
       //     .fontSize(16)
       //     .padding({ left: 16, top: 12, bottom: 12 })
       // }
       // .margin({ top: 8 ,bottom:10})
       // .backgroundColor('#f5f5f5')
       // .width('90%')
       // .borderRadius(20)

       // 历史浏览
       // Row() {
       //   Text('历史浏览')
       //     .fontSize(16)
       //     .padding({ left: 16, top: 12, bottom: 12 })
       //   Blank()
       //   Image($r('app.media.history_view'))// 日历图标
       //     .size({ width: 20, height: 20 })
       //     .margin({ right: 16 })
       //
       // }
       // .margin({ top: 4 })
       // .backgroundColor('#f5f5f5')
       // .width('90%')
       // .borderRadius(20)

       // 所有收藏
       // Row(){
       //   Text('所有收藏')
       //     .fontSize(16)
       //     .padding({ left: 16, top: 12, bottom: 12 })
       //   Blank()
       //   Image($r('app.media.all_favor'))// 日历图标
       //     .size({ width: 20, height: 20 })
       //     .margin({ right: 16 })
       // }
       // .margin({ top: 4 })
       // .backgroundColor('#f5f5f5')
       // .width('90%')
       // .borderRadius(20)

       // 所有发布的作品
       // Row(){
       //   Text('所有发布的作品')
       //     .fontSize(16)
       //     .padding({ left: 16, top: 12, bottom: 12 })
       //   Blank()
       //   Image($r('app.media.all_works')) // 日历图标
       //     .size({ width: 20, height: 20 })
       //     .margin({ right: 16 })
       // }
       // .margin({ top: 4 })
       // .backgroundColor('#f5f5f5')
       // .width('90%')
       // .borderRadius(20)
     }

      // Text('关于谷创...')
      //   .fontSize(16)
      //   .foregroundColor('#186AFF')
      //   .margin({ top: 16, left: 16 })
      //   .width("90%")

    }
    .width('100%')

  }
  exit(){
    this.uid=''
    this.get_info()
    prompt.showToast({message:"用户已退出"})

  }

  async get_info() {
    const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/user/get_info`;
    // 定义要发送的数据
    const data:Data = {
      uid: this.uid
    };
    // 定义请求头


    try {
      const response: AxiosResponse = await axios.post(
        getURL,
        data, // 请求体数据
        { headers: headers } // 请求头配置
      );
      console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
      this.userInfo.profile = response.data.user.profile_url
      this.userInfo.username = response.data.user.user_name
      let userID_int:number = response.data.user.uid
      this.userInfo.userId = userID_int.toString()

    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        if(axiosError.response?.status == 401)
        {
          prompt.showToast({message:`用户未登录，请点击头像登录`}) ;
          this.userInfo.profile = ''
          this.userInfo.username = '未登录'
          this.userInfo.userId = ''
        }
        else {
          console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
          prompt.showToast({message:`请求失败: ${axiosError.message}`}) ;
          AlertDialog.show({
            title:"账户信息获取失败",
            message:"请检查网络"
          })
        }

      } else {
        console.error(`An unexpected error occurred: ${error}`);
        prompt.showToast({message:`发生未知错误: ${error}`}) ; ;
      }
    }
  }
}