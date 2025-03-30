import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { confirm_button } from './buttons';
import axios, { AxiosError, AxiosHeaders, AxiosResponse, FormData } from '@ohos/axios';
import fetch from '@system.fetch';
import { prompt } from '@kit.ArkUI';

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
  const ext = 'jpg'
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
  AI_pid: string;
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
  const url = 'http://120.55.76.15:3100/api/upload-image/to_oss/AI_paintings';

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
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`上传失败: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      AlertDialog.show({
        title: "上传失败",
        message: `错误信息: ${axiosError.message}`
      });
    } else {
      console.error(`发生未知错误: ${error}`);
      AlertDialog.show({
        title: "上传失败",
        message: `发生未知错误: ${error}`
      });
    }
  }
}


interface Data {
  uid: string
}

interface Query_Contents {
  AI_pid:number
  url: string;
}

interface ResponseData {
  query_content: Query_Contents[];
}

async function search_ai_paintings(uid: string): Promise<Query_Contents[]> {
  const getURL = "http://120.55.76.15:3400/api/db/AI_paintings/search";
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


export { PickerPhoto, copyImgToCache, FileUpload,search_ai_paintings };