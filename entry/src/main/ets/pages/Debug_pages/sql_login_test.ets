import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

interface  Data  {
  username: string,
  pwd: string
};

@Entry
@Component
struct sql_login_test {
  @State user_name: string = '';
  @State pwd: string = '';
  @State resultMessage: string = ''; // 用于显示请求结果的消息

  build() {
    Column({ space: 10 }) {
      TextInput({ placeholder: "账号" }).width('80%')
        .onChange((content: string) => {
          this.user_name = content;
        })
      TextInput({ placeholder: "密码" }).width('80%')
        .onChange((content: string) => {
          this.pwd = content;
        })
      Button("登录")
        .onClick(() => {
          this.verify();
        })
      Text(this.resultMessage) // 显示请求结果的消息
    }.width('100%')
    .height('100%')
  }

  async verify() {
    const getURL = "http://120.55.76.15:3400/test-db";
    // 定义要发送的数据
    const data:Data = {
      username: this.user_name,
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
      this.resultMessage = `请求成功: ${JSON.stringify(response.data.message)}`;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
        this.resultMessage = `请求失败: ${axiosError.message}`;
        AlertDialog.show({
          title:"登录失败",
          message:"账号不存在或密码不正确"
        })
      } else {
        console.error(`An unexpected error occurred: ${error}`);
        this.resultMessage = `发生未知错误: ${error}`;
      }
    }
  }
}