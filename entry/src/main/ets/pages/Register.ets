import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';
import { router } from '@kit.ArkUI';
import {back_button} from '../page_compolents/buttons'

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

interface  Data  {
  user_name: string,
  pwd: string
};

@Entry
@Component
struct Register {
  @State user_name : string = ''
  @State pwd : string = ''
  @State again_pwd : string = ''

  build() {
    Stack() {
      Column() {
        Image($r("app.media.login_bg2"))
          .position({x:150,y:-300})
          .opacity(0.6)
        Image($r("app.media.login_bg"))
          .position({x:-150,y:300})
          .opacity(0.6)
      }.zIndex(1)

      Column() {
        Stack({alignContent:Alignment.TopStart})
        {
          back_button().margin({left:20})
          Text("注册")
            .width('100%')
            .textAlign(TextAlign.Center)
        }.width('100%')


        Blank()
          .height(80)
        Column() {

          Column() {
            Text("欢迎来到谷创")
              .id('TextTestHelloWorld')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
          }
          .linearGradient({
            angle: 135,
            colors: [['#B65EBA', 0], ['#78F2E9', 1]]
          })
          .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
          .alignSelf(ItemAlign.Start)
          .margin({left:20})

          Blank()
            .height(40)
          TextInput({ placeholder: "请输入您要注册的用户名" })
            .width('80%')
            .margin({ top: 10, bottom: 20 })
            .onChange((content:string)=>{
              this.user_name = content
            })
          TextInput({ placeholder: "请输入您的用户名密码" })
            .type(InputType.Password)
            .width('80%')
            .margin({ top: 10, bottom: 20 }).margin({ top: 10, bottom: 20 })
            .onChange((content:string)=>{
              this.pwd = content
            })
          TextInput({ placeholder: "请再次输入您的用户名密码" })
            .type(InputType.Password)
            .width('80%')
            .onChange((content:string)=>{
              this.again_pwd = content
            })
          Blank()
            .height(50)

          Blank()
            .height(30)
          Button("注册")
            .width('80%')
            .enabled(this.user_name != '' && this.pwd != '' && this.again_pwd != '' ? true:false)
            .margin({ bottom: 5 })
            .onClick(()=>{
              if(this.pwd == this.again_pwd)
              {
                this.verify()
              }
              else
              {
                AlertDialog.show({
                  title:"错误",
                  message:"两次密码输入不同，请重试"
                })
              }

            })

        }
        .width('100%')

        .height('100%')
        .zIndex(2)
      }

    }
  }
  async verify() {
    const getURL = "http://120.55.76.15:3400/api/db/user/register";
    // 定义要发送的数据
    const data:Data = {
      user_name: this.user_name,
      pwd: this.again_pwd
    };
    // 定义请求头


    try {
      const response: AxiosResponse = await axios.post(
        getURL,
        data, // 请求体数据
        { headers: headers } // 请求头配置
      );
      console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
      prompt.showToast({message:"注册成功，请返回登录"})
      router.pushUrl({
        url: "pages/Login_in",
      })
      router.clear()
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
        prompt.showToast({message:`请求失败: ${axiosError.message}`}) ;
        AlertDialog.show({
          title:"注册失败",
          message:"已有相同的用户名，请换一个用户名"
        })
      } else {
        console.error(`An unexpected error occurred: ${error}`);
        prompt.showToast({message:`发生未知错误: ${error}`}) ; ;
      }
    }
  }
}