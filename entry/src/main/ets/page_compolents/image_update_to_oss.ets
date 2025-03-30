import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { confirm_button } from './buttons';

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

async function FileUpload(imgSrc: string,uid: string,user_file_name: string) {
  const array = copyImgToCache(imgSrc);
  console.log("复制完成");
  console.log(array[0], array[1])

  let header = new Map<Object, string>();
  let files: Array<request.File> = [
    {
      filename: array[1],
      name: 'image',
      uri: array[0],
      type: 'jpg'
    }
  ];
  // 修改 data 数组，添加 uid 和 file_name
  let data: Array<request.RequestData> = [
    { name: 'uid', value: uid },
    { name: 'file_name', value: user_file_name },
    { name: 'name', value: 'value' }
  ];
  let uploadConfig: request.UploadConfig = {
    url: 'http://120.55.76.15:3100/api/upload-image/to_oss',
    header: header,
    method: 'POST',
    files: files,
    data: data
  };

  try {
    request.uploadFile(context, uploadConfig)
      .then((uploadTask: request.UploadTask) => {
        console.log("正在上传");

        uploadTask.on('progress', (progress: number) => {
          console.log(`上传进度: ${progress}%`);
        });

        uploadTask.on('complete', (taskStates: Array<request.TaskState>) => {
          for (let i = 0; i < taskStates.length; i++) {
            console.info(`upload complete taskState: ${JSON.stringify(taskStates[i])}`);
            console.log("上传成功", i.toString());
          }
          AlertDialog.show({
            title:"上传成功",
            message:"文件已成功上传",
            primaryButton: {
              value: '确定',
              action: () => {

              }
            }
          })
        });

      })
      .catch((err: BusinessError) => {
        console.error(`Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
      });
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error(`Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
  }

}


export {PickerPhoto,copyImgToCache,FileUpload}