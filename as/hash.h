#ifndef __HASH_H
#define __HASH_H

/*
 * This file implements the symbol table as a simple hash table.
 */

#include <stdint.h>

/**
 * The number of bins in the table.
 */
#define HASH_TAB_SIZE 256

/**
 * Within the hash table, there are HASH_TAB_SIZE bins. If there is a collision
 * (i.e. two or more items wanting to be in the same bin), then a linked list
 * of hash_entry_t is formed.
 */
typedef struct hash_entry {
	char *label;
	int lineno;
	struct hash_entry *next;
} hash_entry_t;

/**
 * The table itself.
 *
 * The table is implemented as a simple array. hash_get() and hash_put() call
 * the hash function hashf() to find the index in the array. If there are
 * collisions, the element in the array will contain a linked list.
 *
 * You shouldn't access the table directly. Instead use get/put functions.
 *
 * You must allocate the table with hash_new() and free it with hash_free().
 */
typedef struct hash {
	hash_entry_t *table[HASH_TAB_SIZE];
} hash_t;

/**
 * Allocates a new hash_t on the heap (free it with hash_free()).
 *
 * @return a new hash table or NULL if malloc() failed.
 */
hash_t *hash_new(void);

/**
 * Insert a line number into hash table h with key 'label'.
 *
 * @param h the hash table to insert into.
 * @param label the key.
 * @param lineno the value.
 */
void hash_put(hash_t *h, char *label, int lineno);

/**
 * Get the line number associated with key 'label' from hash table h.
 *
 * @param h the hash table to query.
 * @param label the key.
 * @return the line number or -1 if not found.
 */
int hash_get(hash_t *h, char *label);

/**
 * De-allocate the memory used by hash table h.
 *
 * @param h the hash table to free().
 */
void hash_free(hash_t *h);

/**
 * Compute a hash code between 0 and HASH_TAB_SIZE-1.
 *
 * @param label a string.
 * @return hashcode for the string.
 */
uint8_t hashf(char *label);

#endif /* __HASH_H */
