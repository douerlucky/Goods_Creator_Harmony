import AI_image_testTest from './AI_image_test.test'
import select_creatTest from './select_creat.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  select_creatTest()
  AI_image_testTest()
}