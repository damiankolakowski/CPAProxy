/**
	Header file used by CPAProxy to start Tor.
 */
int tor_main(int argc, const char *argv[]);
void tor_reload(void);

const char tor_git_revision[] = @TOR_GIT_REVISION@;
