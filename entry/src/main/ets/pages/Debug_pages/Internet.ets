import axios, { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';

interface Message {
  content: string;
  role: 'system' | 'user';
  name?: string;
}


interface RequestPayload {
  model: string;
  messages: Message[];
}

interface ResponseData {
  // 根据实际API响应结构补充完整类型
  status_code?: number;
  reply?: string;
  // 其他可能的响应字段...
}

const api_key: string = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJHcm91cE5hbWUiOiJkb3Vlcl9sdWNreSIsIlVzZXJOYW1lIjoiZG91ZXJfbHVja3kiLCJBY2NvdW50IjoiIiwiU3ViamVjdElEIjoiMTg5NDYzOTgwNzk0Mjg5MDQ2OCIsIlBob25lIjoiMTMzNDM0NjA5MjIiLCJHcm91cElEIjoiMTg5NDYzOTgwNzkzNDUwMTc3MiIsIlBhZ2VOYW1lIjoiIiwiTWFpbCI6IiIsIkNyZWF0ZVRpbWUiOiIyMDI1LTAzLTA0IDIxOjUzOjI5IiwiVG9rZW5UeXBlIjoxLCJpc3MiOiJtaW5pbWF4In0.hejroCSDbCGQggeWhw2OeKVYyEOHE-M0YwRXcZl0Ilbl7Rcyg2OSQN9touGLU8pDU8yS96NTzalSVbBd2q2iN4VVyJvVjnwelnElv4u4YC4FMy07rslUdLaMc0nc0nGBdShw0XDxKRsrHgALR2OycQGYVemZep30u8IkAtOGeiaoYH1HXPc6ZD_yTjWmL1NaU08T6d_5Ch7XsJdWCwTNl2Ir70NeOq42han3-rh1xn_CjM9US0erS3r5n34OFeW5XGn_qFgX4XvF5gPWuoJ_ryKzDJhLS38fyYef32Hit1X_1zYR94F2jh0VXrotElBR52y5EITrGmJzVw22YzSiVw";
const instance = axios.create({
  baseURL: 'https://api.minimax.chat/v1/text/',
  timeout: 60000,
  headers: {
    "Authorization": `Bearer ${api_key}`,
    "Content-Type": "application/json"
  }
});

@Entry
@Component
struct AI_Test {
  @State responseText: string = '';
  @State statusCode: number = 0;
  @State loading: boolean = false;
  @State input:string = '你好';

  // 构建请求参数
  private getPayload(): RequestPayload {
    return {
      model: "MiniMax-Text-01",
      messages: [
        {
          content: "MM智能助理是一款由MiniMax自研的，没有调用其他产品的接口的大型语言模型。MiniMax是一家中国科技公司，一直致力于进行大模型相关的研究。",
          role: "system",
          name: "MM智能助理"
        },
        {
          role: "user",
          name: "用户",
          content: this.input
        }
      ]
    };
  }



  build() {
    Column({ space: 10 }) {
      Text("AI 访问测试")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextInput({
        placeholder: "问问AI"
      })
        .width('100%')
          // 绑定 onChange 事件，当输入内容变化时更新 inputValue 的值
        .onChange((value: string) => {
          this.input = value;
        })
      Text(this.input)


      Button(this.loading ? 'AI生成中...' : 'AI一下')
        .onClick(() => {
          if (this.loading) return;

          this.loading = true;
          instance.post<ResponseData>('chatcompletion_v2', this.getPayload())
            .then((response: AxiosResponse<ResponseData>) => {
              this.statusCode = response.status;
              if (response.data?.reply) {
                this.responseText = response.data.reply;
                console.log("1")
              } else {
                this.responseText = JSON.stringify(response.data, null, 2);
                const regex = /"content": "([^"]*)"/;
                const match = this.responseText.match(regex);
                console.log("2")
                if (match && match[1]) {
                  this.responseText=match[1]
                } else {
                  console.log('未找到 content 内容');
                }
              }
            })
            .catch((error: AxiosError) => {
              this.responseText = `请求失败: ${error.message}`;
              if (error.response) {
                this.statusCode = error.response.status;
              }
            })
            .finally(() => {
              this.loading = false;


            });
        })

      Text(`状态码: ${this.statusCode}`)
        .fontSize(14)
        .fontColor(Color.Gray)

      Scroll() {
        Text(this.responseText)
          .fontSize(16)
          .textAlign(TextAlign.Start)
          .padding(10)
          .copyOption(CopyOptions.LocalDevice)
      }
      .height('60%')
      .width('100%')
      .border({ width: 1, color: Color.Gray })
    }
    .padding(20)
    .width('100%')
    .height('100%')
  }
}