<template>

  <v-app>
    <div class="d-flex flex-row-reverse" style="margin-top: 10px">
      <v-btn class="button-toolbar submit" @click="editUser()">
        <v-icon style="color: #0066A2"> mdi-content-save-move-outline</v-icon>
      </v-btn>
      <v-btn class="button-toolbar" title="Remove User" @click="handleDeleteUsers()">
        <v-icon style="color: red"> mdi-account-multiple-remove</v-icon>
      </v-btn>
      <v-btn class="button-toolbar" title="Add User" @click="addUser">
        <v-icon style="color: #00b050"> mdi-account-plus</v-icon>
      </v-btn>
    </div>

    <grid ref="grid" :options=options></grid>

    <div class="footer">
      <Dialog ref="dialog"
              @confirm="deleteUser()"
              @cancel="dialogDelete = false"
      ></Dialog>
      <snack-bar :snackbar="snackbar"></snack-bar>

    </div>
  </v-app>
</template>

<script>

import CONSTANTS from "~/constants/constants"
import userMixin from "~/mixins/user-mixins";

export default {
  name: "manage_user",
  mixins: [userMixin],
  components: {},
  data() {
    return {
      selectedUsername: [],
      snackbar: {
        snackbar: false,
        text: '',
        timeout: 1500,
      },
      dialogDelete: false,
      search: true,
      options: {}

    }
  },
  watch: {
    dialogDelete(newValue) {
      if (newValue === true) {
        this.$refs.dialog.show()
      } else {
        this.$refs.dialog.close()
      }
    }
  },
  methods: {
    render(ui) {
      return function (ui) {
        return {
          style: {
            color: '#6a1b1c',
            'font-weight': 'bold',
            'background-color': '#fdc8ce !important',
          },
        }
      }
    },


    handleDeleteUsers() {
      this.selectedUsername = this.allUsers.filter(el => el.state === true).map(el => el.username)
      if (this.selectedUsername.length === 0) return;
      this.dialogDelete = true
    },

    async deleteUser() {
      try {
        const res = await this.$axios.delete('/profile/delete/' + this.selectedUsername.join(","))
        this.snackbar.text = res.data.res
        this.allUsers = this.allUsers.filter(el => !this.selectedUsername.includes(el.username))
        this.init();
      } catch (e) {
        this.snackbar.text = e.response.status === 401 ? 'Session expired, login again!' : `Update failed ${e}`
        this.snackbar.color = 'red accent-2'
        this.snackbar.snackbar = true
      } finally {
        this.snackbar.snackbar = true
        this.dialogDelete = false
      }
    },

    async editUser() {
      try {
        const res = await this.$axios.post('/profile/', this.$refs.grid.getRow())
        this.snackbar.text = res.data.res
      } catch (e) {
        this.snackbar.text = e.response.status === 401 ? 'Session expired, login again!' : `Update failed ${e}`
        this.snackbar.color = 'red accent-2'
        this.snackbar.snackbar = true
      } finally {
        this.snackbar.snackbar = true
      }

    },
    addUser() {
      const newUser = {userName: 'NewUser', raw_pass: "123", is_active: true, is_superuser: false, is_new: true}
      this.$refs.grid.addRow(newUser)
    },


    init() {
      this.options = null;
      this.options = {...CONSTANTS.options}
      const currentOptions = {
        colModel: [
          {
            dataIndx: 'state',
            maxWidth: 50,
            minWidth: 40,
            align: 'center',
            resizable: false,
            title: '',
            menuIcon: true,
            cls: 'ui-state-default',
            sortable: false,
            hidden: false,
            editor: false,
            type: 'checkbox',
            dataType: 'bool',
            cb: {all: false, header: true},
          },
          {

            title: 'Tên User',
            width: 100,
            dataIndx: 'username',
            prepend: "user is required",
            align: "left",
            editable: (ui) => ui.rowData?.is_new === true,
            validations: [{type: 'minLen', value: '1', msg: 'Required'}],
            filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
          },
          {
            validations: [{type: 'minLen', value: '1', msg: 'Required'}],
            editor: {type: 'textbox', style: 'border-radius:5px;'},
            title: 'Mật khẩu', width: 100, dataType: 'string', dataIndx: 'raw_pass',
          },
          {
            title: 'Roles',
            dataIndx: 'is_superuser',
            width: 100,
            editor: {
              type: 'select',
              options: [
                'Admin', 'User'
              ],
            },
            render: (ui) => {
              const isSuperUser = ['Admin', true, 'true'].includes(ui.rowData.is_superuser)
              return `<p style = " font-weight: bold; color: ${isSuperUser === true ? 'red' : 'green'}; text-align-last: center"> ${isSuperUser === true ? 'Admin' : 'User'} </p>`
            }
          },
          {
            title: 'Actions',
            width: 200,
            dataType: 'string',
            name: 'actions',
            dataIndx: 'actions',
            hidden: false,
            align: 'center',
            editable: false,
            render: (ui) => {
              const renderData = {}
              const newButton = `
              <button style="color: green">
              <span class="mdi mdi-content-save-edit mdi-24px"></span>
            </button>`
              const deleteButton = `
              <button style="color: red">
              <span class="mdi mdi-delete mdi-24px"></span>
            </button>`
              renderData.text = ui.rowData?.is_new ? newButton : deleteButton
              return renderData
            }
          },

        ],
        cellClick: this.cellClick(),
        dataModel: {
          data: this.allUsers
        }
      }
      this.options = {...CONSTANTS.options, ...currentOptions}
    },

    cellClick() {
      return (evt, ui) => {
        if (ui.column.name === 'actions') {
          if (ui.rowData.username && ui.rowData.is_new === true) {
            ui.rowData.is_new = false
            setTimeout(() => {
              this.$refs.grid.refreshDataAndView();
            }, 1)
          } else {
            this.selectedUsername = [ui.rowData.username]
            this.dialogDelete = true
          }
        }
      }
    }
  },

  async mounted() {
    await this.getAllUsers()
    this.init()
  }

}
</script>

<style scoped>
.button-toolbar {
  border-radius: 5px;
  margin-right: 7px;
  margin-bottom: 3px;
  border: 1px solid gray;
}

.pq-grid-hd-search-field::after {
  content: "\f002" !important;   /* FontAwesome search icon */
  font-family: FontAwesome, serif;
  font-size: 14px;
  color: #ccc;
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
}


</style>
