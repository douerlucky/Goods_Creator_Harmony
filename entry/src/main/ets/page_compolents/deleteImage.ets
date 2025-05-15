import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import * as server from '../class/ServerKits';

// 定义请求数据的接口
interface DeleteData {
  bid: string;
  uid: string;
  op:number;
}

// 定义响应数据的接口
interface DeleteResponse {
  success: boolean;
  message: string;
}

async function deleteBadge(bid: string, uid: string,op:number): Promise<DeleteResponse> {
  const url = `${server.postBaseUrl}${server.databasePort}/api/db/badges/delete`;
  const data: DeleteData = { bid, uid ,op};
  try {
    const response: AxiosResponse<DeleteResponse> = await axios.post(url, data);
    return response.data;
  } catch (error) {
    let errorMessage = '网络请求失败';
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`响应错误: 状态码 ${axiosError.response?.status}, 信息 ${axiosError.message}`);
      errorMessage = `请求失败: ${axiosError.message}`;
    } else if (error instanceof Error) {
      errorMessage = error.message;
    } else {
      errorMessage = JSON.stringify(error);
    }
    throw new Error(errorMessage);
  }
}

// 前端删除函数
interface DeleteImageData {
  iid: number; // 假设 iid 为字符串类型（与后端保持一致）
}

async function deleteUploadImage(iid: number): Promise<DeleteResponse> {
  const url = `${server.postBaseUrl}${server.databasePort}/api/db/upload_images/delete`;
  const data: DeleteImageData = { iid };

  try {
    const response: AxiosResponse<DeleteResponse> = await axios.post<DeleteResponse>(url, data);
    return response.data;
  } catch (error) {
    // 处理错误（与 deleteBadge 函数逻辑一致）
    throw new Error('删除图片失败');
  }
}

export { deleteBadge,deleteUploadImage };