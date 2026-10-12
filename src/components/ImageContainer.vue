<template>
  <div>
    <canvas
      style="width: 100%; height: 100%"
      v-if="isScrFile"
      width="256"
      height="192"
      :id="item.filename"
      @mouseup="fastFinishScreen"
    />
    <v-img
      v-if="!isScrFile"
      :src="getScreenUrl(item.url)"
      class="white--text align-end"
      :lazy-src="getDefaultImageSrc"
      :aspect-ratio="1.33"
    >
      <template v-slot:placeholder>
        <v-row class="fill-height ma-0" align="center" justify="center">
          <v-progress-circular indeterminate color="black lighten-5"></v-progress-circular>
        </v-row> </template
    ></v-img><div v-if="xrated" class="ribbon-wrapper">
    <div class="ribbon">X-RATED</div>
  </div>
  </div>
</template>
<script>
import imageHelper from "@/helpers/image-helper";
import axios from "axios";

const colors = [
  /* bright 0 */
  "#000000",
  "#0000D7",
  "#D70000",
  "#D700D7",
  "#00D700",
  "#00D7D7",
  "#D7D700",
  "#D7D7D7",
  /* brigth 1 */
  "#000000",
  "#0000FF",
  "#FF0000",
  "#FF00FF",
  "#00FF00",
  "#00FFFF",
  "#FFFF00",
  "#FFFFFF",
];

export default {
  name: "ImageContainer",
  props: ["item", "xrated"],
  data() {
    return {
      scrData: [],
      attrData: [],
      canvas: null,
      cw: null,
      ch: null,
      active: false,
      isScrFile: false,
      datapos: 0,
      pixmap: [], // full color version 192x256 pixels (with attr)
      fastload: false,
      delay: 10, // 500ms
      started: null,
    };
  },
  computed: {
    getDefaultImageSrc() {
      return imageHelper.DEFAULT_SRC;
    },
  },
  methods: {
    getScreenUrl: imageHelper.getScreenUrl,
    blue() {
      this.canvas.fillStyle = "blue";
      this.canvas.fillRect(0, 0, this.cw, this.ch);
    },
    fastFinishScreen() {
      this.fastload = true;
    },

    loadScreen(data) {
      // initialize data for screen draw
      var c = document.getElementById(this.item.filename);
      this.canvas = c.getContext("2d");

      this.scrData = data.slice(0, 6144);
      this.attrData = data.slice(6144, 6912);
      this.datapos = 0;
      this.cw = c.width;
      this.ch = c.height;
      if (this.$isDevelopment) console.log(`ImageContainer - loadScreen(): width: ${this.cw}, height: ${this.ch}`);
      // clear screen
      this.canvas.fillStyle = colors[7];
      this.canvas.fillRect(0, 0, c.width, c.height);
      for (var y = 0; y < 192; y++) {
        this.pixmap[y] = [];
      }

      this.active = true;
      this.delay = 0;
      this.fastload = false;
      this.running = setInterval(this.drawNextStep, this.delay);
      /*
		this.$nextTick(() => {
        this.drawNextStep();
	  });
	  */
      // setTimeout(this.drawNextStep, 500);
    },
    drawNextStep() {
      if (this.active && this.datapos < 6144) {
        // draw pixels
        const adr = 0x4000 + this.datapos;
        const y = ((adr & 0b0000011100000000) >> 8) + ((adr & 0b0000000011100000) >> 2) + ((adr & 0b0001100000000000) >> 5);
        const x = adr & 0b00011111;
        var byte = this.scrData[this.datapos];
        for (var b = 0; b < 8; b++) {
          var color;
          var pixel;
          if (byte & (128 >> b)) {
            color = colors[0];
            pixel = 1;
          } else {
            color = colors[7];
            pixel = 0;
          }
          this.canvas.fillStyle = color;
          this.canvas.fillRect(x * 8 + b, y, 1, 1);
          this.pixmap[y][x * 8 + b] = pixel;
        }
        this.datapos++;
      } else if (this.active && this.datapos > 6143 && this.datapos < 6912) {
        const attrpos = this.datapos - 6144;
        const attrData = this.attrData[attrpos];
        const y = Math.trunc(attrpos / 32); // 0-23
        const x = attrpos % 32; // 0-31
        const inkval = ((attrData & 0b01000000) >> 3) + (attrData & 0b00000111);
        const ink = colors[inkval];
        const paperval = (attrData & 0b01111000) >> 3;
        const paper = colors[paperval];
        for (var dy = 0; dy < 8; dy++) {
          for (var dx = 0; dx < 8; dx++) {
            if (this.pixmap[y * 8 + dy][x * 8 + dx]) {
              this.canvas.fillStyle = ink;
            } else {
              this.canvas.fillStyle = paper;
            }
            this.canvas.fillRect(x * 8 + dx, y * 8 + dy, 1, 1);
          }
        }
        this.datapos++;
      } else {
        this.active = false;
        clearInterval(this.running);
        if (this.$isDevelopment) console.log("drawNext() - forced stopped");
      }
      if (this.active) {
        if (this.fastload) {
          this.$nextTick(() => {
            this.drawNextStep();
          });
        } else {
          //setTimeout(function() {}, 1);
        }
      }
    },
  },
  destroyed() {
    if (this.$isDevelopment) console.log("ImageContainer - destroyed(), stopping:");
    this.active = false;
  },
  mounted() {
    this.isScrFile = true;
    if (this.$isDevelopment) console.log("ImageContainer - mounted():");

    if (this.item.scrUrl && this.item.scrUrl.endsWith(".scr")) {
      if (this.$isDevelopment) console.log("ImageContainer - found .SCR file... good");
      this.isScrFile &= true;
    } else {
      this.isScrFile &= false;
    }
    if (this.item.type === "Loading screen") {
      if (this.$isDevelopment) console.log("ImageContainer - Loading screen... good");
      this.isScrFile &= true;
    } else {
      this.isScrFile &= false;
    }

    if (this.isScrFile) {
      if (this.$isDevelopment) console.log(`ImageContainer - .SCR found: ${this.item.scrUrl}`);
      // load .SCR file into scrdata;
      const scrURL = `/media${this.item.scrUrl}`;
      axios.get(scrURL, { responseType: "arraybuffer" }).then((response) => {
        const bytes = Array.from(new Uint8Array(response.data));
        this.loadScreen(bytes);
      });
    }
  },
  beforeCreate() {
    if (this.$isDevelopment) console.log("ImageContainer - beforeCreate()");
  },
  created() {
    if (this.$isDevelopment) console.log("ImageContainer - created()");
  },
  beforeMount() {
    if (this.$isDevelopment) console.log("ImageContainer - beforeMount()");
  },
  beforeUpdate() {
    if (this.$isDevelopment) console.log("ImageContainer - beforeUpdate()");
  },
  updated() {
    if (this.$isDevelopment) console.log("ImageContainer - updated()");
  },
  beforeDestroy() {
    if (this.$isDevelopment) console.log("ImageContainer - beforeDestroy()");
  },
};
</script>
<style scoped>
.ribbon-wrapper {
  width: 85px;
  height: 88px;
  overflow: hidden;
  position: absolute;
  top: -3px;
  left: -3px;}
  .ribbon {
    font: bold 15px sans-serif;
    color: #333;
    text-align: center;
    transform: rotate(-45deg);
    position: relative;
    padding: 7px 0;
    top: 15px;
    left: -30px;
    width: 120px;
    background-color: #91000084;
    color: #fff;
  }</style>
