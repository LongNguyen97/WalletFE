<template>
  <div class="footer">
    <v-snackbar
      :color="snackbar.color"
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
  </div>
</template>

<script>
export default {
  name: "snackbar",
  props : ['snackbar']
}
</script>

<style scoped>

</style>
