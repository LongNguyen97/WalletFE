<template>
  <v-app>
    <div>
      <v-row
        style="display: flex"
      >
        <v-col>
          <v-autocomplete
            clearable
            deletable-chips
            prepend-icon="mdi-account-multiple"
            :autofocus="true"
            :items=users
            no-data-text='User not found'
            :placeholder=placeholder
            v-model="selectedUsername"
          ></v-autocomplete>
        </v-col>

        <v-col>
          <v-container>
            <v-btn @click="getReceipts()" :loading=btnApplyLoading>
              <v-icon style="color: #0066A2"> mdi-account-search</v-icon>
            </v-btn>
          </v-container>
        </v-col>
        <v-col/>
        <v-col/>

      </v-row>
    </div>

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
        <v-col/>
        <v-col/>
      </v-row>
    </div>

    <div style="display: flex; margin-top: -15px">
      <v-row>
        <v-col>
          <v-menu
            :close-on-content-click="false"
            :nudge-right="40"
            transition="scale-transition"
            offset-y
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="fromDate"
                label="From Date"
                prepend-icon="mdi-calendar"
                readonly
                v-bind="attrs"
                v-on="on"
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="fromDate"
            ></v-date-picker>
          </v-menu>
        </v-col>
        <v-col
          style="display: flex"
        >

          <v-menu
            :close-on-content-click="false"
            :nudge-right="40"
            transition="scale-transition"
            offset-y
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="toDate"
                label="To date"
                prepend-icon="mdi-calendar"
                readonly
                v-bind="attrs"
                v-on="on"
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="toDate"
            ></v-date-picker>
          </v-menu>
        </v-col>
        <v-col/>
        <v-col/>
      </v-row>
    </div>
    <div style="margin-top: -25px">
      <v-radio-group
        v-model="modeSelection"
        row
      >
        <v-radio
          label="Quản lý Nạp"
          color="success"
          value="push-token"


        ></v-radio>
        <v-radio
          label="Quản lý Xả"
          color="error"
          value="pull-token"
        ></v-radio>
      </v-radio-group>
    </div>
    <v-row>
      <v-col
        cols="12"
        sm="6"
      >
        <b>Thông tin {{ modeSelection === 'push-token' ? 'Nạp' : 'Xả' }}</b>
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
  name: "ManageAssignRevoke",
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
      users: ['Long', 'Nguyen', 'Viet'],
      btnApplyLoading: false,
      fromDate: null,
      toDate: null,
      modeSelection : 'push-token',
      selectedGame : 'All',
      selectedPackage : null,
      placeholder: 'Input user name',
      selectedUsername: "",
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
              dataIndx: 'name',
              align: "left",
              editable: false,
              filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
            }, {
              title: 'Amount',
              width: 40,
              dataIndx: 'amount',
              editable: false,
              align: "center",
              render: (ui) => {
                const amount = `<b style="color: ${this.modeSelection ==='pull-token' ? 'red' : 'green'}">${ui.rowData.amount}</b>`
                return {text :amount}
              }
            },
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

    async getReceipts() {
      const data = {
        userId: this.selectedUsername,
        gameId: this.selectedGame,
        identify: this.selectedPackage,
        fromDate: this.fromDate,
        toDate: this.toDate,
      }
      const url = this.modeSelection === 'pull-token' ? '/get-orders/' : '/get-receipts/'

      if (!data.userId) {
        this.snackbar = {
          text : 'Select username and game id',
          color : 'red accent-2',
          snackbar :  true
        }
        return
      }

      try {
        this.btnApplyLoading = true
        const res = await this.$axios.get(url, {params: data})
        this.dataDetail = res.data.data
        this.initGrid()
      } catch (e) {
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
