<template>

  <v-app>

    <grid ref="grid" :options=options></grid>

    <div class="footer">
      <snack-bar :snackbar="snackbar"></snack-bar>
      <Dialog ref="dialog"
              @confirm="deletePackages()"
              @cancel="dialogDelete = false"
      ></Dialog>
    </div>

  </v-app>
</template>

<script>

import CONSTANTS from "~/constants/constants"

export default {
  name: "managePackage",
  components: {},
  data() {
    return {
      snackbar: {
        snackbar: false,
        text: '',
        timeout: 1500,
      },
      dialogDelete: false,
      currentDelete: null,
      options: {},
      allData: [],

    }
  },

  async mounted() {
    await this.initPage()
  },

  watch: {
    dialogDelete(newValue) {
      if (newValue === true) {
        this.$refs.dialog.show()
      } else {
        this.$refs.dialog.close()
      }
    },
  },

  methods: {

    async initPage() {
      await this.getGamesAndPackages()
      this.init()
    },
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
          {
            title: 'Xóa gói',
            maxWidth: 15,
            name: 'delete_package',
            dataIndx: 'delete_package',
            align: "center",
            editable: false,
            render: (ui) => {
              return {
                text: `<div style='align-items: center'>
                <span class="mdi mdi-minus-box mdi-24px"></span>
              </button>
              </div>`
              }
            }
          },
        ],
        dataModel: {
          data: this.allData
        },
        cellClick: this.cellClick(),
      }
      this.options = {...CONSTANTS.options, ...currentOptions}
    },

    cellClick() {
      return (evt, ui) => {
        if (ui.column.dataIndx === 'delete_package') {
          this.currentDelete = {
            game_id: ui.rowData.game_id,
            identify: ui.rowData.package_id
          }
          this.dialogDelete = true
        }
      }
    },

    async deletePackages() {
      try {
        console.log(this.currentDelete)
        let data = {'data': this.currentDelete, 'type': 'delete_package'}
        const res = await this.$axios.post(`/all-games-packages/`, data)
        this.snackbar.text = res.data.msg
        this.snackbar.color = 'success'
        await this.initPage()
      } catch (ex) {
        this.snackbar.text = ex.response.data.msg
        this.snackbar.color = 'red accent-2'
      } finally {
        this.snackbar.snackbar = true
        this.currentDelete = null
        this.dialogDelete=false
      }
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
  }

}
</script>

<style>
.button-toolbar {
  border-radius: 5px;
  margin-right: 7px;
  margin-bottom: 3px;
  border: 1px solid gray;
}
</style>
