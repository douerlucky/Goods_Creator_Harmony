import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';
import { router } from '@kit.ArkUI';



const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

interface  Data  {
  user_name: string,
  pwd: string
};

@Entry
@Component
struct Login_in {
  @StorageLink('uid') uid:string = ''
  @State user_name : string = ''
  @State pwd : string = ''
  @State agree : boolean = false

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
        Text("登录")
          .width('100%')
          .textAlign(TextAlign.Center)
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
          TextInput({ placeholder: "请输入您的用户名" })
            .width('80%')
            .margin({ top: 10, bottom: 20 })
            .onChange((content:string)=>{
              this.user_name = content
            })
          TextInput({ placeholder: "请输入密码" })
            .type(InputType.Password)
            .width('80%')
            .onChange((content:string)=>{
              this.pwd = content
            })
          Blank()
            .height(50)
          Row() {
            Checkbox()
              .height(12)
              .onChange(()=>{
                this.agree = !this.agree
              })
            Text("我已经阅读并同意《用户协议》及隐私协议")
              .fontSize(12)
          }.width('80%')

          Blank()
            .height(30)
          Button("登录")
            .width('80%')
            .enabled(this.user_name != '' && this.pwd != '' && this.agree)
            .margin({ bottom: 5 })
            .onClick(()=>{
              this.verify()
            })
          Row() {
            Text("没有账号？")
            Text("去注册")
              .fontColor('#2A82E4')
          }

        }
        .width('100%')
        .height('100%')
        .zIndex(2)
      }

    }
  }
  async verify() {
    const getURL = "http://120.55.76.15:3400/api/db/user/login";
    // 定义要发送的数据
    const data:Data = {
      user_name: this.user_name,
      pwd: this.pwd
    };
    // 定义请求头


    try {
      const response: AxiosResponse = await axios.post(
        getURL,
        data, // 请求体数据
        { headers: headers } // 请求头配置
      );
      console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
      this.uid = response.data.user.uid
      prompt.showToast({message:"登录成功"})
      router.pushUrl({
        url: "pages/Index",
      })
      router.clear()
      
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
        prompt.showToast({message:`请求失败: ${axiosError.message}`}) ;
        AlertDialog.show({
          title:"登录失败",
          message:"账号不存在或密码不正确"
        })
      } else {
        console.error(`An unexpected error occurred: ${error}`);
        prompt.showToast({message:`发生未知错误: ${error}`}) ; ;
      }
    }
  }
}