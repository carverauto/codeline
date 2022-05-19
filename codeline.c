/***
 *
 * codeline.c - BoW codeline for internet.
 *
 * y0y0y0y, JuST WHaT Yo0'V3 BeEN WaITiNG 4... A WaY To RuN A CoDE-LiNE oN
 * iNTeRNeT... YeS, eXPLoIT THe iNFoRMaTiON S00PaH HiWaY aS WeLL aS 
 * Vee-EmM-BeE'S... To CoMPiLE, SiMPLy
 *
 *  1) Change the password to your preference [optional]
 *  2) Change any of the config items to your preference
 *     ie: port number, command names etc [optional]
 *  3) Type "cc -o codeline codeline.c" on the unix prompt
 *  4) Type "codeline" to run.
 *  5) Rejoice in your new found eliteness at running an internet codeline
 *
 * ReMeMBeR - PHeAR BoW
 *                             - THe V3LKR0 K0D3 WaRRi0R - KRaD iN '94
 ***/
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <varargs.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define CODE "code"   /* THIS IS THE PASSWORD HERE!!! MAX 8 CHARACTERS */

/* advanced users only, encrypted password.. define to make it go into effect */
/* sample encrypted password is "code", generate your own if you know how     */

/* #define CR_CODE "K-8kTMnNV1SaM" */

#define PORT 31337    /* PORT NUMBER.. */
#define VER_MAJOR 1   /* version #'s   */
#define VER_MINOR 0
#define BoW 31337
#define KRAD 31337
#define PROMPT "BoW codeline [? for help]# "
#define ADMIN_PROMPT "BoW codeline admin [? for help]# "
#define MOTD "codeline.motd"
#define CODES "codeline.codes"

int soc2;
int parent;
char codes_exe[80];

typedef enum {
   code_post,
   code_list,
   code_admin,
   code_quit
} t_main_menu;

typedef enum {
   code_clear,
   code_motd,
   code_kill,
   code_exit
} t_admin_menu;

typedef void (*t_handler)();

void post_handler();
void list_handler();
void admin_handler();
void quit_handler();
void clear_handler();
void motd_handler();
void kill_handler();
void exit_handler();

typedef struct {
   char         *menu_command;
   char         *command_description;
   t_main_menu   menu_enum;
   t_handler     menu_handler;
} m_main_menu;

typedef struct {
   char         *menu_command;
   char         *command_description;
   t_admin_menu  menu_enum;
   t_handler     menu_handler;
} m_admin_menu;

m_main_menu main_menu[] = {
   "POST",  "Post a code",     code_post,  post_handler,
   "LIST",  "List all codes",  code_list,  list_handler,
   "ADMIN", "Goto admin menu", code_admin, admin_handler,
   "QUIT",  "Disconnect",      code_quit,  quit_handler
};

m_admin_menu admin_menu[] = {
   "CLEAR", "Erase all the codes",       code_clear, clear_handler,
   "MOTD",  "Change the login greeting", code_motd,  motd_handler,
   "KILL",  "Kill the BoW codeline",     code_kill,  kill_handler,
   "QUIT",  "Quit back to main menu",    code_exit,  exit_handler
};

void k_write(soc, out_msg, msg_len)
register int soc;
register char *out_msg;
register int msg_len;
{
 int num_written;
 int num_left;

   num_left = msg_len;

   while(num_left > 0) {
      num_written = write(soc, out_msg, msg_len);
      if (num_written < 0) {
         return;
      }
      num_left -= num_written;
      out_msg  += num_written;
   }
}

void kprintf(fmt, va_alist)
char *fmt;
va_dcl
{
   va_list args;
   int msg_len;
   char out_msg[80];

   va_start(args);
   vsprintf(out_msg, fmt, args);
   for(msg_len=0;msg_len <= 80;msg_len++) {
      if (out_msg[msg_len]==0)
         break;
   }
   k_write(soc2,out_msg,msg_len);
   va_end(args);
}

int check_pw(entered_pw)
char *entered_pw;
{
#ifdef CR_CODE
 char *encr_pw;
 char key[8];
 char salt[3];

   strncpy(key,entered_pw,8);
   strncpy(salt,CR_CODE,2); 
   salt[2] = 0;
   encr_pw = (char *) crypt(key,salt);
   return !strcmp(CR_CODE,encr_pw);
#else
   return !strcmp(CODE,entered_pw);
#endif
}

void admin_menu_proc()
{
  int  cmd_idx,idx2;
  int found;
  char command[11];

   while(BoW == KRAD) {
      kprintf(ADMIN_PROMPT);
      fgets(command,11,stdin);
      command[strlen(command)-2] = 0;
      if (command[0] == 0)
         continue;
      for (cmd_idx = 0; cmd_idx < strlen(command); cmd_idx++) 
         command[cmd_idx] = toupper(command[cmd_idx]);
      found = 0;
      for (cmd_idx = 0; cmd_idx <= code_exit; cmd_idx++) {
         if(!strcmp(admin_menu[cmd_idx].menu_command,command)) {
            (*admin_menu[cmd_idx].menu_handler)();
            found = 1;
            break;
         }
      }
      if (command[0] == '?') {
         kprintf("\nValid commands are:\n");
         for(idx2=0; idx2 <= code_quit; idx2++) {
            kprintf("%-5.5s - %s\n",admin_menu[idx2].menu_command,
                    admin_menu[idx2].command_description);
         }
         kprintf("\n");
      } else if (!found){
         kprintf("%s: Command not found.\n",command);
      } else if (admin_menu[cmd_idx].menu_enum == code_exit) {
         return;
      }
   }
}

void main_menu_proc()
{
  int  cmd_idx,idx2;
  int found;
  char command[11];

   while(BoW == KRAD) {
      kprintf(PROMPT);
      fgets(command,11,stdin);
      command[strlen(command)-2] = 0;
      if (command[0] == 0)
         continue;
      for (cmd_idx = 0; cmd_idx < strlen(command); cmd_idx++) 
         command[cmd_idx] = toupper(command[cmd_idx]);
      found = 0;
      for (cmd_idx = 0; cmd_idx <= code_quit; cmd_idx++) {
         if(!strcmp(main_menu[cmd_idx].menu_command,command)) {
            (*main_menu[cmd_idx].menu_handler)();
            found = 1;
            break;
         }
      }
      if (command[0] == '?') {
         kprintf("\nValid commands are:\n");
         for(idx2=0; idx2 <= code_quit; idx2++) {
            kprintf("%-5.5s - %s\n",main_menu[idx2].menu_command,
                    main_menu[idx2].command_description);
         }
         kprintf("\n");
      } else if (!found){
         kprintf("%s: Command not found.\n",command);
      }
   }
}

void connect_handler()
{
 FILE *motd;
   kprintf("BoW Code-Line for the Information Super Highway\n");
   kprintf("version %d.%d -- BoW - K-RaD in \'94 -\n",
           VER_MAJOR,VER_MINOR);
   motd = fopen(MOTD,"r");
   if (motd != NULL) {
     char message[80];
      while(!feof(motd)) {
         fgets(message,80,motd);
         if (feof(motd))
            break;
         kprintf("%s",message);
      }
   } else {
      kprintf("\n");
   }
   fclose(motd);
   main_menu_proc();
}

void main(argc,argv)
int argc;
char *argv[];
{
  int soc,soc2_len;
  struct sockaddr_in soc_addr;
  struct sockaddr_in soc2_addr;
  int rc;

   strcpy(codes_exe,argv[0]);
   soc = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

   bzero((char *) &soc_addr, sizeof(soc_addr));

   soc_addr.sin_family      = AF_INET;
   soc_addr.sin_addr.s_addr = htonl(INADDR_ANY);
   soc_addr.sin_port        = htons(PORT);

   rc = bind(soc, (struct sockaddr *) &soc_addr, sizeof(soc_addr));
   if (rc != 0) {
      fprintf(stderr,"ERROR: Cannot bind to port. Port busy.\n");
      exit(-1);
   }

   if (fork() != 0) {
      exit(0);
   }
   setpgrp();
   signal(SIGHUP,SIG_IGN);
   if (fork() != 0) {
      exit(0);
   }
   rc = listen(soc, 5);
   if (rc != 0) {
      fprintf(stderr,"ERROR: Unable to listen to port.\n");
      exit(-2);
   }
   for (;;) {
      soc2_len = sizeof(soc2_addr);
      soc2 = accept(soc, (struct sockaddr *) &soc2_addr, &soc2_len);

      if (soc2 < 0) {
         fprintf(stderr,"ERROR: accept() failed\n");
         exit(-3);
      }
      parent = fork();
      if (parent != 0) {
         dup2(soc2,0);
         dup2(soc2,1);
         connect_handler();
         shutdown(soc2, 2);
         close(soc2);
         exit(0);
      }
      close(soc2);
   }
}

void post_handler()
{
  char input[80];
   kprintf("Enter your codes now. Enter a period ('.') by itself to end\n");
   do {
      fgets(input,80,stdin);
      if (input[0] != '.') {
        FILE *codes;
         input[strlen(input)-2] = 0;
         codes = fopen(CODES,"a");
         if (codes != NULL) {
            fprintf(codes,"%s\n",input);
         }
         fclose(codes);
      }
   } while(input[0]!='.');
}

void list_handler()
{
  FILE *codes;
  char input[80];
   codes = fopen(CODES,"r");
   if (codes == NULL) {
      kprintf("No codes at this time.\n");
   } else {
      while (!feof(codes)) {
         fgets(input,80,codes);
         if (!feof(codes)) {
            kprintf("%s",input);
         }
      }
   }
   fclose(codes);
}

void admin_handler()
{
 char auth_code[11];
   kprintf("Please enter your access code: ");
   fgets(auth_code,11,stdin);
   auth_code[strlen(auth_code)-2] = 0;
   if (!check_pw(auth_code)) {
      kprintf("Access denied.\n");
      return;
   }
   admin_menu_proc();
}

void quit_handler()
{
   kprintf("NO CARRIER\n");
   close(soc2);
   exit(0);
}

void clear_handler()
{
   unlink(CODES);
   kprintf("All codes have been deleted.\n");
}

void motd_handler()
{
  char input[80];
   kprintf("Enter the new MOTD, end with a period ('.') on a line by itself\n");
   unlink(MOTD);
   do {
      fgets(input,80,stdin);
      if (input[0] != '.') {
        FILE *motd;
         input[strlen(input)-2] = 0;
         motd = fopen(MOTD,"a");
         if (motd != NULL) {
            fprintf(motd,"%s\n",input);
         }
         fclose(motd);
      }
   } while(input[0]!='.');
}

void kill_handler()
{
   kill(parent,SIGKILL);
   unlink(CODES);
   unlink(MOTD);
   /* in some OS's (HP-UX notably) you can't unlink a file that is running */
   /* get around this by exec-ing an rm..                                  */
   execl("/bin/rm","/bin/rm",codes_exe,(char *)0);
}

void exit_handler()
{
   kprintf("Returning to main menu..\n");
}
