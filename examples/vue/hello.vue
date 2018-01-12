<template>
    <div>
      <slider style="width: 750px; height: 2668px; ">
        <list style="width: 750;height:300px;">
          <cell v-for="item in list" style="margin-top: 6px; margin-bottom: 6px; background-color: green; width: 750px;">
            <div>
              <text>{{item}}</text>
            </div>
          </cell>
        </list>
        <waterfall
          class="container" 
          append="node" 
          column-width="369" 
          column-count="2" 
          column-gap="12" 
          show-scrollbar="false" 
          scrollable="true">
          <cell v-for="item in list" style="margin-top: 6px; margin-bottom: 6px; background-color: pink;">
            <div style="width: 369px; ">
              <text>{{item}}</text>
            </div>
          </cell>
        </waterfall>
      </slider>
    </div>
</template>
<style scoped>
    .container {
      width: 750px;
      background-color: #999999;
    }
</style>
<script>
export default {
	data() {
	  return {
	    list: ["3r23r2护腕gu'ru'd'h'f'w护腕故如待会发问姐额符合iu'w'h'f'iu'h'f护腕故如待会发问姐额符合iu我回复iu翰飞2h'f翰飞2f分hi分几f分几分ir23r23", 
	    '23423rwer23r23', '23423rwfewuify82y34f834738er23r23', '23423uwgfeug8f2t8fwbefy82y284ffgrwer23r23', 
	    '23423rwer23r23', '23423rwer23r23', '23423rwersfduhewfy82374tf87wfy23r23', '23423rwer23r23']
	  }
	},
	methods: {}
};</script>