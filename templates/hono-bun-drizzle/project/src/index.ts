import { Hono } from "hono";
import { getAllNotes } from "../src/db/queries";

const app = new Hono()

app.get("/",(c)=>{
  return c.json(getAllNotes())
})


export default { 
  port: process.env["PORT"] ?? 3000, 
  fetch: app.fetch, 
} 
