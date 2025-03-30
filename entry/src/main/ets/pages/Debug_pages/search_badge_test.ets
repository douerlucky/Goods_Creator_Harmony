import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';

interface Query_Contents {
  bid: string;
  badge_name: string;
  uid: string;
  user_name: string;
  URL: string;
}

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

interface  Data  {
  query_name:string
};

interface ResponseData {
  query_content: Query_Contents[];
}

@Entry
@Component
struct Search_badge_test {
  @State message: string = 'Hello World';
  @State query_name: string = '';
  @State query_content: Query_Contents[] = [

  ];

  build() {
    Column() {
      Search({ placeholder: "搜索徽章名" })
        .searchButton("搜索")
        .width('80%')
        .onChange((content: string) => {
          this.query_name = content;
        })
        .onClick(()=>{
          this.search_badge(this.query_name)

        });
      Scroll() {
        Grid() {
          ForEach(this.query_content, (item: Query_Contents) => {
            GridItem() {
              Column({ space: 5 }) {
                Image(item.URL)
                  .width(128)
                  .borderRadius(16);
                Column() {
                  Text(item.badge_name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold);
                  Text(item.user_name);
                }
                Button("下载");
              }
            }
            .backgroundColor('#f5f5f5')
            .padding({top:5,bottom:5})
            .borderRadius(16)
          });
        }
        .columnsTemplate('1fr 1fr')
        .width('100%')
        .height('100%')
        .rowsGap(10)
        .columnsGap(10);
      }.width('90%')
      .height('100%');
    }.width('100%');
  }
  async search_badge(query_name:string)
  {
    const getURL = "http://120.55.76.15:3400/api/db/query_badge";
    // 定义要发送的数据
    const data:Data = {
      query_name:query_name
    };
    // 定义请求头

    try {
      const response: AxiosResponse = await axios.post(
        getURL,
        data, // 请求体数据
        { headers: headers } // 请求头配置
      );
      if (response.data && response.data.query_content) {
        this.query_content = response.data.query_content;
        console.info('数据更新成功:', JSON.stringify(this.query_content));
      } else {
        console.error('返回数据格式异常:', JSON.stringify(response.data));
        AlertDialog.show({ title: "提示", message: "服务器返回数据格式错误" });
      }
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
        AlertDialog.show({
          title:"登录失败",
          message:"账号不存在或密码不正确"
        })
      } else {
        console.error(`An unexpected error occurred: ${error}`);
      }
    }
  }
}
