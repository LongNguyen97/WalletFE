<template>
  <v-app>
    <div style="display: flex">
      <v-row
      >
        <v-col>
          <v-autocomplete
            clearable
            deletable-chips
            prepend-icon="mdi-gamepad-outline"
            :items=gamesAutoComplete
            no-data-text='Game not found'
            placeholder="Input game"
            v-model="selectedGame"
          ></v-autocomplete>
        </v-col>
        <v-col/>
        <v-col/>
        <v-col/>
      </v-row>
    </div>
    <div style="display: flex; margin-top: -15px">
      <v-row>
        <v-col>
          <v-autocomplete
            clearable
            deletable-chips
            prepend-icon="mdi-package-variant-closed-plus"
            :items=packagesAutoComplete
            no-data-text='Package not found'
            placeholder="Input package"
            v-model="selectedPackage"
          ></v-autocomplete>
        </v-col>
        <v-col/>
        <v-col/>
        <v-col/>
      </v-row>
    </div>
    <div style="display: flex; margin-top: -15px">
      <v-row>
        <v-col>
          <v-text-field
            v-model="selectedAmount"
            hide-details
            prepend-icon="mdi-counter"
            single-line
            placeholder="Input amount"
            type="number"
            min="0"
          />
        </v-col>
        <v-col/>
        <v-col/>
        <v-col/>
      </v-row>
    </div>

    <div style="display: flex; margin-top: 5px">
      <v-row>
        <v-col style=" margin-right: -40px;">
          <v-container class="d-flex flex-row-reverse" >
            <v-btn @click="exportTokens()" :loading=btnApplyLoading>
              <v-icon style="color: #0066A2"> mdi-download-multiple</v-icon>
            </v-btn>
          </v-container>
        </v-col>
        <v-col/>
        <v-col/>
        <v-col/>
      </v-row>

    </div>
    <div class="footer">
      <snack-bar :snackbar="snackbar"></snack-bar>
    </div>
  </v-app>
</template>

<script>
import userMixin from "@/mixins/user-mixins";
import CONSTANTS from "@/constants/constants";

export default {
  name: "ManageAssignRevoke",
  mixins: [userMixin],
  watch: {
    selectedGame() {
      if (!this.selectedGame || this.selectedGame === 'All') {
        this.packagesAutoComplete = []
        this.isPackagesEmpty = true
      } else {
        this.isPackagesEmpty = false
        this.packagesAutoComplete = this.games[this.selectedGame]['packages'].map(el => el)
      }
    }
  },
  data() {
    return {
      options: null,
      btnApplyLoading: false,
      selectedGame : null,
      selectedPackage : null,
      selectedAmount : 0,
      games : {},
      gamesAutoComplete : [],
      packagesAutoComplete : [],
      isPackagesEmpty : false,
      snackbar: {
        snackbar: false,
        text: '',
        timeout: 1500,
        color: 'success'
      },
    }
  },
  mounted() {
    this.init();
  },
  methods: {
    async init() {
      await this.getGamesAndPackages()
    },
    async getGamesAndPackages() {
      const res = await this.$axios.get('/all-games-packages/')
      this.games = res.data.games
      this.gamesAutoComplete = []
      Object.keys(this.games).forEach((ind, _) => {
        this.gamesAutoComplete.push({'value': ind, 'text': this.games[ind]['game_name']})
      })
    },

    async exportTokens() {
      const data = {
        gameId: this.selectedGame,
        identify: this.selectedPackage,
        amount: this.selectedAmount
      }

      if (!(data.gameId && data.identify && data.amount)) {
        this.snackbar = {
          text : 'Select Game/Package/Amount',
          color : 'red accent-2',
          snackbar :  true
        }
        return
      }

      try {
        this.btnApplyLoading = true
        const res = await this.$axios.get('export-import/', {params: data})
        const url = window.URL.createObjectURL(new Blob([res.data]));
        const link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', 'file.csv');
        document.body.appendChild(link);
        link.click();
        link.remove();
      } catch (e) {
        console.log(e.response)
        this.snackbar.text = e.response['status'] === 401 ? 'Session expired, login again!' : `Request failed ${e.response.data}`
        this.snackbar.color = 'red accent-2'
        this.snackbar.snackbar = true
      } finally {
        this.btnApplyLoading = false
      }
    }
  }
}
</script>

<style scoped>

</style>
