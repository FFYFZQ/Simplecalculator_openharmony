/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants } from '../common/constants/CommonConstants';
import { CalculateModel } from '../model/CalculateModel';
import { PressKeysItem } from '../viewmodel/PressKeysItem';
import keysModel from '../viewmodel/PresskeysViewModel';

@Entry
@Component
struct HomePage {
  // 注意：如果 CalculateModel 中修改了类型，这里传入 this 不会报错
  private model: CalculateModel = new CalculateModel(this);
  @State inputValue: string = '';
  @State calValue: string = '';

  /**
   * 辅助方法：判断当前按键是否为等号（即最后一个按键）
   * 必须提取为非 Builder 的普通方法，因为 Builder 内部不能写 const/let 逻辑
   */
  private isEqualsKey(colIndex: number, rowIndex: number, colItemsLength: number): boolean {
    const isLastCol = colIndex === (keysModel.getPressKeys().length - 1);
    const isLastRow = rowIndex === (colItemsLength - 1);
    return isLastCol && isLastRow;
  }

  /**
   * 构建单个按键组件
   */
  @Builder
  KeyButton(keyItem: PressKeysItem, colIndex: number, rowIndex: number, colItems: Array<PressKeysItem>) {
    Column() {
      Column() {
        if (keyItem.flag === 0) {
          Image(keyItem.source !== undefined ? keyItem.source : '')
            .width(keyItem.width)
            .height(keyItem.height)
        } else {
          Text(keyItem.value)
            .fontSize(
              (keyItem.value === CommonConstants.DOTS) ?
              $r('app.float.font_size_dot') : $r('app.float.font_size_text')
            )
            .width(keyItem.width)
            .height(keyItem.height)
        }
      }
      .width($r('app.float.key_width'))
      // 修复点：直接调用方法判断，不使用局部变量
      .height(this.isEqualsKey(colIndex, rowIndex, colItems.length) ? $r('app.float.equals_height') : $r('app.float.key_height'))
      .borderWidth(1)
      .borderColor($r('app.color.border_color'))
      .borderRadius($r('app.float.border_radius'))
      // 修复点：直接调用方法判断
      .backgroundColor(this.isEqualsKey(colIndex, rowIndex, colItems.length) ? $r('app.color.equals_back_color') : Color.White)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (keyItem.flag === 0) {
          this.model.inputSymbol(keyItem.value);
        } else {
          this.model.inputNumber(keyItem.value);
        }
      })
    }
    // 修复点：直接调用方法判断
    .layoutWeight(this.isEqualsKey(colIndex, rowIndex, colItems.length) ? CommonConstants.TWO : 1)
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // 1. 输入显示区域
      Column() {
        TextInput({ text: this.model.resultFormat(this.inputValue) })
          .height(CommonConstants.FULL_PERCENT)
          .fontSize(
            (this.inputValue.length > CommonConstants.INPUT_LENGTH_MAX) ?
            $r('app.float.font_size_text') : $r('app.float.font_size_input')
          )
          .enabled(false)
          .fontColor(Color.Black)
          .textAlign(TextAlign.End)
          .backgroundColor($r('app.color.input_back_color'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.input_height'))
      .alignItems(HorizontalAlign.End)
      .margin({
        right: $r('app.float.input_margin_right'),
        top: $r('app.float.input_margin_top')
      })

      // 2. 计算结果预览区域
      Column() {
        Text(this.model.resultFormat(this.calValue))
          .fontSize($r('app.float.font_size_text'))
          .fontColor($r('app.color.text_color'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.text_height'))
      .alignItems(HorizontalAlign.End)
      .margin({
        right: $r('app.float.text_margin_right'),
        bottom: $r('app.float.text_margin_bottom')
      })

      // 3. 键盘区域
      Column() {
        Row() {
          ForEach(keysModel.getPressKeys(), (columnItem: Array<PressKeysItem>, columnItemIndex: number) => {
            Column() {
              ForEach(columnItem, (keyItem: PressKeysItem, keyItemIndex: number) => {
                // 调用 Builder 构建按键
                this.KeyButton(keyItem, columnItemIndex, keyItemIndex, columnItem)
              }, (keyItem: PressKeysItem) => JSON.stringify(keyItem))
            }
            .layoutWeight(1)
          }, (item: Array<Array<PressKeysItem>>) => JSON.stringify(item))
        }
        .height(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Top)
        .margin({
          left: $r('app.float.margin_left'),
          right: $r('app.float.margin_right')
        })
      }
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.row_back_color'))
    }
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.column_back_color'))
  }
}