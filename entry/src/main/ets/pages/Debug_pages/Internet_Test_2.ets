import axios, { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import prompt from '@system.prompt';

// 定义提交绘画任务的请求参数接口
interface DrawRequestPayload {
  prompt: string;
  modelStyleId: number;
}

// 定义获取任务详情的请求参数接口
interface TaskDetailRequestPayload {
  taskId: string;
}

// 定义提交绘画任务的响应数据接口
interface GeneratedTypeLiteralInterface_1 {
  paintingSign: string;
}

interface DrawResponseData {
  code: number;
  msg: string;
  data: GeneratedTypeLiteralInterface_1;
}

// 定义获取任务详情的响应数据接口
interface GeneratedTypeLiteralInterface_2 {
  state: string;
  progress: number;
  imgUrl?: string;
  current_image?: string;
}

interface TaskDetailResponseData {
  data: GeneratedTypeLiteralInterface_2;
}

// 请替换为实际的 token
const token: string = '22e09f7a742e4f06a4e20ad6d97665d5';
const instance = axios.create({
  baseURL: 'https://ai.huashi6.com/aiapi/v1',
  timeout: 60000,
  headers: {
    'content-type': 'application/json',
    'Auth-Token': token
  }
});

@Entry
@Component
struct TouchStationAIPaintingDemo {
  @State inputText: string = '';
  @State progressText: string = '0%';
  @State imageUrl: string = '';
  @State showImage: boolean = false;
  @State isButtonDisabled: boolean = false;

  build() {
    Column({ space: 20 }) {
      // 输入框和提交按钮区域
      Row({ space: 10 }) {
        TextInput({placeholder:"请输入你要生成的图片描述"}).onChange((value:string)=>{
          this.inputText=value
        })

        Button(this.isButtonDisabled ? '生成中...' : '生成')
          .width('30%')
          .onClick(() => {
            this.handleSubmit();
          })
      }

      // 进度显示和图片展示区域
      Column({ space: 10 }) {
        Text(this.progressText)
          .fontSize(16)

        Image(this.imageUrl)
          .width(512)
          .height(512)
      }
    }
    .padding({ top: 50, left: 20, right: 20 })
  }

  private async handleSubmit() {
    if (!this.inputText) {
      prompt.showToast({
        message: '请输入词条'
      });
      return;
    }
    this.showImage = false;
    this.progressText = '0%';
    this.isButtonDisabled = true;

    try {
      const payload: DrawRequestPayload = {
        prompt: this.inputText,
        modelStyleId: 1
      };
      const response: AxiosResponse<DrawResponseData> = await instance.post('draw', payload);
      const data = response.data;
      if (data.code!== 0) {
        prompt.showToast({
          message: data.msg
        });
        this.isButtonDisabled = false;
        return;
      }
      const taskId = data.data.paintingSign;
      this.pollTaskStatus(taskId);
    } catch (error) {
      prompt.showToast({
        message: '请求出错，请稍后重试'
      });
      this.isButtonDisabled = false;
    }
  }

  private async pollTaskStatus(taskId: string) {
    let lastState: string | null = null;
    const intervalId = setInterval(async () => {
      try {
        const payload: TaskDetailRequestPayload = {
          taskId: taskId
        };
        const response: AxiosResponse<TaskDetailResponseData> = await instance.post('task/detail', payload);
        const data = response.data;
        lastState = data.data.state;
        this.progressText = `${data.data.progress * 100}%`;

        if (lastState === 'success') {
          this.progressText = '生成完成';
          this.showImage = true;
          this.imageUrl = data.data.imgUrl || '';
          clearInterval(intervalId);
          this.isButtonDisabled = false;
        } else if (lastState === 'fail') {
          this.progressText = '生成失败';
          clearInterval(intervalId);
          this.isButtonDisabled = false;
        } else if (data.data.current_image) {
          this.showImage = true;
          this.imageUrl = `data:image/jpeg;base64,${data.data.current_image}`;
        }
      } catch (error) {
        prompt.showToast({
          message: '获取任务状态出错，请稍后重试'
        });
        clearInterval(intervalId);
        this.isButtonDisabled = false;
      }
    }, 3000);
  }
}