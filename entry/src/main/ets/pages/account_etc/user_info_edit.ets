import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';
import { router } from '@kit.ArkUI';
import * as server from '../../class/ServerKits';

interface UserInfo {
  profile: string; //头像
  username: string; //用户名
  userId: string; //用户uid
  tel:string; //电话
  address:string //收货地址
  coin: number;
}

interface Data{
  uid:string
}

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});


interface Data_Modify {
  profile: string;
  uid: string;
  username: string;
  tel: string;
  address: string;
}

@Entry
@Component

struct User_info_edit {
  @StorageLink('uid') uid:string = ''
  @State userInfo: UserInfo = {
    profile: '',
    username: '未登录',
    userId: this.uid,
    coin: 0,
    tel: '',
    address: ''
  };
  @State modifiedInfo: UserInfo = this.userInfo
  aboutToAppear() {
    this.get_info();
  }


  build() {
    Column({ space: 10 }) {
      Row() {
        Image(this.userInfo.profile==''?$r('app.media.default_profile'):this.userInfo.profile)
          .width(100)
          .height(100)
          .borderRadius(50)
          .backgroundColor(0xc0c0c0)
          .margin({ top: 20 })
      }
      // UID 标签和输入框
      Row() {
        Text('UID')
          .width('30%')
          .textAlign(TextAlign.Start)

        Text(this.userInfo.userId)
          .margin({left:5})
          .fontWeight(600)
          .width('70%')
          .height(45)
          .borderRadius(20)
      }
      // 昵称标签和输入框
      Row() {
        Text('昵称')
          .width('30%')
          .textAlign(TextAlign.Start)
        TextInput({ placeholder: '请输入昵称',text:this.userInfo.username })
          .width('70%')
          .onChange((value: string) => {
            this.modifiedInfo.username = value;
          })
      }
      // 电话标签和输入框
      Row() {
        Text('电话')
          .width('30%')
          .textAlign(TextAlign.Start)
        TextInput({ placeholder: '请输入电话',text:this.userInfo.tel })
          .width('70%')
          .onChange((value: string) => {
            this.modifiedInfo.tel = value;
          })
      }
      // 收货地址标签和输入框
      Row() {
        Text('地址')
          .width('30%')
          .textAlign(TextAlign.Start)
        TextInput({ placeholder: '请输入地址',text:this.userInfo.address })
          .width('70%')
          .onChange((value: string) => {
            this.modifiedInfo.address = value;
          })
      }
      // 操作按钮区域
      Blank().height(100)
      Row({space:10}) {
        Button('取消')
          .width('45%')
          .backgroundColor(0xff5555)
          .onClick(() => {
            router.back()
          })
        Button('保存')
          .width('45%')
          .backgroundColor(0xff5555)
          .onClick(() => {
            // 这里可以添加保存逻辑，例如将数据发送到后端接口
            if(this.userInfo.username=='')
            {
              AlertDialog.show({title:"保存错误",message:"昵称不能为空"})
            }
            else {
              this.save_info()

              router.pushUrl({
                url:"pages/account_etc/user_info"
              })
              router.clear()
            }
          })
      }
    }
    .width('100%')
    .padding(20)
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
      this.modifiedInfo = this.userInfo
      this.userInfo.tel = response.data.user.tel
      this.userInfo.address = response.data.user.address

    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        if(axiosError.response?.status == 401)
        {
          prompt.showToast({message:`用户未登录，请点击头像登录`}) ;
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

  async save_info() {
    this.userInfo = this.modifiedInfo
    console.log(this.userInfo.profile)
    const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/user/modify_info`;
    // 定义要发送的数据
    const data_modify: Data_Modify = {
      profile : this.userInfo.profile,
      uid: this.uid,
      username : this.userInfo.username,
      tel: this.userInfo.tel,
      address: this.userInfo.address
    };
    // 定义请求头


    try {
      const response: AxiosResponse = await axios.post(
        getURL,
        data_modify, // 请求体数据
        { headers: headers } // 请求头配置
      );
      console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
      prompt.showDialog({title:"修改成功",message:"个人信息已保存至云端"})

    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        if(axiosError.response?.status == 404)
        {
          prompt.showToast({message:`用户不存在`}) ;
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