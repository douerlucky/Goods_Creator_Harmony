import { describe, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { UIAbility, Want } from '@kit.AbilityKit';

const delegator = abilityDelegatorRegistry.getAbilityDelegator();
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

export default function UploadPictureTest() {
  describe('UploadPictureTest', () => {
    it('testUiExample', 0, async (done: Function) => {
      console.info("uitest: TestUiExample begin");
      // 替换为实际的Ability名称，根据config.json可知是EntryAbility
      const want: Want = {
        bundleName: bundleName,
        abilityName: 'EntryAbility'
      };

      await delegator.startAbility(want);
      await sleep(8000); // 确保组件渲染（根据实际加载速度调整）

      const ability = await delegator.getCurrentTopAbility() as UIAbility;
      // 断言Ability名称正确
      expect(ability.context.abilityInfo.name).assertEqual('EntryAbility');

      const driver = Driver.create() as Driver;
      await driver.delayMs(1000);

      // 输入框操作（增加非空校验，避免null引用）
      const input = await driver.findComponent(ON.id('promptInput'));
      if (!input) {
        console.error('输入框未找到，请检查ID或布局');
        done(new Error('输入框未找到')); // 主动失败并提示
        return;
      }
      await input.click();
      // 修复inputText参数，传递文本和坐标
      await driver.inputText({ x: 0, y: 0 },'蓝发少女');

      // 生成按钮操作
      const button = await driver.findComponent(ON.id('generateBtn'));
      if (!button) {
        console.error('生成按钮未找到，请检查ID');
        done(new Error('生成按钮未找到'));
        return;
      }
      await button.click();

      // 等待AI生成（根据实际接口耗时调整，建议15 - 30秒）
      await sleep(15000);

      // 图片组件断言（核心验证点）
      const image = await driver.findComponent(ON.id('generatedImg'));
      if (!image) {
        console.error('图片组件未渲染');
        done(new Error('图片组件未找到'));
        return;
      }
      //expect(image).not.toBeNull(); // 确保组件存在

      await driver.pressBack();
      done();
    });
  });
}