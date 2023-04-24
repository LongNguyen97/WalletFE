<template>
  <v-app>
    <div>
      <v-col
        cols="6"
        sm="6"
        style="display: flex"
      >
        <v-autocomplete
          clearable
          deletable-chips
          prepend-icon="mdi-account-multiple"
          :autofocus="true"
          :items=users
          :no-data-text=notFound
          :placeholder=placeholder
          v-model="selectedUsername"
        ></v-autocomplete>
        <v-container>
          <v-btn @click="getQuotaAndHistoryByUser" :loading=btnApplyLoading :disabled=!selectedUsername>
            <v-icon style="color: #0066A2"> mdi-account-search</v-icon>
          </v-btn>
        </v-container>
      </v-col>
    </div>
    <v-checkbox
      class="inline-checkbox"
      v-model="isShowingEmpty"
      label="Hiển thị all"
    ></v-checkbox>
    <v-row>
      <v-col
        cols="12"
        sm="6"
      >
        <b>Quota</b>
        <grid ref="quotaTable" :options=quotaOptions></grid>
      </v-col>
      <v-col
        cols="12"
        sm="6"
      >
        <b>History</b>
        <grid ref="historyTable" :options="historyOptions"></grid>

      </v-col>
    </v-row>
    <div class="footer">
      <snack-bar :snackbar="snackbar"></snack-bar>
    </div>
  </v-app>
</template>

<script>

import userMixin from "~/mixins/user-mixins";
import CONSTANTS from "@/constants/constants";

export default {
  name: "manageQuota",
  mixins: [userMixin],
  data() {
    return {
      users: ['Long', 'Nguyen', 'Viet'],
      notFound: 'User not found',
      placeholder: 'Input user name',
      selectedUsername: '',
      btnApplyLoading: false,
      data: {},
      quotaOptions: {},
      historyOptions: {},
      isShowingEmpty: false,
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
  watch: {
    // whenever question changes, this function will run
    isShowingEmpty() {
      this.initQuotaTable()
    }
  },

  methods: {
    async init() {
      await this.getAllUsers()
      this.users = this.allUsers.map(el => el.username)
    },
    initQuotaTable: function () {

      // set the filtered data to the dataModel
      var filteredData = null;
      if (!this.data.quota)
        return
      if (this.isShowingEmpty === false) {
        filteredData = this.data.quota.filter(item => item.amount !== 0 || item.amount_used !== 0);
      } else {
        filteredData = this.data.quota
      }

      this.quotaOptions = null;
      this.quotaOptions = {...CONSTANTS.options}
      let currentQuotaOptions = {
        colModel: [{
          title: 'Game',
          dataIndx: 'game',
          width: 100,
          align: 'center',
          resizable: false,
          menuIcon: true,
          editable: false,
          // cls: 'ui-state-default',
          sortable: true,
          filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
        },
          {
            title: 'Package',
            width: 150,
            dataIndx: 'package',
            prepend: "user is required",
            align: "left",
            editable: false,
            filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
          }, {
            title: 'Tổng/Đã dùng',
            width: 40,
            editable: true,
            validations: [{type: 'regex', value: '^[0-9]*$', msg: 'Required'}],
            align: "center",
            render: (ui) => {
              let amount = `<b style="color: green"> ${ui.rowData.amount}</b>/<b style="color: red"> ${ui.rowData.amount_used}</b>`
              return {text: amount}
            }
          },
          {
            title: 'Còn lại',
            width: 30,
            dataIndx: 'remain_amount',
            align: "center",
            editable: true,
          },
          {
            title: 'Số Lượng',
            width: 30,
            dataIndx: 'newAmount',
            align: "center",
            editable: true,
          },

          {
            title: 'Cấp gói',
            maxWidth: 15,
            name: 'assign_amount',
            align: "center",
            editable: false,

            render: (ui) => {
              let a = `<div style='align-items: center'>
                <button style="color: green">
                  <span class="mdi mdi-plus-box mdi-24px"></span>
                </button>
              </div>`

              return {text: a}
            }
          },
          {
            title: 'Thu hồi',
            maxWidth: 15,
            name: 'revoke_amount',
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
        sortModel: {
          single: false,
          sorter: [{ dataIndx: 'remain_amount', dir: 'down' }],
          space: true,
          multiKey: null
        },
        dataModel: {
          data: filteredData,
        },
        cellClick: this.cellClick(),
      }
      this.quotaOptions = {...CONSTANTS.options, ...currentQuotaOptions}
    },

    initHistoryTable() {
      this.historyOptions = null;
      this.historyOptions = {...CONSTANTS.options}
      let currentQuotaOptions = {
        colModel: [{
          title: 'Game',
          dataIndx: 'game',
          width: 100,
          align: 'center',
          resizable: false,
          menuIcon: true,
          sortable: true,
          editable: false,
          filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
        },
          {
            title: 'Package',
            width: 150,
            dataIndx: 'package',
            align: "left",
            editable: false,
            filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
          }, {
            title: 'Amount added',
            width: 40,
            dataIndx: 'amount',
            editor: {
              type: 'textbox',
              options: [
                'Admin', 'User'
              ],
            },
            render: (ui) => {
              return `<b style="color: ${ui.rowData.amount < 0 ? 'red' : 'green'}">${ui.rowData.amount}</b>`
            },
            editable: false,
            validations: [{type: 'regex', value: '^[0-9]*$', msg: 'Required'}],
            align: "center",
          },
          {
            title: 'Added Time',
            width: 40,
            dataIndx: 'time_add',
            align: "right",
            editable: false,
          }],
        dataModel: {
          data: this.data.history
        }
      }
      this.historyOptions = {...CONSTANTS.options, ...currentQuotaOptions}
    },
    initDataTable() {
      this.initQuotaTable();
      this.initHistoryTable();
    },

    async getQuotaAndHistoryByUser() {
      try {
        this.btnApplyLoading = true
        const res = await this.$axios.get('/quota/get-quota-and-history/' + this.selectedUsername)
        this.data = res.data
        this.initDataTable()
      } catch {

      } finally {
        this.btnApplyLoading = false
      }
    },

    cellClick() {
      return (evt, ui) => {
        if (ui.column.name === 'assign_amount') {
          this.assignPackages(ui, 'assign')
        } else if (ui.column.name === 'revoke_amount') {
          this.assignPackages(ui, 'revoke')
        }
      }

    },
    async assignPackages(ui, action) {
      console.log((0 - parseInt(ui.rowData.newAmount)))
      if ((!ui.rowData.newAmount || isNaN(ui.rowData.newAmount)) || (action === 'assign' && parseInt(ui.rowData.newAmount) <= 0)) return

      const data = {
        game_id: ui.rowData.game_id || ui.rowData.product_data_game_id,
        identify: ui.rowData.identify || ui.rowData.product_data_game_identify,
        newAmount: action === 'assign' ? parseInt(ui.rowData.newAmount) : (0 - parseInt(ui.rowData.newAmount)),
        userId: this.selectedUsername,
      }
      try {
        const res = await this.$axios.post('quota/update-amount', data)
        this.snackbar.text = res.data.msg
        this.snackbar.color = 'success'
        await this.getQuotaAndHistoryByUser()
      } catch (ex) {
        console.log(ex.response.data)
        this.snackbar.text = ex.response.data.msg
        this.snackbar.color = 'red accent-2'
      } finally {
        this.snackbar.snackbar = true
      }
    },

  }
}
</script>

<style scoped>
.inline-checkbox{
  margin-right: 20px;
  margin-top: -16px;
}
</style>
