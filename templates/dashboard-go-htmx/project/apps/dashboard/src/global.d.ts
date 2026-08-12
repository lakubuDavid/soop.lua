export {}

declare global {
  interface Window {
    Alpine: unknown
    htmx: { trigger(target: string | Element, event: string): void }
  }
}
