import { Hono } from "hono";

const %NAME% = new Hono();
%NAME%.get("/%NAME%", async (c) => {
  c.json({hello:"world"})
});

export default %NAME%;
