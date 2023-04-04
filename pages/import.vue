<template>
  <v-app>
    <div>
      <v-row
      >
        <v-col>
          <v-file-input
            label="Upload file"
            accept="text/csv"
            show-size
            counter
            filled
            @change="handleFileUpload"
            v-model="selectedFile"

          ></v-file-input>
        </v-col>
        <v-col>
          <v-container>
            <v-btn class="button-toolbar submit" @click="importTokens()" :loading=btnApplyLoading>
              <v-icon style="color: #0066A2"> mdi-cloud-upload</v-icon>
            </v-btn>
          </v-container>
        </v-col>
        <v-col/>
        <v-col/>
      </v-row>

    </div>
      <v-row>
        <v-col
          cols="12"
          sm="12">
          <grid ref="quotaTable" :options=importOptions></grid>
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
import Papa from 'papaparse';

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
      fileFields: ['identify', 'user_id', 'game_id', 'token', 'signature', 'order_id', 'create_time'],
      importOptions: null,
      btnApplyLoading: false,
      selectedFile: null,
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
    InitGrid(data) {
      this.importOptions = null;
      this.importOptions = {...CONSTANTS.options}
      let options = {
        colModel: [
          {
            //identify	user_id	game_id	user_id	token	signature	order_id	create_time

            title: 'Package Id',
            width: 150,
            dataIndx: 'identify',
            align: "left",
            editable: false,

            filter: {type: 'textbox', condition: "begin", listeners: ['keyup']}
          }, {
            //identify	user_id	game_id	user_id	token
            title: 'UserId',
            width: 150,
            dataIndx: 'user_id',
            align: "left",
            editable: false,
          },
          {
            title: 'Game Id ',
            width: 150,
            dataIndx: 'game_id',
            align: "center",
            editable: true,
          },
          {
            title: 'Token',
            width: 150,
            dataIndx: 'token',
            align: "center",
            editable: true,
          },
          {
            title: 'Signature',
            width: 150,
            dataIndx: 'signature',
            align: "center",
            editable: false,
          },
          {
            title: 'OrderId',
            width: 150,
            dataIndx: 'order_id',
            align: "center",
            editable: false,
          },
          {
            title: 'Create Time',
            width: 150,
            dataIndx: 'create_time',
            align: "center",
            editable: false,
          },
        ],
        dataModel: {
          data: data
        },
      }
      this.importOptions = {...CONSTANTS.options, ...options}
    },
    handleFileUpload(event) {
      if(this.selectedFile){
        Papa.parse(this.selectedFile, {
          header: true,
          dynamicTyping: true,
          complete: (results) => {
            let isValid = true
            if (results?.meta?.fields) {
              results.meta.fields.forEach(el => {
                if (!this.fileFields.includes(el)) {
                  isValid = false
                }
              })
            }
            if (isValid === false) {
              this.snackbar.text = 'Columns không hợp lệ trong list: ' + this.fileFields.join(',')
              this.snackbar.color = 'red accent-2'
              this.snackbar.snackbar = true
            } else
              this.InitGrid(results['data'])
          },
          error: (error) => {
            console.log(error);
          }
        });
      }
    },

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

    async importTokens() {

      if (!this.selectedFile) {
        this.snackbar = {
          text: 'Select CSV file',
          color: 'red accent-2',
          snackbar: true
        }
        return
      }

      let formData = new FormData();
      formData.append("importedFile", this.selectedFile);
      try {
        this.btnApplyLoading = true
        const res = await this.$axios.post('export-import/', formData)
        this.snackbar.text = res.data.msg
        this.snackbar.color = 'success'
        this.snackbar.snackbar = true
        this.selectedFile = null
      } catch (e) {
        console.log(e.response)
        this.snackbar.text = e.response['status'] === 401 ? 'Session expired, login again!' : `Request failed ${e.response.data.msg}`
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
