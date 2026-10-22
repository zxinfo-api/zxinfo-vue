<template>
  <v-container v-if="!loading" justify-start class="scroll-y pa-0" fluid>
    <v-row
      ><v-col cols="12" justify="center" class="py-0 ma-0">
        <v-toolbar dense dark color="grey" class="pa-0">
          <v-spacer />
          <v-icon>{{ getMagazineTypeIcon(mag.type) }}</v-icon
          ><v-toolbar-title class="white--text"
            >{{ mag.name }} - {{ mag.publisher }} ({{ mag.country }}), {{ mag.language }}
          </v-toolbar-title>
          <v-spacer />
        </v-toolbar> </v-col
    ></v-row>
    <v-row :align="'start'" :justify="'start'">
      <v-col v-for="(card, index) in mag.issues" :key="index" cols="12" sm="6" md="4" class="pa-1">
        <v-card dark class="pa-2">
          <div class="d-flex flex-no-wrap justify-space-between">
            <div>
              <v-card-title class="headline">Issue: {{ card.number }}</v-card-title>

              <v-card-subtitle
                >Year: {{ card.date_year }}, Month: {{ card.date_month }}
                <div v-if="card.special">Special: {{ card.special }}</div>
              </v-card-subtitle>
              <v-card-actions>
                <v-btn class="ml-2 mt-5" outlined rounded small :to="`/magazines/${encodeURIComponent(mag.name)}/issues/${card.id}`">
                  Info
                </v-btn></v-card-actions
              >
            </div>
            <v-img
              :lazy-src="getDefaultImageSrc"
              :aspect-ratio="9 / 16"
              max-height="300"
              max-width="200"
              :src="getScreenUrl(card.cover_image)"
            ></v-img>
          </div>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import axios from "axios";
import imageHelper from "@/helpers/image-helper";

export default {
  name: "Magazines",
  metaInfo() {
    return {
      title: "ZXInfo - The open source ZXDB frontend",
    };
  },
  data() {
    return {
      mag: [],
      loading: false,
    };
  },
  computed: {
    getDefaultImageSrc() {
      return imageHelper.DEFAULT_PAPER_SRC;
    },
  },
  methods: {
    getScreenUrl: imageHelper.getScreenUrl,
    getMagazineTypeIcon(t) {
      switch (t) {
        case "PAPER":
          return "mdi-book-open-variant";
        case "TAPE":
          return "mdi-cassette";
        case "DISK":
          return "mdi-floppy-variant";
        default:
          return "help";
      }
    },
  },
  mounted() {
    this.isLoading = true;

    var dataURL = this.$api_base_url + `/magazines/${this.$route.params.name}/issues`;
    if (this.$isDevelopment) console.log(`DetailView.vue - loadentry(): calling ZXInfo API ${dataURL}`);
    axios
      .get(dataURL)
      .then((response) => {
        this.mag = response.data;
        this.loading = false;
      })
      .catch((error) => {
        console.log(error);
        this.completeOptions = [];
        this.errormessage = error.code + ": " + error.message;
        this.isLoadingOptions = false;
      })
      .finally(() => {
        this.loading = false;
      });
  },
};
</script>
<style scoped></style>
