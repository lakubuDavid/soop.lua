function tableSearch() {
  return {
    query: '',
    filter() {
      const query = this.query.toLowerCase()
      const root = (this as unknown as { $el: HTMLElement }).$el
      root.querySelectorAll<HTMLTableRowElement>('tbody tr').forEach((row) => {
        row.hidden = query !== '' && !row.innerText.toLowerCase().includes(query)
      })
    },
  }
}

export { tableSearch }
