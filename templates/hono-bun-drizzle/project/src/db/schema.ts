import { integer, sqliteTable, text, real } from "drizzle-orm/sqlite-core";

const table = sqliteTable;

export const NotesTable = table("notes", {
  id: integer().primaryKey(),
  content: text().notNull(),
  completed: integer({ mode: "boolean" }).default(false),
});
