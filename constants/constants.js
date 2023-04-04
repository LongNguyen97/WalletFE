export default Object.freeze(
  {
    options: {
      locale: 'en',
      height: 'flex',
      maxHeight : '100%',
      wrap: true,
      showTop: false,
      showToolbar: false,
      showBottom: false,
      reactive: true,
      headerMenu: true,
      stripeRows: true,
      numberCell: {
        show: false
      },
      editModel: {
        onSave: 'downFocus',
        keyUpDown: false,
        clicksToEdit: 2
      },
      filterModel: {
        on: true,
        mode: 'AND',
        header: true,
        menuIcon: false, // show filter row icon initially.
      },
      animModel: {
        on: true
      },
      menuIcon: false, // show header menu icon initially.
      menuUI: {
        tabs: ['filter'], // display only filter tab.
      },
      selectionModel: { type: 'cell' },
    }
  }
)
