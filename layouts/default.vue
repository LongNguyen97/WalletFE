<template>
  <v-app :light=true>
    <v-navigation-drawer
      v-model="drawer"
      :mini-variant="miniVariant"
      :clipped="clipped"
      fixed
      app
    >
      <v-list>
        <v-list-item
          v-for="(item, i) in items"
          :key="i"
          :to="item.to"
          router
          exact
        >
          <v-list-item-action>
            <v-icon>{{ item.icon }}</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title>{{ item.title }}</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
    <v-app-bar
      :clipped-left="clipped"
      fixed
      app
    >
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />

      <v-btn
        icon
        @click.stop="miniVariant = !miniVariant"
      >
        <v-icon>mdi-{{ `chevron-${miniVariant ? 'right' : 'left'}` }}</v-icon>
      </v-btn>

      <v-toolbar-title>{{ title }}</v-toolbar-title>
      <v-spacer />
      <b style="color: red">{{ $auth.user?.username }}</b>
      <v-btn
        icon
        @click.stop="rightDrawer = !rightDrawer"
        @click = login
      >
        <v-icon @click="userLogout">mdi-location-exit</v-icon>
      </v-btn>
    </v-app-bar>

    <v-main>
      <v-container>
        <Nuxt />
      </v-container>
    </v-main>

    <v-footer
      :absolute="!fixed"
      app
    >
      <span>&copy; {{ new Date().getFullYear() }}</span>
    </v-footer>
  </v-app>
</template>

<script>
import login from "@/pages/login";

export default {
  name: 'DefaultLayout',
  data () {
    return {
      clipped: false,
      drawer: true,
      fixed: false,
      items: [
        {
          icon: 'mdi-apps',
          title: 'Home page',
          to: '/'
        },
        {
          icon: 'mdi-account-multiple',
          title: 'Quản lý users',
          to: '/managerUser'
        },
        {
          icon: 'mdi-gift',
          title: 'Quản lý gói',
          to: '/manageQuota'
        },
        {
          icon: 'mdi-shield-lock-open',
          title: 'Quản lý Nạp/Xả',
          to: '/ManageAssignRevoke'
        },
        {
          icon: 'mdi-database',
          title: 'Quản lý kho',
          to: '/manageStorage'
        },
        {
          icon: 'mdi-package-variant',
          title: 'Quản lý Gói',
          to: '/managePackage'
        },
        {
          icon: 'mdi-file-export-outline',
          title: 'Export Token',
          to: '/export'
        },
        {
          icon: 'mdi-file-import-outline',
          title: 'Import Token',
          to: '/import'
        },
      ],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: 'Wallet',
      currentUsername: 'Admin'
    }
  },
  methods : {
    async userLogout() {
      await this.$auth.logout();
    },
    login(){
      this.$router.push('/login')
    }
  }
}
</script>
