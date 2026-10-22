<template>
  <v-card flat tile height="100%" width="100%">
    <v-container fluid>
      <v-row align="start" justify="center">
        <v-sheet dark width="100%">
          <v-slide-group show-arrows>
            <v-slide-item v-for="n in getLetters" :key="n">
              <v-btn plain small text tile @click="byLetter(n)">{{ n }} </v-btn></v-slide-item
            >
          </v-slide-group>
        </v-sheet></v-row
      ></v-container
    >
    <v-container class="fill-height" fluid>
      <v-row align="center" justify="center">
        <v-col :xl="8" :lg="8" :md="8" :sm="8" :xs="12">
          <v-card flat>
            <v-card-text>
              <div>
                <SearchInput v-model="searchText" />
                <div class="text-center">
                  <v-btn elevation="0" small @action="search">ZXDB search</v-btn>&nbsp;
                  <v-btn elevation="0" small @click="random">I'm Feeling Lucky</v-btn>
                </div>
                <p></p>
                <p class="text-center .caption .font-weight-thin"><router-link :to="{ path: '/whatsnew'}">ZXDB update October 22nd. 2026</router-link>
                  </p>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row></v-container
    >
  </v-card>
</template>
<script>
import SearchInput from "@/components/SearchInput";
import axios from "axios";

export default {
  name: "Home",
  metaInfo() {
    return {
      title: "ZXInfo - The open source ZXDB frontend",
    };
  },
  data() {
    return {
      searchText: "",
    };
  },
  components: { SearchInput },
  computed: {
    getLetters: function() {
      var letters = ["#"];
      for (var i = 65; i < 91; i++) {
        letters.push(String.fromCharCode(i));
      }
      return letters;
    },
  },
  methods: {
    search() {
      this.$router.push({ path: `/search/${encodeURIComponent(this.searchText)}` });
    },
    random() {
      const dataURL = `${this.$api_base_url}/entries/random/1?mode=tiny`;
      if (this.$isDevelopment) console.log(`Home.vue - reandom(): calling ZXInfo API ${dataURL}`);
      axios
        .get(dataURL, { timeout: 500 })
        .then((response) => {
          const entry_id = response.data.hits.hits[0]._id;
          this.$router.push({ path: `/details/${entry_id}` });
        })
        .catch((error) => {
          console.log(error);
        });
    },
    byLetter(l) {
      this.$router.push({ path: `/letter/${encodeURIComponent(l)}` });
    },
  },
  watch: {
    searchText(v) {
      if (this.$isDevelopment) console.log("watch: " + v);
      if (v === Object(v)) {
        if (this.$isDevelopment) console.log("Got object: " + v.text);
        this.searchText = v.text;
      } else {
        if (this.$isDevelopment) console.log("plain value: " + v);
      }
      this.search();
    },
  },
  mounted() {
    // fire event to parent
    this.$emit("updateContenttype", "");
  },
};
</script>
