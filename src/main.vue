<template>
  <v-app id="inspire">
    <keep-alive>
      <navigationmenu v-model="drawer"></navigationmenu>
    </keep-alive>
    <!-- FAB button for scroll to top -->
    <v-btn v-scroll="onScroll" v-show="fab" fab dark fixed bottom right color="primary" @click="toTop">
      <v-icon>keyboard_arrow_up</v-icon>
    </v-btn>

    <v-app-bar app clipped-left dark color="black">
      <v-app-bar-nav-icon title="MENU" @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <template
        v-if="!$vuetify.breakpoint.xs || this.isByLetter || this.isHome || this.isGraphPage || this.isAnimatedLoadingPage">
        <v-toolbar-title>
          <router-link title="HOME" to="/"
            class="text-decoration-none text-h4 font-weight-black white--text">ZXInfo</router-link>
        </v-toolbar-title>
        <v-spacer></v-spacer>
      </template>
      <div v-if="$isDevelopment">{{ $vuetify.breakpoint.name }} - {{ this.$route.name }}</div>

      <!-- search bar -->
      <v-toolbar v-if="showSearchBar" flat class="py-4" color="black" min-width="75%">
        <v-combobox @change="showinfo" @keypress="showAutoselectMenu" @keyup.enter="submitSearch"
          :menu-props="{ value: autoselectMenu }" v-model="completeSelected" :items="completeOptions"
          :loading="isLoadingOptions" :search-input.sync="searchTerm" hide-no-data no-filter item-text="text"
          item-value="text" :label="labelText" :prepend-inner-icon="'mdi-magnify'" @click:prepend-inner="submitSearch"
          @click:append-outer="filterdrawer = !filterdrawer"
          :append-outer-icon="isEntrySearch ? 'mdi-filter-variant' : ''" clearable return-object dense
          :error="errormessage !== ''" :error-messages="errormessage" full-width solo>
          <template v-slot:item="{ item }">
            <div v-if="isEntrySearch || isDetailPage">
              <v-icon v-if="item.type == 'SOFTWARE'" left>games</v-icon><v-icon v-if="item.type == 'BOOK'"
                left>book</v-icon><v-icon v-if="item.type == 'HARDWARE'" left>mouse</v-icon>
              <v-icon v-if="['AUTHOR', 'PUBLISHER'].includes(item.type) && item.labeltype.startsWith('Company')"
                left>mdi-bank</v-icon>
              <v-icon v-if="['AUTHOR', 'PUBLISHER'].includes(item.type) && item.labeltype.startsWith('Person')"
                left>mdi-account</v-icon>
              <v-icon v-if="['AUTHOR', 'PUBLISHER'].includes(item.type) && item.labeltype.startsWith('Nickname')"
                left>mdi-account-multiple</v-icon>
              <v-icon v-if="['AUTHOR', 'PUBLISHER'].includes(item.type) && item.labeltype == ''"
                left>mdi-map-marker-question</v-icon>
              <span v-html="highlight(item.text)"></span>
            </div>
            <div v-if="isPublisherPage || isAuthorPage">
              <v-icon v-if="item.labeltype.startsWith('Company')" left>mdi-bank</v-icon><v-icon
                v-if="item.labeltype.startsWith('Person')" left>mdi-account</v-icon><v-icon
                v-if="item.labeltype.startsWith('Nickname')" left>mdi-account-multiple</v-icon><v-icon
                v-if="item.labeltype == ''" left>mdi-map-marker-question</v-icon>
              <span v-html="highlight(item.text)"></span>
            </div>
          </template>
        </v-combobox>
      </v-toolbar>

      <v-spacer />
      <v-icon>{{ getContenttypeIcon }}</v-icon>
      <v-img src="@/assets/rainbow2.jpg" max-width="48"></v-img>
    </v-app-bar>

    <!-- Navigation drawer - filters -->
    <v-navigation-drawer app temporary right v-model="filterdrawer" width="340">
      <template>
        <v-card>
          <v-toolbar color="teal" dark>
            <v-toolbar-title>Filtering options</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon @click="resetfilters">
              <v-icon>mdi-restore</v-icon>
            </v-btn>
          </v-toolbar>

          <v-list dense>
            <v-list-group :prepend-icon="group.icon" no-action v-for="(group, key) in activeFacets" :key="key">
              <template v-slot:activator>
                <v-list-item-content>
                  <v-list-item-title>{{ group.title }} {{ group.items.length }} option(s)</v-list-item-title>
                </v-list-item-content>
              </template>
              <v-list-item v-for="subItem in group.items" :key="subItem.key">
                <v-list-item-action class="ma-0">
                  <v-checkbox color="primary" v-model="facets[key].selected"
                    :value="subItem.key.toString()"></v-checkbox>
                </v-list-item-action>
                <v-list-item-content class="py-0 pl-4">
                  <v-list-item-title v-text="subItem.key"></v-list-item-title>
                </v-list-item-content>
                <v-list-item-action class="ma-0">
                  <v-list-item-action-text v-text="subItem.doc_count"></v-list-item-action-text>
                </v-list-item-action>
              </v-list-item>
            </v-list-group>
          </v-list>
          <v-divider></v-divider>
          <v-row align="center" justify="center">
            <v-col class="text-center" cols="4">
              <div class="my-2">
                <v-btn @click="searchFilters()" color="primary">FILTER</v-btn>
              </div>
            </v-col>
            <v-col class="text-center" cols="6">
              <div class="my-2">
                <v-btn @click="filterdrawer = !filterdrawer">CLOSE</v-btn>
              </div>
            </v-col>
          </v-row>
          <v-system-bar color="teal" window dark></v-system-bar>
        </v-card>
      </template>
    </v-navigation-drawer>

    <v-main><!-- v-container (fluid) -> v-row -> v-vol -->
      <router-view :facets="facets" :queryparameters="queryparameters" :pagesize="this.getPageSize"
        :pageindex="pageindex" :cards="cards" :allResults="allResults" :searchNumberOfResults="searchNumberOfResults"
        :searchTimeOf="searchTimeOf" :isLoading="isLoading" @loadMore="loadMore" @loadPage="loadPage"
        @replaceURL="replaceURL" class="view"></router-view></v-main>
    <v-footer app padless class="caption .font-weight-thin">
      <v-container fluid>
        <v-row justify="space-between" align="center" class="px-4">
          <span>&copy; 2026 info@zxinfo.dk</span>
          <span class="text-center"><a href="https://zxinfo-api.github.io/zxinfo-api-v5/">Public API</a></span><span><a
              href="https://github.com/thomasheckmann/zxinfo-vue">GitHub</a></span>
        </v-row></v-container>
    </v-footer>
  </v-app>
</template>
<script>
import navigationmenu from "@/components/NavigationMenu";
import axios from "axios";

// QUeryBuilder Helper
var buildQuery = function (data) {
  // If the data is already a string, return it as-is
  if (typeof data === "string") return data;

  // Create a query array to hold the key/value pairs
  var query = [];

  // Loop through the data object
  for (var key in data) {
    // eslint-disable-next-line no-prototype-builtins
    if (data.hasOwnProperty(key)) {
      // Encode each key and value, concatenate them into a string, and push them to the array

      if (typeof data[key] === "object") {
        let subitems = data[key];
        for (var items in subitems) {
          query.push(encodeURIComponent(key) + "=" + encodeURIComponent(subitems[items]));
        }
      } else {
        // if (this.$isDevelopment) console.log(`main.vue - buildQuery(): ${key} = ${encodeURIComponent(data[key])}`);
        query.push(encodeURIComponent(key) + "=" + encodeURIComponent(data[key]));
      }
    }
  }

  // Join each item in the array with a `&` and return the resulting string
  return query.join("&");
};

export default {
  name: "ZXInfoApp",
  metaInfo() {
    return {
      title: "ZXInfo - The open source ZXDB frontend",
    };
  },
  data() {
    return {
      contenttype: "",
      /* navigation */
      filterdrawer: null,
      drawer: false,
      fab: false,
      /* autocomplete / combobox */
      autoselectMenu: false,
      errormessage: "",
      completeSelected: null,
      completeOptions: [],
      isLoadingOptions: false,
      searchTerm: "",
      queryparameters: {
        group: { name: "group", value: "" },
        groupname: { name: "groupname", value: "" },
        contenttype: { name: "contenttype", value: "" },
        xrated: { name: "xrated", value: "" },
        mia: { name: "mia", value: "" },
      },
      facets: {
        // key = name in agg output, paramname = parameter name for search
        // must match filtere_<name> in JSON
        machinetypes: {
          aggName: "aggMachineTypes",
          icon: "mdi-desktop-classic",
          title: "Machine type",
          items: [],
          selected: [],
          paramname: "machinetype",
        },
        genretype: {
          aggName: "aggGenreType",
          icon: "mdi-drama-masks",
          title: "Genre type",
          items: [],
          selected: [],
          paramname: "genretype",
        },
        genresubtype: {
          aggName: "aggGenreSubType",
          icon: "mdi-drama-masks",
          title: "Subtype",
          items: [],
          selected: [],
          paramname: "genresubtype",
        },
        controls: {
          aggName: "aggControls",
          icon: "mdi-controller-classic",
          title: "Controls",
          items: [],
          selected: [],
          paramname: "control",
        },
        multiplayermode: {
          aggName: "aggMultiplayerMode",
          icon: "mdi-account-multiple-check",
          title: "Multiplayer mode",
          items: [],
          selected: [],
          paramname: "multiplayermode",
        },
        multiplayertype: {
          aggName: "aggMultiplayerType",
          icon: "mdi-account-multiple",
          title: "Multiplayer type",
          items: [],
          selected: [],
          paramname: "multiplayertype",
        },
        availability: {
          aggName: "aggAvailability",
          icon: "mdi-check-circle",
          title: "Availability",
          items: [],
          selected: [],
          paramname: "availability",
        },
        language: {
          aggName: "aggLanguage",
          icon: "mdi-message",
          title: "Language",
          items: [],
          selected: [],
          paramname: "language",
        },
        yearofrelease: {
          aggName: "aggOriginalYearOfRelease",
          icon: "mdi-timetable",
          title: "Year",
          items: [],
          selected: [],
          paramname: "year",
        },
      },
      isLoading: false,
      searchTimeOf: 0,
      searchNumberOfResults: 0,
      allResults: false,
      pagesize: this.getPageSize,
      pageindex: 0,
      titlesonly: false,
      cards: [],
    };
  },
  components: { navigationmenu },
  methods: {
    showAutoselectMenu() {
      this.autoselectMenu = true;
    },
    updateContenttype(status) {
      this.contenttype = status;
    },
    updateContenttypeIcon() {
      if (this.$route.query.contenttype) {
        this.updateContenttype(this.$route.query.contenttype);
      } else if (this.isPublisherPage) {
        this.updateContenttype("PUBLISHER");
      } else if (this.isAuthorPage) {
        this.updateContenttype("AUTHOR");
      } else {
        this.updateContenttype("");
      }
    },
    getParametersFromRequest() {
      // resetSearchResultialize parameters from request
      if (this.$isDevelopment) console.log("main.vue - getParametersFromRequest()");
      if (this.$route.params.query) {
        this.completeSelected = this.searchTerm = this.$route.params.query;
      } else {
        this.completeOptions = [];
      }
      // this.searchTerm = this.$route.params.query ? this.$route.params.query : "";
      for (var qp in this.queryparameters) {
        var paramname = this.queryparameters[qp].name;
        var queryvalue = this.$route.query[paramname];
        if (paramname !== "query" && queryvalue) {
          this.queryparameters[paramname].value = queryvalue;
        }
      }

      for (var agg in this.facets) {
        this.facets[agg].selected = Array.isArray(this.$route.query[this.facets[agg].paramname])
          ? this.$route.query[this.facets[agg].paramname]
          : [this.$route.query[this.facets[agg].paramname]];
      }
    },

    resetSearchResult() {
      if (this.$isDevelopment) console.log("main.vue - resetSearchResult()");
      this.isLoading = false;
      this.searchTimeOf = 0;
      this.searchNumberOfResults = 0;
      this.allResults = false;
      this.pageindex = 0;
      this.cards = [];
      this.searchTerm = "";
    },
    replaceURL() {
      // build URL for current selection
      if (this.$isDevelopment) console.log("main.vue - replaceURL()");
      const queryparam = this.searchTerm ? this.searchTerm : "";

      var filterquery = {};
      // Update URL query object with filter values for current selection
      for (var agg in this.facets) {
        var selected = [];
        for (var sel in this.facets[agg].selected) {
          if (this.facets[agg].selected[sel]) {
            selected.push(this.facets[agg].selected[sel]);
          }
        }

        filterquery[this.facets[agg].paramname] = selected;
      }

      // Update URL query object with filter values for current queryparameters
      for (var qp in this.queryparameters) {
        if (this.queryparameters[qp].value) {
          filterquery[this.queryparameters[qp].name] = this.queryparameters[qp].value;
        }
      }

      // fire event to parent
      if (this.queryparameters.contenttype) {
        this.updateContenttype(this.queryparameters.contenttype.value);
      } else {
        this.updateContenttype("");
      }
      var path;
      if (this.isEntrySearch || this.isDetailPage) path = "search";
      if (this.isPublisherPage) path = "publisher";
      if (this.isAuthorPage) path = "author";
      this.$router.replace({ path: `/${path}/${encodeURIComponent(queryparam)}`, query: filterquery }, () => { });
    },
    toggleNavigation() {
      this.filterdrawer = !this.filterdrawer;
    },
    showinfo() {
      if (this.$isDevelopment) {
        console.log("showinfo()");
        console.log("showinfo() - completeSelected: " + this.completeSelected);
        console.log("showinfo() - searchTerm: " + this.searchTerm);
      }
      if (!this.searchTerm && !this.completeSelected) {
        if (this.$isDevelopment) console.log("Nothing to do - probaly just cleared");
        return;
      }
      var selected = this.completeSelected;
      var selectedText;
      if (selected === Object(selected)) {
        selectedText = JSON.parse(JSON.stringify(selected)).text;
      } else {
        selectedText = selected;
      }
      if (this.$isDevelopment) console.log("showinfo() - searchText: " + selectedText);
      this.searchTerm = selectedText;
      this.submitSearch();
    },
    submitSearch() {
      if (this.$isDevelopment) {
        console.log("submitSearch()");
        console.log("submitSearch() - completeSelected: " + this.completeSelected);
        console.log("submitSearch() - searchTerm: " + this.searchTerm);
      }

      this.autoselectMenu = false;
      this.replaceURL();
    },
    /* NAVIGATION FILTERS */
    searchFilters() {
      if (this.$isDevelopment) {
        console.log("searchFilters()");
      }
      this.filterdrawer = false;
      this.replaceURL();
    },
    resetfilters() {
      if (this.$isDevelopment) console.log("resetfilters()");
      for (var agg in this.facets) {
        this.facets[agg].selected = [];
      }
      for (var qp in this.queryparameters) {
        this.queryparameters[qp].value = "";
      }

      this.filterdrawer = false;
      // this.searchText = "";
      this.$route.params.query = "";
      this.replaceURL();
    },
    loadPage(p) {
      this.resetSearchResult();
      this.pageindex = p;
      this.loadMore();
    },
    loadMore: function () {
      if (this.$isDevelopment) console.log("main.vue - loadMore()");
      this.isLoading = true;
      this.allResults = true;
      this.errormessage = "";

      this.getParametersFromRequest();

      var cs = "";
      if (this.completeSelected) {
        cs = JSON.parse(JSON.stringify(this.completeSelected)).text;
      }
      if (this.$isDevelopment) {
        console.log("main.vue - loadMore() - completeSelected: " + cs + ", " + typeof cs);
        console.log("main.vue - loadMore() - searchTerm: " + this.searchTerm);
      }
      let searchText = "";
      if (typeof cs !== "undefined" && !this.searchTerm) {
        if (this.$isDevelopment) console.log("main.vue - loadMore() => Using completeSelected (what is selected)");
        if (this.completeSelected) {
          searchText = JSON.parse(JSON.stringify(this.completeSelected)).text;
        }
      } else if (this.searchTerm && typeof cs === "undefined") {
        // entering URL /search/<text>
        if (this.$isDevelopment) console.log("main.vue - loadMore() => Using searchTerm (what is typed in)");
        searchText = this.searchTerm;
      } else if (this.searchTerm === cs) {
        if (this.$isDevelopment) console.log("main.vue - loadMore() => The same, use one");
        searchText = this.searchTerm;
      } else if (this.searchTerm !== cs) {
        if (this.$isDevelopment) console.log("main.vue - loadMore() => Different - using searchTerm");
        searchText = this.searchTerm;
      } else {
        if (this.$isDevelopment) console.log("main.vue - loadMore() => CONFUSED)");
      }

      var p = {
        // query: searchText,
        mode: "tiny",
        includeagg: "true",
        size: this.getPageSize,
        offset: this.pageindex,
        titlesonly: false
      };

      // add filters
      for (var agg in this.facets) {
        var selected = [];
        for (var sel in this.facets[agg].selected) {
          if (this.facets[agg].selected[sel]) {
            selected.push(this.facets[agg].selected[sel]);
          }
        }
        p[this.facets[agg].paramname] = selected;
      }

      for (var qp in this.queryparameters) {
        if (this.queryparameters[qp].value) {
          p[this.queryparameters[qp].name] = this.queryparameters[qp].value;
        }
      }

      var dataURL;
      if (this.isEntrySearch || this.isDetailPage) {
        dataURL = `${this.$api_base_url}/search/${encodeURIComponent(searchText)}?${buildQuery(p)}`; //this.$api_base_url + "/search?" + buildQuery(p);
      }
      if (this.isPublisherPage)
        dataURL = `${this.$api_base_url}/entries/bypublisher/${encodeURIComponent(this.$route.params.query)}?${buildQuery(p)}`;
      if (this.isAuthorPage)
        dataURL = `${this.$api_base_url}/entries/byauthor/${encodeURIComponent(this.$route.params.query)}?${buildQuery(p)}`;
      if (dataURL) {
        if (this.$isDevelopment) console.log(`main.vue - loadMore(): buildQuery: ${buildQuery(p)}`);
        if (this.$isDevelopment) console.log(`main.vue - loadMore(): calling ZXInfo API ${dataURL}`);
        axios
          .get(dataURL, { timeout: 5000 })
          .then((response) => {
            var cards = response.data;

            // initialize options for filters
            if (this.isEntrySearch) {
              for (var agg in this.facets) {
                this.facets[agg].items = [];
                const aggName = this.facets[agg].aggName;
                if (cards.aggregations.all_entries[aggName] !== undefined) {
                  for (var i = 0; i < cards.aggregations.all_entries[aggName]["filtered_" + agg].buckets.length; i++) {
                    this.facets[agg].items.push(cards.aggregations.all_entries[aggName]["filtered_" + agg].buckets[i]);
                  }
                }
              }
            }
            // append to cards
            if (cards.hits.hits) {
              for (var ii = 0; ii < cards.hits.hits.length; ii++) {
                this.cards.push(cards.hits.hits[ii]);
              }

              // all shown?
              if (cards.hits.hits.length !== this.getPageSize || cards.hits.total.value == this.getPageSize) {
                this.allResults = true;
              } else {
                this.allResults = false;
              }
            }
            this.pageindex++;
            this.searchNumberOfResults = cards.hits.total.value;
            if (cards.hits.total.relation === "gte") this.searchNumberOfResults += "+";
            this.searchTimeOf = cards.took;
            this.isLoading = false;
            if (this.$isDevelopment) console.log("main.vue - loadMore(): ZXInfo API - DONE!");
          })
          .catch((error) => {
            this.isLoading = false;
            this.allResults = true;
            this.errormessage = error.code + ": " + error.message;
          })
          .finally(() => {
            this.isLoading = false;
          });
      }
    },

    highlight(content) {
      if (!this.searchTerm) {
        return content;
      }
      return content.replace(new RegExp(this.searchTerm, "gi"), (match) => {
        return '<span class="font-weight-bold">' + match + "</span>";
      });
    },

    /* FAB scroll to yop */
    onScroll(e) {
      if (typeof window === "undefined") return;
      const top = window.pageYOffset || e.target.scrollTop || 0;
      this.fab = top > 20;
    },
    toTop() {
      this.$vuetify.goTo(0);
    },
  },
  computed: {
    // Only return non-empty facets
    activeFacets: function () {
      var active = {};
      for (var agg in this.facets) {
        if (this.facets[agg].items.length) {
          active[agg] = this.facets[agg];
        }
      }
      return active;
    },
    // calculate page size, so each "page" are filled out based on breakpoint
    // TODO: recalculate on resize window.
    getPageSize() {
      switch (this.$vuetify.breakpoint.name) {
        case "xs":
          return 20; // cols=12 (1 column),
        case "sm":
          return 20; // cols=6 (2 columns),
        case "md":
          return 21; // cols=3 (3 columns)
        case "lg":
          return 20; // cols=2 (4 columns)
        case "xl":
          return 24; // cols=2 (6 columns)
        default:
          return 20;
      }
    },
    showSearchBar() {
      return this.isEntrySearch || this.isPublisherPage || this.isAuthorPage || this.isDetailPage;
    },
    isHome() {
      return this.$route.name == "Home";
    },
    isByLetter() {
      return this.$route.name == "ByLetterView";
    },
    isEntrySearch() {
      return this.$route.name == "EntrySearch";
    },
    isPublisherPage() {
      return this.$route.name == "PublisherPage";
    },
    isAuthorPage() {
      return this.$route.name == "AuthorPage";
    },
    isDetailPage() {
      return this.$route.name == "DetailPage";
    },
    isGraphPage() {
      return this.$route.name == "GraphPage";
    },
    isAnimatedLoadingPage() {
      return this.$route.name == "AnimatedLoadingPage";
    },
    suggestEndpoint() {
      if (this.isEntrySearch) return "/suggest/";
      else if (this.isPublisherPage) return "/suggest/publisher/";
      else if (this.isAuthorPage) return "/suggest/author/";
      else return "/suggest/";
    },
    labelText() {
      if (this.isEntrySearch || this.isDetailPage) return "What is your favorite game, publisher or author?";
      else if (this.isPublisherPage) return "What is your favorite publisher?";
      else if (this.isAuthorPage) return "Who is your favorite coder?";
      else return "Type something to search for";
    },
    getContenttypeIcon() {
      switch (this.contenttype) {
        case "SOFTWARE":
          return "games";
        case "HARDWARE":
          return "mdi-mouse";
        case "BOOK":
          return "book";
        case "PUBLISHER":
          return "mdi-bank";
        case "AUTHOR":
          return "mdi-account";
        default:
          return "";
      }
    },
  },
  watch: {
    // reload page when linking to new entry
    $route() {
      if (this.$isDevelopment) {
        console.log("main.vue - watch()");
      }

      this.updateContenttypeIcon();
      this.resetSearchResult();
      this.loadMore();
    },
    searchTerm(val) {
      if (this.$isDevelopment) console.log(`main.vue - searchTerm(${val})`);
      if (!val) {
        if (this.$isDevelopment) console.log("main.vue - no value, doing nothing");
        return;
      }
      this.isLoadingOptions = true;
      this.errormessage = "";

      var dataURL = this.$api_base_url + this.suggestEndpoint + encodeURIComponent(val);
      if (this.$isDevelopment) console.log(`main.vue - searchTerm(): calling ZXInfo API ${dataURL}`);
      axios
        .get(dataURL, { timeout: 1500 })
        .then((response) => {
          this.completeOptions = response.data;
          this.isLoadingOptions = false;
        })
        .catch((error) => {
          console.log(error);
          this.completeOptions = [];
          this.errormessage = error.code + ": " + error.message;
          this.isLoadingOptions = false;
        })
        .finally(() => (this.isLoadingOptions = false));
    },
  },
  mounted() {
    if (this.$isDevelopment) console.log(`main.vue - mounted(): query=${this.$route.params.query}`);
    if (this.$route.params.query) {
      this.completeSelected = this.searchTerm = this.$route.params.query;
    } else {
      this.completeOptions = [];
    }
    this.updateContenttypeIcon();
    this.loadMore();
  },
};
</script>
<style scoped>
a:hover,
a:link,
a:visited,
a.router-link-active,
a.router-link-exact-active {
  color: black;
  cursor: pointer;
  text-decoration: underline;
}
</style>
