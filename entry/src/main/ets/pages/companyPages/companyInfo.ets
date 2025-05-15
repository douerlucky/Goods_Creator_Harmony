import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';
import { router } from '@kit.ArkUI';
import * as server from '../../class/ServerKits';

interface CompanyInfo {
  cid: string; //企业cid
  company_name: string; //用户名
  tel:string; //电话
  address:string //收货地址
}

interface Data{
  cid:string
}

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});


interface Data_Modify {
  cid: string;
  company_name: string;
  tel: string;
  address: string;
}

@Entry
@Component

struct User_info_edit {
  @StorageLink('cid') cid:string = ''
  @State companyInfo: CompanyInfo = {
    company_name: '',
    cid: '',
    tel: '',
    address: ''
  };
  @State modifiedInfo: CompanyInfo = this.companyInfo
  aboutToAppear() {
    this.get_info();
  }


  build() {
    Column({ space: 10 }) {
      Row() {
        Text('CID')
          .width('30%')
          .textAlign(TextAlign.Start)

        Text(this.companyInfo.cid)
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
        TextInput({ placeholder: '请输入昵称',text:this.companyInfo.company_name })
          .width('70%')
          .onChange((value: string) => {
            this.modifiedInfo.company_name = value;
          })
      }
      // 电话标签和输入框
      Row() {
        Text('电话')
          .width('30%')
          .textAlign(TextAlign.Start)
        TextInput({ placeholder: '请输入电话',text:this.companyInfo.tel })
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
        TextInput({ placeholder: '请输入地址',text:this.companyInfo.address })
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
            if(this.companyInfo.company_name=='')
            {
              AlertDialog.show({title:"保存错误",message:"企业名不能为空"})
            }
            else {
              this.save_info()

              router.pushUrl({
                url:"pages/companyPages/companyPage"
              })
              router.clear()
            }
          })
      }
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
    .width('100%')
    .padding(20)
  }

  exit(){
    this.cid=''
    this.get_info()
    prompt.showToast({message:"用户已退出"})

  }

  async get_info() {
    const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/company/get_info`;
    // 定义要发送的数据
    const data:Data = {
      cid: this.cid
    };
    // 定义请求头


    try {
      const response: AxiosResponse = await axios.post(
        getURL,
        data, // 请求体数据
        { headers: headers } // 请求头配置
      );
      console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
      this.companyInfo.company_name = response.data.user.cname
      let userID_int:number = response.data.user.cid
      this.companyInfo.cid = userID_int.toString()
      this.modifiedInfo = this.companyInfo
      this.companyInfo.tel = response.data.user.ctel
      this.companyInfo.address = response.data.user.caddress

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
    this.companyInfo = this.modifiedInfo
    const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/company/modify_info`;
    // 定义要发送的数据
    const data_modify: Data_Modify = {
      cid: this.cid,
      company_name : this.companyInfo.company_name,
      tel: this.companyInfo.tel,
      address: this.companyInfo.address
    };
    // 定义请求头


    try {
      const response: AxiosResponse = await axios.post(
        getURL,
        data_modify, // 请求体数据
        { headers: headers } // 请求头配置
      );
      console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
      prompt.showDialog({title:"修改成功",message:"企业信息已保存至云端"})

    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError: AxiosError = error;
        if(axiosError.response?.status == 404)
        {
          prompt.showToast({message:`企业不存在`}) ;
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