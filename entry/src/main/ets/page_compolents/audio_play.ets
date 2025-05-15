import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';

@Entry
@Component
struct a {
  build() {
  }
}

export class AVPlayerDemo {
  public avPlayer: media.AVPlayer | null = null;
  async setPlayUrl(url: string) {
    if (this.avPlayer) {
      // 释放旧实例
      this.avPlayer.stop();
      this.avPlayer.reset();
      this.avPlayer.release();
    }
    // 创建新实例
    this.avPlayer = await media.createAVPlayer();
    this.setAVPlayerCallback(this.avPlayer);
    this.avPlayer.url = url;
    await this.avPlayer.prepare(); // 等待准备完成
  }

  // 注册avplayer回调函数。
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    // seek操作结果回调函数。
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程。
    avPlayer.on('error', (err: BusinessError) => {
      console.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      avPlayer.reset(); // 调用reset重置资源，触发idle状态。
    });
    // 状态机变化回调函数。
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报。
          console.info('AVPlayer state idle called.');
          avPlayer.release(); // 调用release接口销毁实例对象。
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报。
          console.info('AVPlayer state initialized called.');
          avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC, // 音频流使用类型：音乐。根据业务场景配置，参考StreamUsage。
            rendererFlags: 0 // 音频渲染器标志。
          };
          avPlayer.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机。
          console.info('AVPlayer state prepared called.');
          avPlayer.play(); // 调用播放接口开始播放。
          break;
        case 'playing': // play成功调用后触发该状态机上报。
          console.info('AVPlayer state playing called.');
          break;
        case 'paused': // pause成功调用后触发该状态机上报。
          console.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报。
          console.info('AVPlayer state completed called.');
          avPlayer.stop(); // 调用播放结束接口。
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报。
          console.info('AVPlayer state stopped called.');
          avPlayer.reset(); // 调用reset接口初始化avplayer状态。
          break;
        case 'released':
          console.info('AVPlayer state released called.');
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    });
  }

  // 以下demo为通过url设置网络地址来实现播放直播码流的demo。
  async avPlayerLiveDemo(url: string) {
    // 创建avPlayer实例对象。
    this.avPlayer = await media.createAVPlayer();
    // 创建状态机变化回调函数。
    this.setAVPlayerCallback(this.avPlayer);
    this.avPlayer.url = url;
  }

  // 播放（若未准备好则先准备）
  play() {
    if (this.avPlayer && this.avPlayer.state === 'prepared') {
      this.avPlayer.play();
    } else if (this.avPlayer) {
      this.avPlayer.prepare(); // 重新准备播放
    }
  }

  // 重新播放（重置并从头开始）
  replay() {
    if (this.avPlayer) {
      this.avPlayer.seek(0); // 回到开头
      this.play(); // 调用播放
    }
  }


  // 新增：暂停播放方法
  pause() {
    if (this.avPlayer) {
      this.avPlayer.pause(); // 调用AVPlayer原生暂停接口
      console.info('AVPlayer paused');
    } else {
      console.error('AVPlayer is not initialized. Cannot pause.');
    }
  }
  togglePlayPause() {
    if (!this.avPlayer) return;

    if (this.avPlayer.state === 'playing') {
      this.avPlayer.pause();
    } else if (this.avPlayer.state === 'paused') {
      this.avPlayer.play();
    } else if (this.avPlayer.state === 'prepared') {
      this.avPlayer.play();
    } else {
      this.avPlayer.prepare();
    }
  }


  release() {
    if (this.avPlayer) {
      this.avPlayer.stop(); // 停止播放
      this.avPlayer.reset(); // 重置状态机
      this.avPlayer.release(); // 释放底层资源
      this.avPlayer = null; // 置空引用
      console.info('AVPlayer resources released');
    }
  }

}
