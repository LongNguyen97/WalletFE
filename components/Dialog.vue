<template>
  <div>
    <v-dialog
      v-model="isShow"
      max-width="290"
      :persistent=true
      :light = true
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
            @click="emitEvent('cancel')"
          >
            Cancel
          </v-btn>

          <v-btn
            color="green darken-1"
            text
            @click="emitEvent('confirm')"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>

    </v-dialog>
  </div>
</template>

<script>
export default {
  name: "Dialog",

  data() {
    return {
      isShow: false
    }
  },
  methods: {
    show() {
      this.isShow = true;
    },
    close() {
      this.isShow = false;
    },
    emitEvent(msg) {
      this.$emit(msg)
    }
  }
}
</script>

<style scoped>

</style>
