import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import axios, { AxiosError, AxiosHeaders, AxiosResponse, FormData } from '@ohos/axios';
import { prompt } from '@kit.ArkUI';
import * as server from '../class/ServerKits';

let context = getContext(this) as common.UIAbilityContext
let cacheDir = context.cacheDir

async function PickerPhoto() {
  // 打开系统图库
  const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
  // 过滤选择媒体文件类型为 IMAGE
  photoSelectOptions.maxSelectNumber = 1;
  // 选择媒体文件的最大数目

  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
  let urls = await photoViewPicker.select(photoSelectOptions)
  if(urls.photoUris.length <= 0)
  {return}
  let imgUrl = urls.photoUris[0]
  return imgUrl
}


function copyImgToCache(photoImgPath:string)
{
  const file = fs.openSync(photoImgPath,fs.OpenMode.READ_ONLY)
  //文件唯一标志
  let fileFD = file.fd

  let fileName = Date.now().toString()
  const ext = 'png'
  let fullPath = cacheDir + "/" + fileName + "." + ext
  fs.copyFileSync(fileFD,fullPath)

  return [`internal://cache/${fileName + '.' + ext}`,fileName + '.' + ext]
}

// 定义请求体的类型
interface Payload {
  imgUrl: string;
  uid: string;
}

// 定义响应数据的类型
interface UploadResponse {
  message: string;
  iid: string;
  uid: string;
  ossUrl: string;
}

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

async function FileUpload(imgSrc: string, uid: string) {
  const payload: Payload = {
    imgUrl: imgSrc,
    uid: uid
  };
  const url = `${server.postBaseUrl}${server.fileuploadPort}/api/upload-image/to_oss/AI_paintings`;

  try {
    const response: AxiosResponse<UploadResponse> = await axios.post(
      url,
      payload,
      { headers: headers }
    );
    console.log('上传成功', response.data);

    AlertDialog.show({
      title: "生成成功",
      message: "生成图片成功并已保存到云端",
      primaryButton: {
        value: '确定',
        action: () => { }
      }



    });
    console.log(`接受的地址${response.data.ossUrl}`)
    return response.data.ossUrl
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`上传失败: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      AlertDialog.show({
        title: "上传失败",
        message: `错误信息: ${axiosError.message}`
      });
      return undefined
    } else {
      console.error(`发生未知错误: ${error}`);
      AlertDialog.show({
        title: "上传失败",
        message: `发生未知错误: ${error}`
      });
      return undefined
    }
  }
}

async function LocalFileUpload(imgSrc: string, uid: string) {
  // 显示上传中的加载弹窗（持续显示，直到手动关闭）
  const toastId = prompt.showToast({
    message: "图片正在上传中，请稍等",
    duration: 10000 // 0 表示不自动消失，需手动关闭
  });

  try {
    const array = copyImgToCache(imgSrc);
    console.log("复制完成");
    console.log(array[0], array[1]);

    const header = new Map<Object, string>();
    const files: Array<request.File> = [
      {
        filename: array[1],
        name: "image",
        uri: array[0],
        type: "png"
      }
    ];
    const data: Array<request.RequestData> = [{ name: "uid", value: uid.toString() }];
    const uploadConfig: request.UploadConfig = {
      url: `${server.postBaseUrl}${server.fileuploadPort}/api/upload-image/to_oss/fromLocal`,
      header,
      method: "POST",
      files,
      data
    };

    // 使用 Promise 包装上传流程
    await new Promise<void>((resolve, reject) => {
      request
        .uploadFile(context, uploadConfig)
        .then((uploadTask: request.UploadTask) => {
          console.log("正在上传");
          uploadTask.on("progress", (progress: number) => {
            console.log(`上传进度: ${progress}%`);
          });

          uploadTask.on("complete", (taskStates: Array<request.TaskState>) => {
            for (const taskState of taskStates) {
              console.info(`upload complete taskState: ${JSON.stringify(taskState)}`);
              console.log("上传成功");
            }
            resolve(); // 上传成功时触发 resolve
          });
        })
        .catch((err: BusinessError) => {
          console.error(`上传失败: code=${err.code}, message=${err.message}`);
          reject(err); // 上传失败时触发 reject
        });
    });

    // 上传成功后关闭弹窗，并提示成功
    prompt.showToast({
      message: "图片上传成功",
      duration: 2000 // 显示 2 秒后自动消失
    });
  } catch (error) {
    // 上传失败时关闭弹窗，并提示失败
    prompt.showToast({
      message: "图片上传失败，请重试",
      duration: 2000
    });
    const err: BusinessError = error as BusinessError;
    console.error(`Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
  } finally {
    // 确保无论成功/失败都关闭加载弹窗

  }
}

//本地裁剪後的圖片图片上传
async function cropImgUpload(imgSrc: string, taskid: string) {

  console.log("复制完成");
  console.log(imgSrc, imgSrc);
  const toastId = prompt.showToast({
    message: "图片正在裁剪中，请稍等",
    duration: 10000 // 0 表示不自动消失，需手动关闭
  });
  let header = new Map<Object, string>();
  let files: Array<request.File> = [
    {
      filename:imgSrc,
      name: 'image',
      uri: imgSrc,
      type: 'png'
    }
  ];
  let data: Array<request.RequestData> = [{ name: 'taskid', value: taskid}];
  let uploadConfig: request.UploadConfig = {
    url: `${server.postBaseUrl}${server.DIPPort}/api/dip/cropImage`,
    header: header,
    method: 'POST',
    files: files,
    data: data
  };

  try{
    // 使用 Promise 包装上传流程
    await new Promise<void>((resolve, reject) => {
      request
        .uploadFile(context, uploadConfig)
        .then((uploadTask: request.UploadTask) => {
          console.log("正在上传");
          uploadTask.on("progress", (progress: number) => {
            console.log(`上传进度: ${progress}%`);
          });

          uploadTask.on("complete", (taskStates: Array<request.TaskState>) => {
            for (const taskState of taskStates) {
              console.info(`upload complete taskState: ${JSON.stringify(taskState)}`);
              console.log("上传成功");
            }
            resolve(); // 上传成功时触发 resolve
          });
        })
        .catch((err: BusinessError) => {
          console.error(`上传失败: code=${err.code}, message=${err.message}`);
          reject(err); // 上传失败时触发 reject
        });

    });
    // 上传成功后关闭弹窗，并提示成功
    prompt.showToast({
      message: "图片裁剪成功",
      duration: 2000 // 显示 2 秒后自动消失
    });
  } catch (error) {
    // 上传失败时关闭弹窗，并提示失败

    const err: BusinessError = error as BusinessError;
    console.error(`Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
  } finally {
    // 确保无论成功/失败都关闭加载弹窗

  }


}



// 定义查询接口的请求数据类型
interface CheckStatusData {
  uid: string; // 上传时使用的用户ID
}

interface CheckStatusResponse {
  code: number; // 状态码（200=成功，500=失败）
  message: string; // 状态描述
  url: string; // 上传文件的OSS URL（成功时返回）
}

// 新增：查询上传状态的函数
async function checkUploadStatus(uid: string): Promise<string> {
  const checkStatusUrl = `${server.postBaseUrl}${server.fileuploadPort}/api/upload-image/to_oss/fromLocal/checkStatus`;
  const data: CheckStatusData = { uid };
  try {
    const response: AxiosResponse<CheckStatusResponse> = await axios.post(
      checkStatusUrl,
      data,
      { headers }
    );

    if (response.data.code === 200) {
      console.log('查询成功，文件URL:', response.data.url);
      return response.data.url; // 返回URL供后续使用
    } else {
      throw new Error(`查询失败：${response.data.message}`);
    }
  } catch (error) {
    let errorMessage = '查询状态失败';
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`查询错误：状态码 ${axiosError.response?.status}，信息 ${axiosError.message}`);
      errorMessage = `查询失败：${axiosError.message}`;
    } else if (error instanceof Error) {
      errorMessage = error.message;
    }
    throw new Error(errorMessage);
  }
}





interface Data {
  uid: string
}

interface Query_Contents {
  iid:number
  url: string;
}

interface ResponseData {
  query_content: Query_Contents[];
}

//搜索之前上传的图片

async function search_upload_images(uid: string): Promise<Query_Contents[]> {
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/upload_images/search`;
  const data: Data = { uid };

  try {
    const response: AxiosResponse<ResponseData> = await axios.post(
      getURL,
      data,
      { headers }
    );

    if (response.data && response.data.query_content) {
      return response.data.query_content;
    } else {
      console.error('返回数据格式异常:', JSON.stringify(response.data));
      throw new Error('Invalid response format');
    }
  } catch (error) {
    let errorMessage = 'Network request failed';

    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      errorMessage = `请求失败: ${axiosError.message}`;
    } else if (error instanceof Error) {
      errorMessage = error.message;
    } else {
      errorMessage = JSON.stringify(error);
    }

    throw new Error(errorMessage); // 始终抛出Error类型
  }
}

interface img2Video_data
{
  imageUrl:string, uid:string, prompt:string, duration:number, resolution:string
}
// 生成动态视频
async function generateVideo(
  imageUrl: string,
  uid: string,
  prompt: string,
): Promise<string> {
  const generateURL = `${server.postBaseUrl}${server.AIPort}/api/ai/generate-video`; // 需替换为实际后端地址
  const data:img2Video_data = {imageUrl:imageUrl,uid:uid,prompt:prompt,duration:4,resolution:'720p'  }; // 匹配后端参数

  try {
    const response: AxiosResponse<GenerateVideoResponse> = await axios.post(
      generateURL,
      data,
      { headers } // 使用与搜索接口一致的请求头
    );

    if (response.data.success) {
      return response.data.videoUrl;
    } else {
      console.error('视频生成失败:', response.data.message);
      throw new Error(response.data.message);
    }
  } catch (error) {
    let errorMessage = '视频生成请求失败';

    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      errorMessage = `请求失败: ${axiosError.message}`;
    } else if (error instanceof Error) {
      errorMessage = error.message;
    } else {
      errorMessage = JSON.stringify(error);
    }

    throw new Error(errorMessage); // 始终抛出Error类型
  }
}

// 响应数据接口（需与后端返回结构一致）
interface GenerateVideoResponse {
  success: boolean;
  videoUrl: string;
  message: string;
  taskId: string;
}


export { PickerPhoto, copyImgToCache, FileUpload, search_upload_images, LocalFileUpload, cropImgUpload,
  checkUploadStatus,generateVideo };