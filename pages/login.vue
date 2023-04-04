<template>
  <v-main>
    <v-container fluid fill-height>
      <v-layout align-center justify-center>
        <v-flex xs12 sm8 md4>
          <v-card class="elevation-12">
            <v-toolbar dark color="primary">
              <v-toolbar-title> Đăng nhập</v-toolbar-title>
            </v-toolbar>
            <v-card-text>
              <v-form>
                <v-text-field
                  v-model="login.username"
                  prepend-icon="mdi-account"
                  name="login"
                  label="Username"
                  type="text"
                ></v-text-field>
                <v-text-field
                  prepend-icon="mdi-shield-key"
                  v-model="login.password"
                  name="password"
                  label="Password"
                  type="password"
                ></v-text-field>
              </v-form>
            </v-card-text>
            <v-card-text v-if="showWrong" style="color: red">
              Wrong information
            </v-card-text>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn color="primary" @click="userLogin()">Login</v-btn>
            </v-card-actions>
          </v-card>
        </v-flex>
      </v-layout>
    </v-container>
  </v-main>
</template>
<script>
export default {
  name: "login",

  data() {
    return {
      login: {
        username: '',
        password: '',
      },
      showWrong: false,
    }
  },
  beforeCreate() {
    if (this.$auth.loggedIn) {
      this.$router.push('/')
    }
  },
  methods: {
    async userLogin() {
      try {
        await this.$auth.loginWith('local', {data: this.login})
        await this.$router.push('/')
        this.showWrong = false;
      } catch (err) {
        this.showWrong = true;
        console.log(err)
      }
    },
  }

}

</script>

<style scoped>

</style>
