<template>
  <div class="footer">
    <v-snackbar
      color="success"
      outlined
      v-model="snackbar.snackbar"
      :timeout="snackbar.timeout"

    >
      <b>{{ snackbar.text }}</b>

      <template v-slot:action="{ attrs }">
        <v-btn
          color="blue"
          text
          v-bind="attrs"
          @click="snackbar.snackbar = false"
        >
          Close
        </v-btn>
      </template>
    </v-snackbar>

    <v-dialog
      v-model="dialogDelete"
      max-width="290"
    >
      <v-card>
        <v-card-title class="text-h5">
          Are you sure you want to delete?
        </v-card-title>
        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="green darken-1"
            text
            @click="dialogDelete = false"
          >
            Cancel
          </v-btn>

          <v-btn
            color="green darken-1"
            text
            @click="deleteUser"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>

    </v-dialog>
  </div>
</template>

<style>
.nuxt-logo {
  height: 180px;
}
</style>
