import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import * as server from '../class/ServerKits';
import { prompt } from '@kit.ArkUI';
import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import { Updated_Badge } from '../class/Badge';
import { orderlist_information } from '../class/order_list';

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});


interface submitOrderData{
  bid:string
  uid:string
  quantity:number
  total_price:number
}

async function get_info(bid:string,uid:string,quantity:number,total_price:number) {
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/materialize/submit_order`;
  // 定义要发送的数据
  const data:submitOrderData = {
    bid:bid,
    uid:uid,
    quantity:quantity,
    total_price:total_price
  };
  // 定义请求头


  try {
    const response: AxiosResponse = await axios.post(
      getURL,
      data, // 请求体数据
      { headers: headers } // 请求头配置
    );
    console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
    prompt.showToast({message:`提交订单成功`}) ;

  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      if(axiosError.response?.status == 401)
      {
        prompt.showToast({message:`提交订单失败`}) ;
      }
      else {
        console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
        prompt.showToast({message:`请求失败: ${axiosError.message}`}) ;
        AlertDialog.show({
          title:"提交订单失败",
          message:"请检查网络"
        })
      }

    } else {
      console.error(`An unexpected error occurred: ${error}`);
      prompt.showToast({message:`发生未知错误: ${error}`}) ; ;
    }
  }
}


interface getOrderData{
  uid:string
  role:number
}

async function get_order_list(uid:string,role:number) {
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/materialize/get_order_list`;
  // 定义要发送的数据
  const data:getOrderData = {
   uid:uid,
    role:role
  };
  // 定义请求头
  try {
    const response: AxiosResponse<orderlist_information[]> = await axios.post(
      getURL,
      data, // 请求体数据
      { headers: headers } // 请求头配置
    );
    console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
    prompt.showToast({message:`获取成功`}) ;
    let orderInfos:orderlist_information[] = []
    orderInfos = response.data
    return orderInfos
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      if(axiosError.response?.status == 401)
      {
        prompt.showToast({message:`提交订单失败`}) ;
      }
      else {
        console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
        prompt.showToast({message:`请求失败: ${axiosError.message}`}) ;
        AlertDialog.show({
          title:"提交订单失败",
          message:"请检查网络"
        })
        return null
      }
      return null
    } else {
      console.error(`An unexpected error occurred: ${error}`);
      prompt.showToast({message:`发生未知错误: ${error}`}) ;
      return null
    }
  }
}


interface changeData{
  orderID:string
  cid:string
  statue:number
}

async function change_statue(orderID:string,cid:string,statue:number) {
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/materialize/change_order_status`;
  // 定义要发送的数据
  const data:changeData = {
    orderID:orderID,
    cid:cid,
    statue:statue
  };
  // 定义请求头


  try {
    const response: AxiosResponse = await axios.post(
      getURL,
      data, // 请求体数据
      { headers: headers } // 请求头配置
    );
    console.info(`Response succeeded: ${JSON.stringify(response.data)}`);
    prompt.showToast({message:`操作成功`}) ;

  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      if(axiosError.response?.status == 401)
      {
        prompt.showToast({message:`操作失败`}) ;
      }
      else {
        console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
        prompt.showToast({message:`请求失败: ${axiosError.message}`}) ;
        AlertDialog.show({
          title:"操作失败",
          message:"请检查网络"
        })
      }

    } else {
      console.error(`An unexpected error occurred: ${error}`);
      prompt.showToast({message:`发生未知错误: ${error}`}) ; ;
    }
  }
}

export {get_info,get_order_list,change_statue}