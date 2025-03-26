import http from '@ohos.net.http';
import json from '@ohos.util.json';
interface JsonData {
  status: string;
  message: string;
  receivedText: string;
}
// 1. 创建 HttpClient 对象
let httpClient = http.createHttp();

@Entry
@Component
struct Index {
  @State status:string=''
  @State message:string=''
  build(){
    Column()
    {
      Button("发送").onClick(()=>{
        // 调用示例：发送文本
        this.sendTextToServer('你好，大傻逼');})
      Text(this.status)
      Text(this.message)
    }
  }
  private async  sendTextToServer(text: string) {
  // 阿里云 ECS 的公网 IP 或域名（替换为你的服务器地址）
  let url = 'http://120.27.132.232:3000/api/receive-text';

  // 3. 构造请求选项
  let options: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: JSON.stringify({ text: text }) // 发送的文本数据
  };

  try {
    // 4. 发送请求
    let response = await httpClient.request(url, options);

    // 5. 处理响应
    if (response.responseCode === 200) {
      console.log('发送成功:', response.result);
      try {
        if (typeof response.result === 'string') {
          const jsonObj: JsonData = JSON.parse(response.result);
          // 通过对象的属性名来获取对应的值
          const status = jsonObj.status;
          const message = jsonObj.message;
          const receivedText = jsonObj.receivedText;

          console.log(`status: ${status}`);
          this.status=status
          console.log(`message: ${message}`);
          this.message=message
          console.log(`receivedText: ${receivedText}`);
        } else {
          console.error('响应结果不是字符串类型，无法进行 JSON 解析。');
        }
      } catch (error) {
        // 处理解析过程中可能出现的错误
        console.error('解析 JSON 时出现错误:', error);
      }
    } else {
      console.error('服务器错误:', response.responseCode);
    }
  } catch (err) {
    console.error('网络请求失败:', err);
  }
}

}

