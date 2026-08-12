import { createMiddleware } from "hono/factory";

export const %NAME% = () => createMiddleware(async (c,next)=>{
  await next()
})
