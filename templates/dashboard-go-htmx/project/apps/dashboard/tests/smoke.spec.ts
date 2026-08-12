import { test, expect } from '@playwright/test'

test('health page is reachable', async ({ page }) => {
  const response = await page.request.get('/healthz')
  expect(response.ok()).toBeTruthy()
})

test('unauthenticated users are sent to login', async ({ page }) => {
  await page.goto('/dashboard')
  await expect(page).toHaveURL(/login/)
})
