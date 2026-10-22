<template>
  <v-container v-if="!loading" class="pa-0 fill-height" fluid>
    <v-row
      ><v-col cols="12" justify="center" class="py-0 ma-0">
        <v-toolbar dense dark color="grey" class="pa-0">
          <v-spacer />
          <v-toolbar-title class="white--text">
            magazines
          </v-toolbar-title>
          <v-spacer />
        </v-toolbar> </v-col
    ></v-row>
    <v-row>
      <v-col cols="12" md="6">
        <v-simple-table>
          <template v-slot:default>
            <thead>
              <tr>
                <th class="text-left">
                  Name
                </th>
                <th class="text-left">
                  Publisher
                </th>
                <th class="text-left">
                  Language
                </th>
                <th class="text-left">
                  Type
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in filteredItems(1, 2)" :key="item.name">
                <td>
                  <router-link :to="{ path: '/magazines/' + encodeURIComponent(item.name) }">{{ item.name }}</router-link>
                </td>
                <td>{{ item.publisher }}</td>
                <td>{{ item.language }}</td>
                <td>
                  <v-icon>{{ getMagazineTypeIcon(item.type) }}</v-icon>
                </td>
              </tr>
            </tbody>
          </template>
        </v-simple-table>
      </v-col>
      <v-col cols="12" md="6">
        <v-simple-table>
          <template v-slot:default>
            <thead>
              <tr>
                <th class="text-left">
                  Name
                </th>
                <th class="text-left">
                  Publisher
                </th>
                <th class="text-left">
                  Language
                </th>
                <th class="text-left">
                  Type
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in filteredItems(2, 2)" :key="item.name">
                <td>
                  <router-link :to="{ path: '/magazines/' + item.name }">{{ item.name }}</router-link>
                </td>
                <td>{{ item.publisher }}</td>
                <td>{{ item.language }}</td>
                <td>
                  <v-icon>{{ getMagazineTypeIcon(item.type) }}</v-icon>
                </td>
              </tr>
            </tbody>
          </template>
        </v-simple-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import axios from "axios";

export default {
  name: "Magazines",
  metaInfo() {
    return {
      title: "ZXInfo - The open source ZXDB frontend",
    };
  },
  data() {
    return {
      magazineItems: [],
      loading: false,
    };
  },
  computed: {},
  methods: {
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
    filteredItems(column, columns) {
      const self = this; // Enables us to pass this to the method
      const total = this.magazineItems.length; // How many items
      const gap = Math.ceil(total / columns); // How many per col
      let top = gap * column; // Top of the col
      const bottom = top - gap + 1; // Bottom of the col
      top -= 1; // Adjust top back down one
      return self.magazineItems.filter(
        (item) => self.magazineItems.indexOf(item) >= bottom && self.magazineItems.indexOf(item) <= top
      ); // Return the items for the given col
    },
  },
  mounted() {
    this.isLoading = true;

    var dataURL = this.$api_base_url + "/magazines/";
    if (this.$isDevelopment) console.log(`DetailView.vue - loadentry(): calling ZXInfo API ${dataURL}`);
    axios
      .get(dataURL)
      .then((response) => {
        var magazineList = response.data.hits.hits;
        for (var i = 0; i < magazineList.length; i++) {
          var item = magazineList[i]._source;
          item.magazine_id = magazineList[i]._id;
          this.magazineItems.push(item);
        }
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
