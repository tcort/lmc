#include "config.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hash.h"

/*
 * This file implements the symbol table as a simple hash table.
 */

/**
 * Allocates a new hash_t on the heap (free it with hash_free()).
 *
 * @return a new hash table or NULL if malloc() failed.
 */
hash_t *hash_new(void) {

	hash_t *h;

	h = (hash_t *) malloc(sizeof(hash_t));
	if (h == NULL) {
		return h;
	}
	memset(h, '\0', sizeof(hash_t));

	return h;
}

/**
 * Insert a line number into hash table h with key 'label'.
 *
 * @param h the hash table to insert into.
 * @param label the key.
 * @param lineno the value.
 */
void hash_put(hash_t *h, char *label, int lineno) {

	uint8_t hash;
	hash_entry_t *entry;

	if (h == NULL) {
		return;
	}

	hash = hashf(label);

	entry = (hash_entry_t *) malloc(sizeof(hash_entry_t));
	if (entry == NULL) {
		return;
	}
	memset(entry, '\0', sizeof(hash_entry_t));

	entry->label = label;
	entry->lineno = lineno;
	entry->next = h->table[hash];

	h->table[hash] = entry;

	return;
}

/**
 * Get the line number associated with key 'label' from hash table h.
 *
 * @param h the hash table to query.
 * @param label the key.
 * @return the line number or -1 if not found.
 */
int hash_get(hash_t *h, char *label) {
	
	uint8_t hash;
	size_t labellen;
	hash_entry_t *entry;

	if (h == NULL) {
		return -1;
	}
	
	hash = hashf(label);

	if (h->table[hash] == NULL) {
		/* no match */
		return -1;
	} else if (h->table[hash]->next == NULL) {
		/* exact match, no collision, return line # straight away */
		return h->table[hash]->lineno; 
	} else {
		/* multiple items with the same hash, search for match */
		labellen = strlen(label);

		for (entry = h->table[hash]; entry != NULL; entry = entry->next) {
			if (strlen(entry->label) == labellen && strcmp(label, entry->label) == 0) {
				return entry->lineno;
			}
		}
	}

	return -1;
}

/**
 * De-allocate the memory used by hash table h.
 *
 * @param h the hash table to free().
 */
void hash_free(hash_t *h) {
	
	int i;
	hash_entry_t *entry, *old;

	if (h == NULL) {
		return;
	}

	for (i = 0; i < HASH_TAB_SIZE; i++) {
		if (h->table[i] != NULL) {
			entry = h->table[i];

			while (entry != NULL) {
				old = entry;
				entry = entry->next;
				if (old->label != NULL) {
					free(old->label);
					old->label = NULL;
				}
				free(old);
				old = NULL;
			}

			h->table[i] = NULL;
		}
	}

	free(h);
	h = NULL;

	return;
}

/**
 * Compute a hash code between 0 and HASH_TAB_SIZE-1.
 *
 * @param label a string.
 * @return hashcode for the string.
 */
uint8_t hashf(char *label) {

	uint8_t hash;

	if (label == NULL || strlen(label) == 0) {
		/* Maybe this should be an error? */
		hash = 0;
	} else {
		/* String is at least 1 character which means the char[]
		 * has at least 2 elements (at least a character and either
		 * null byte or another character).
		 *
		 * If we just used the first character, then we would have
		 * more collisions (since most characters we'll see are
		 * only in the range 'A'-'Z'. Instead we combine the lower
		 * 4 bits from the first two bytes.
		 *
		 * I don't seem much of a benefit of doing any more than
		 * the first two bytes.
		 */
		hash = (((label[0] & 0x0f) << 4) | (label[1] & 0x0f));
	}

	/* keep the hash within the bounds of the array */
	return (hash % HASH_TAB_SIZE);
}

