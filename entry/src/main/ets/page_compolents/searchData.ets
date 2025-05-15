import axios, { AxiosError, AxiosHeaders, AxiosResponse } from '@ohos/axios';
import {Updated_Badge} from '../class/Badge'
import * as server from '../class/ServerKits'
interface lyrics_information {
  lid: number;
  title: string;
  cv: string;
  lyric_url: string;
}

const headers = new AxiosHeaders({
  'Content-Type': 'application/json',
});

interface Data {
  keyword: string;
}

let lyrics: lyrics_information[] = [];

async function search_lyrics(query_name: string) {
  console.log("搜索的名字是", query_name);
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/lyrics/search`;
  const data: Data = {
    keyword: query_name
  };

  try {
    const response: AxiosResponse<lyrics_information[]> = await axios.post(
      getURL,
      data,
      { headers: headers }
    );

    // 直接将返回的数组赋值给 lyrics
    lyrics = response.data;
    return lyrics;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      AlertDialog.show({
        title: "搜索失败",
        message: "发生错误"
      });
    } else {
      console.error(`An unexpected error occurred: ${error}`);
    }
    return lyrics;
  }
}

interface bgms_information {
  bgmid: number;
  title: string;
  author: string;
  bgm_url: string;
}
let bgms: bgms_information[] = [];

async function search_bgms(query_name: string) {
  console.log("搜索的名字是", query_name);
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/bgms/search`;
  const data: Data = {
    keyword: query_name
  };

  try {
    const response: AxiosResponse<bgms_information[]> = await axios.post(
      getURL,
      data,
      { headers: headers }
    );

    // 直接将返回的数组赋值给 lyrics
    bgms = response.data;
    return bgms;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      AlertDialog.show({
        title: "搜索失败",
        message: "发生错误"
      });
    } else {
      console.error(`An unexpected error occurred: ${error}`);
    }
    return bgms;
  }
}



interface Data_uid{
  uid:string
  query_name:string
}

let badges: Updated_Badge[] = [];

async function search_user_Badges(query_uid: string,query_name:string) {
  console.log("搜索的名字是", query_uid);
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/badges/user_badge_search`;
  const data: Data_uid = {
    uid: query_uid,
    query_name : query_name
  };

  try {
    const response: AxiosResponse<Updated_Badge[]> = await axios.post(
      getURL,
      data,
      { headers: headers }
    );

    // 直接将返回的数组赋值给 lyrics
    badges = response.data;
    return badges;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      AlertDialog.show({
        title: "搜索失败",
        message: "发生错误"
      });
    } else {
      console.error(`An unexpected error occurred: ${error}`);
    }
    return badges;
  }
}

async function search_public_badge(query_uid: string,query_name:string) {
  console.log("搜索的名字是", query_name);
  const getURL = `${server.postBaseUrl}${server.databasePort}/api/db/badges/search_public_badge`;
  const data: Data_uid = {
    uid: query_uid,
    query_name : query_name
  };

  try {
    const response: AxiosResponse<Updated_Badge[]> = await axios.post(
      getURL,
      data,
      { headers: headers }
    );

    // 直接将返回的数组赋值给 lyrics
    badges = response.data;
    return badges;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError: AxiosError = error;
      console.error(`Response err: Code is ${axiosError.response?.status}, message is ${axiosError.message}`);
      AlertDialog.show({
        title: "搜索失败",
        message: "发生错误"
      });
    } else {
      console.error(`An unexpected error occurred: ${error}`);
    }
    return badges;
  }
}

export { search_lyrics, search_bgms,search_user_Badges,search_public_badge };