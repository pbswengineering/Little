#include "global.h"
void write_files(files)
     Name *files;
{
  while (files) {
    write_files(files->llink);
    {
      static char temp_name[] = "nw000000";
      static int temp_name_count = 0;
      char indent_chars[500];
      int temp_file_fd;
      FILE *temp_file;
    
      for( temp_name_count = 0; temp_name_count < 10000; temp_name_count++) {
        sprintf(temp_name,"nw%06d", temp_name_count);
    #ifdef O_EXCL
        if (-1 != (temp_file_fd = open(temp_name, O_CREAT|O_WRONLY|O_EXCL))) {
           temp_file = fdopen(temp_file_fd, "w");
           break;
        }
    #else
        if (0 != (temp_file = fopen(temp_name, "a"))) {
           if ( 0L == ftell(temp_file)) {
              break;
           } else {
              fclose(temp_file);
              temp_file = 0;
           }
        }
    #endif
      }
      if (!temp_file) {
        fprintf(stderr, "%s: can't create %s for a temporary file\n",
                command_name, temp_name);
        exit(-1);
      }  
      if (verbose_flag)
        fprintf(stderr, "writing %s [%s]\n", files->spelling, temp_name);
      write_scraps(temp_file, files->defs, 0, indent_chars,
                   files->debug_flag, files->tab_flag, files->indent_flag, 0);
      fclose(temp_file);
      if (compare_flag)
        {
          FILE *old_file = fopen(files->spelling, "r");
          if (old_file) {
            int x, y;
            temp_file = fopen(temp_name, "r");
            do {
              x = getc(old_file);
              y = getc(temp_file);
            } while (x == y && x != EOF);
            fclose(old_file);
            fclose(temp_file);
            if (x == y)
              remove(temp_name);
            else {
              remove(files->spelling);
              rename(temp_name, files->spelling);
            }
          }
          else
            rename(temp_name, files->spelling);
        }
      else {
        remove(files->spelling);
        rename(temp_name, files->spelling);
      }
    }
    files = files->rlink;
  }
}
