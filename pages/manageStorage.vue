<template>
  <v-app>

    <div style="display: flex; margin-top: -15px">
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
        <v-col>
          <v-autocomplete
            clearable
            deletable-chips
            prepend-icon="mdi-package-variant-closed-plus"
            :disabled =isPackagesEmpty
            :items=packagesAutoComplete
            no-data-text='Package not found'
            placeholder="Input package"
            v-model="selectedPackage"
          ></v-autocomplete>
        </v-col>
        <v-col>
          <v-container>
            <v-btn @click="retrieveStorage()" :loading=btnApplyLoading>
              <v-icon style="color: #0066A2"> mdi-toy-brick-search-outline</v-icon>
            </v-btn>
          </v-container>
        </v-col>
        <v-col/>
      </v-row>
    </div>

    <v-row>
      <v-col
        cols="12"
        sm="6"
      >
        <b>Thông tin</b>
        <grid ref="tableDetail" :options="options"></grid>
      </v-col>
    </v-row>
    <div class="footer">
      <snack-bar :snackbar="snackbar"></snack-bar>
    </div>
  </v-app>
</template>

<script>
import userMixin from "@/mixins/user-mixins";
import CONSTANTS from "@/constants/constants";

export default {
  name: "ManageStorage",
  mixins: [userMixin],
  watch: {
    selectedGame() {
      if (!this.selectedGame || this.selectedGame === 'All') {
        this.packagesAutoComplete = []
        this.isPackagesEmpty = true
      } else {
        this.isPackagesEmpty = false
        this.packagesAutoComplete = [...[{
          text: 'All',
          value: 'All'
        }], ...this.games[this.selectedGame]['packages'].map(el => el)]
      }
    }
  },
  data() {
    return {
      options: null,
      btnApplyLoading: false,
      selectedGame : 'All',
      selectedPackage : null,
      games : {},
      dataDetail: {},
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
    initGrid() {
      this.options = null;
      this.options = {...CONSTANTS.options}
      //      "game_name": "L2M TW",
      // "package": "130KC - 3.74",
      //   "total": 163,
      //   "not_used": 11,
      //   "used": 152
      let currentOptions = {
        colModel: [{
          title: 'Game Name',
          dataIndx: 'game_name',
          width: 100,
          align: 'left',
          resizable: false,
          menuIcon: true,
          editable: false,
          sortable: true,
          filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
        },
          {
            title: 'Package Name',
            width: 150,
            dataIndx: 'package',
            align: "left",
            editable: false,
            filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
          }, {
            title: 'Tổng',
            width: 40,
            dataIndx: 'total',
            editable: false,
            align: "center",
            render: (ui) => {
              const amount = `<b style="color: green}">${ui.rowData.total}</b>`
              return {text: amount}
            }
          },
          {
            title: 'Đã dùng',
            width: 40,
            dataIndx: 'used',
            editable: false,
            align: "center",
            render: (ui) => {
              const amount = `<b style="color: red">${ui.rowData.used}</b>`
              return {text: amount}
            }
          },
          {
            title: 'Chưa dùng',
            width: 40,
            dataIndx: 'not_used',
            editable: false,
            align: "center",
            render: (ui) => {
              const amount = `<b style="color: green">${ui.rowData.not_used}</b>`
              return {text: amount}
            }
          }
        ],
        dataModel: {
          data: this.dataDetail
        },}
      this.options = {...CONSTANTS.options, ...currentOptions}
    },
    async init() {
      await this.getAllUsers()
      await this.getGamesAndPackages()
      this.users = this.allUsers.map(el => el.username)
    },
    async getGamesAndPackages() {
      const res = await this.$axios.get('/all-games-packages/')
      this.games = {...{'All': {game_name: 'All'}}, ...res.data.games}
      this.gamesAutoComplete = []
      Object.keys(this.games).forEach((ind, _) => {
        this.gamesAutoComplete.push({'value': ind, 'text': this.games[ind]['game_name']})
      })
    },

    async retrieveStorage() {
      const data = {
        gameId: this.selectedGame,
        identify: this.selectedPackage,
      }

      try {
        this.btnApplyLoading = true
        const res = await this.$axios.get('/get-storage/', {params: data})
        this.dataDetail = res.data.data
        this.initGrid()
      } catch (e) {
        console.log(e)
        if (e.response.status === 401){
          this.$router.push('/login');
        }
        this.snackbar.text = e.response.status === 401 ? 'Session expired, login again!' : `Update failed ${e}`
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
