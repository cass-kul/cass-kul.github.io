#ifndef LINKED_LIST_H
#define LINKED_LIST_H

struct ListNode
{
    int value;
    struct ListNode *next;
};

struct List
{
    struct ListNode *first;
};

typedef enum
{
    OK = 1,
    UNINITIALIZED_LIST = -1,
    OUT_OF_MEMORY = -2,
    INDEX_OUT_OF_BOUNDS = -3,
    UNINITIALIZED_RETVAL = -4,
} status;

struct List *list_create();

status list_append(struct List *list, int value);

int list_length(struct List *list);

status list_get(struct List *list, int index, int *value);

status list_print(struct List *list);

status list_remove_item(struct List *list, int index);

status list_delete(struct List *list);

status list_insert(struct List *list, int index, int value);

#endif