document.addEventListener('alpine:init', () => {
  document.addEventListener('toggle-sidebar', () => {
    document.querySelector('[data-sidebar]')?.classList.toggle('hidden')
  })
})

document.addEventListener('htmx:afterSettle', () => {
  const path = window.location.pathname
  document.querySelectorAll<HTMLAnchorElement>('.sidebar-link').forEach((link) => {
    link.toggleAttribute('aria-current', link.pathname === path)
  })
})
