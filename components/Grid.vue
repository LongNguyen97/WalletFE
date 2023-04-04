<template>

  <div
    :options="options"
  ></div>
</template>
<script>
/* Add application styles & imports to this file! */

import pq from 'pqgridf';
import 'jquery-ui-pack/jquery-ui.css';
import 'jquery-ui-pack/jquery-ui.structure.css';
import 'jquery-ui-pack/jquery-ui.theme.css';
import 'pqgridf/pqgrid.min.css';
import 'pqgridf/pqgrid.ui.min.css';
import 'pqgridf/themes/steelblue/pqgrid.css';

export default {
  name: "Grid",
  props: ['options'],
  data () {
    return {
      grid: null,
    };
  },
  watch: {
    options() {
      if (this.grid) this.grid.destroy();
      this.grid = pq.grid(this.$el, this.options);
      this.grid.refreshDataAndView();
      this.$emit('gridInitialized');
    }
  },
  methods: {
    refreshDataAndView() {
      this.grid?.refreshDataAndView();
    },
    addRow(row) {
      this.grid.addRow({
        newRow: row,
        rowIndx: 0,
      });
    },
    getRow() {
      return this.grid.getData();
    },
    getChangeData() {
      return this.grid.getChanges();
    },
  }
}
</script>

<style>
.toolbar-style > button{
  border-radius: 5px;
}
.toolbar-xxx {
  display: contents !important;
  align-items : center;
}
</style>
