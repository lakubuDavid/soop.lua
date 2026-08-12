import { db } from "../db";
import { eq, and, or, like, desc, asc, sql } from "drizzle-orm";
import { NotesTable } from "./schema";

// Basic CRUD Queries

// Create a new note
export async function createNote(content: string) {
  return await db.insert(NotesTable).values({
    content,
    completed: false,
  }).returning();
}

// Read all notes
export async function getAllNotes() {
  return await db.select().from(NotesTable);
}

// Get a specific note by ID
export async function getNoteById(id: number) {
  return await db
    .select()
    .from(NotesTable)
    .where(eq(NotesTable.id, id))
    .limit(1);
}

// Update a note
export async function updateNote(id: number, data: { content?: string; completed?: boolean }) {
  return await db
    .update(NotesTable)
    .set(data)
    .where(eq(NotesTable.id, id))
    .returning();
}

// Delete a note
export async function deleteNote(id: number) {
  return await db
    .delete(NotesTable)
    .where(eq(NotesTable.id, id))
    .returning();
}

// Advanced Queries

// Get all completed notes
export async function getCompletedNotes() {
  return await db
    .select()
    .from(NotesTable)
    .where(eq(NotesTable.completed, true));
}

// Get all incomplete notes
export async function getIncompleteNotes() {
  return await db
    .select()
    .from(NotesTable)
    .where(eq(NotesTable.completed, false));
}

// Search notes by content
export async function searchNotes(searchTerm: string) {
  return await db
    .select()
    .from(NotesTable)
    .where(like(NotesTable.content, `%${searchTerm}%`));
}

// Get notes sorted by ID (newest first)
export async function getNotesNewestFirst() {
  return await db
    .select()
    .from(NotesTable)
    .orderBy(desc(NotesTable.id));
}

// Bulk operations

// Mark multiple notes as completed
export async function markNotesCompleted(ids: number[]) {
  return await db
    .update(NotesTable)
    .set({ completed: true })
    .where(
      or(...ids.map(id => eq(NotesTable.id, id)))
    )
    .returning();
}

// Delete completed notes
export async function deleteCompletedNotes() {
  return await db
    .delete(NotesTable)
    .where(eq(NotesTable.completed, true))
    .returning();
}

// Example usage with pagination
export async function getPaginatedNotes(page: number = 1, pageSize: number = 10) {
  const offset = (page - 1) * pageSize;
  
  const notes = await db
    .select()
    .from(NotesTable)
    .limit(pageSize)
    .offset(offset)
    .orderBy(desc(NotesTable.id));

  const totalCount = await db
    .select({ count: sql<number>`count(*)` })
    .from(NotesTable);

  return {
    notes,
    totalCount: totalCount[0].count,
    currentPage: page,
    pageSize,
    totalPages: Math.ceil(totalCount[0].count / pageSize)
  };
}
