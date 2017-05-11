<template>
  <scroller>
    <text class="txt">default is black</text>
      <text class="txt" style="color:#286090">#286090</text>
      <text class="txt" style="color:#0f0">#0f0</text>
      <text class="txt" style="color:red">keyword</text>
      <text class="txt" style="color:rgb(238, 162, 54)">rgb(238, 162, 54)</text>
      <text class="txt" test-id='test-text' style="color:rgba(238, 162, 54, 0.5)">rgba(238, 162, 54, 0.5)</text>
  </scroller>
</template>

<style>
  .txt {
    margin-bottom: 12px;
    font-size: 40px;
  }
</style>