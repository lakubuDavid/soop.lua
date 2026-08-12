export function confirmAction(message: string): boolean {
  return window.confirm(message)
}

document.addEventListener('click', (event) => {
  const target = (event.target as HTMLElement).closest<HTMLElement>('[data-confirm]')
  if (target && !window.confirm(target.dataset.confirm ?? 'Are you sure?')) {
    event.preventDefault()
  }
})
