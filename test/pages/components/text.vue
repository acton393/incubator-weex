<template>
  <scroller>
      <text class="txt" coretext='false'>default is black</text>
      <text class="txt" coretext='false' style="color:#286090">#286090</text>
      <text class="txt" coretext='false' style="color:#0f0">#0f0</text>
      <text class="txt" coretext='false' style="color:red">keyword</text>
      <text class="txt" coretext='false' style="color:rgb(238, 162, 54)">rgb(238, 162, 54)</text>
      <text class="txt" coretext='false' test-id='test-text' style="color:rgba(238, 162, 54, 0.5)">rgba(238, 162, 54, 0.5)</text>

      <text class="txt" coretext='false' style="font-size: 32px;">32</text>
      <text class="txt" coretext='false' style="font-size: 64px;">64</text>
      <text class="txt" coretext='false' style="font-size: 100px;">100</text>


      <text class="txt" coretext='false' style="font-style: normal">normal</text>
      <text class="txt" coretext='false' style="font-style: italic">italic</text>


      <text class="txt" coretext='false' style="font-weight: normal">normal</text>
      <text class="txt" coretext='false' style="font-weight: bold">bold</text>

      <text class="txt" coretext='false' style="text-decoration: none">none</text>
      <text class="txt" coretext='false' style="text-decoration: underline">underline</text>
      <text class="txt" coretext='false' style="text-decoration: line-through">line-through</text>


      <text class="txt" coretext='false' style="text-align: left">left</text>
      <text class="txt" coretext='false' style="text-align: center">center</text>
      <text class="txt" coretext='false' style="text-align: right">right</text>

      <text class="txt" coretext='false' style="lines:1">no text-overflow, no text-overflow</text>
      <text class="txt" coretext='false' style="text-overflow:clip;width:450px;lines:1">text-overflow: clip, text-overflow: clip</text>
      <text class="txt" coretext='false' style="text-overflow:ellipsis;width:450px;lines:1">text-overflow: ellipsis, text-overflow: ellipsis</text>

      <text class="txt" coretext='false' style='border-width:2px' >no lineheight setting</text>
      <text class="txt" coretext='false' style="line-height: 50px;border-width:2px">lineheight 50</text>
      <text class="txt" coretext='false' style="line-height: 80px;border-width:2px"> lineheight 80</text>

  </scroller>
</template>

<style>
  .txt {
    margin-bottom: 12px;
    font-size: 20px;
  }
</style>