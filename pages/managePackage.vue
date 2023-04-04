<template>

  <v-app>
    <div class="d-flex flex-row-reverse" style="margin-top: 10px">
      <v-btn class="button-toolbar submit" @click="save">
        <v-icon style="color: #0066A2"> mdi-content-save-move-outline</v-icon>
      </v-btn>
    </div>

    <grid ref="grid" :options=options></grid>

    <div class="footer">
      <snack-bar :snackbar="snackbar"></snack-bar>
    </div>
  </v-app>
</template>

<script>

import CONSTANTS from "~/constants/constants"
export default {
  name: "managePackage",
  components: {

  },
  data() {
    return {
      snackbar: {
        snackbar: false,
        text: '',
        timeout: 1500,
      },
      options: {},
      allData : [],

    }
  },
  async mounted() {
    await this.getGamesAndPackages()
    this.init()
  },
  methods: {
    init() {
      this.options = null;
      this.options = {...CONSTANTS.options}
      const currentOptions = {
        colModel: [
          {
            title: 'Tên game',
            width: 100,
            dataIndx: 'game_name',
            prepend: "user is required",
            align: "left",
            editable: false,
            filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
          },
          {
            title: 'Tên gói',
            dataIndx: 'package_name',
            editable: false,
            filter: {type: 'textbox', condition: "begin", listeners: ['keyup']},
            width: 100,
          },
          {
            title: 'Giá',
            editable: false,
            dataIndx: 'real_price',
            width: 100,
          },
        ],
        dataModel: {
          data: this.allData
        },
        change: (_, ui) => {
          if (ui.rowList[0].newRow.hasOwnProperty('game_name')) {
            let a = this.allData.filter((el) => el.game_id === ui.rowList[0].rowData.game_id);
            a.forEach(el => el.game_name = ui.rowList[0].newRow.game_name)
            setTimeout(() => {
              this.$refs.grid.refreshDataAndView();
            }, 1)
          }
        },
      }
      this.options = {...CONSTANTS.options, ...currentOptions}
    },

    async getGamesAndPackages() {
      try {
        const res = await this.$axios.get('/all-games-packages/')
        const resItem = res.data.games
        this.allData = []
        Object.keys(resItem).forEach((ind, _) => {
          resItem[ind]['packages'].forEach((item) => {
            this.allData.push({
              'game_name': resItem[ind]['game_name'],
              'game_id': ind,
              'package_name': item.virtual_currency,
              'package_id': item.value,
              'real_price': item.real_price
            })
          })
        })
      } catch (e) {
        console.log(e)
        if (e.response.status === 401) {
          this.$router.push('/login');
        }
        this.snackbar.text = e.response.status === 401 ? 'Session expired, login again!' : `Update failed ${e}`
        this.snackbar.color = 'red accent-2'
        this.snackbar.snackbar = true
      }
    },

    async save() {
      try {
        const updateData = this.$refs.grid.getRow()
        const res = await this.$axios.post('/all-games-packages/', {'data': updateData, 'type': 'updatePackage'})
        this.snackbar.text = res.data.msg
        this.snackbar.color = 'success'
      } catch (e) {
        console.log(e)
        if (e.response.status === 401) {
          await this.$router.push('/login');
        }
        this.snackbar.text = e.response.status === 401 ? 'Session expired, login again!' : `Update failed ${e}`
        this.snackbar.color = 'red accent-2'
      } finally {
        this.snackbar.snackbar = true
      }
    },
  }

}
</script>

<style>
.button-toolbar{
  border-radius: 5px;
  margin-right:7px;
  margin-bottom:3px;
  border: 1px solid gray;
}
</style>
