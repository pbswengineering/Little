#include "global.h"
void pass1(file_name)
     char *file_name;
{
  if (verbose_flag)
    fprintf(stderr, "reading %s\n", file_name);
  source_open(file_name);
  init_scraps();
  macro_names = NULL;
  file_names = NULL;
  user_names = NULL;
  {
    int c = source_get();
    while (c != EOF) {
      if (c == nw_char)
        {
          c = source_get();
          switch (c) {
            case 'r':
                  c = source_get();
                  nw_char = c;
                  update_delimit_scrap();
                  break;
            case 'O':
            case 'o': {
                        Name *name = collect_file_name(); /* returns a pointer to the name entry */
                        int scrap = collect_scrap();      /* returns an index to the scrap */
                        {
                          Scrap_Node *def = (Scrap_Node *) arena_getmem(sizeof(Scrap_Node));
                          def->scrap = scrap;
                          def->next = name->defs;
                          name->defs = def;
                        }
                      }
                      break;
            case 'D':
            case 'd': {
                        Name *name = collect_macro_name();
                        int scrap = collect_scrap();
                        {
                          Scrap_Node *def = (Scrap_Node *) arena_getmem(sizeof(Scrap_Node));
                          def->scrap = scrap;
                          def->next = name->defs;
                          name->defs = def;
                        }
                      }
                      break;
            case 'u':
            case 'm':
            case 'f': /* ignore during this pass */
                      break;
            default:  if (c==nw_char) /* ignore during this pass */
                        break;
                      fprintf(stderr,
                              "%s: unexpected @ sequence ignored (%s, line %d)\n",
                              command_name, source_name, source_line);
                      break;
          }
        }
      c = source_get();
    }
  }
  if (tex_flag)
    search();
  {
    reverse_lists(file_names);
    reverse_lists(macro_names);
    reverse_lists(user_names);
  }
}
