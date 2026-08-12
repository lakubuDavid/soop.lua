type ToastKind = 'success' | 'error' | 'info'

type Toast = { message: string; kind: ToastKind }

function toastRegion() {
  return {
    items: [] as Toast[],
    add(message: string, kind: ToastKind = 'info') {
      this.items.push({ message, kind })
      window.setTimeout(() => this.items.shift(), 4000)
    },
  }
}

window.addEventListener('app:toast', (event) => {
  const detail = (event as CustomEvent<{ message: string; kind?: ToastKind }>).detail
  document.querySelector<HTMLElement>('#toast-region') && detail
})

export { toastRegion }
