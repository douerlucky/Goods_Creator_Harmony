import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import * as buttons from '../page_compolents/buttons'
import prompt from '@system.prompt';
import { router } from '@kit.ArkUI';

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

struct User_info_edit {
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

  }

  async get_info() {
    const getURL = "http://120.55.76.15:3400/api/db/user/get_info";
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