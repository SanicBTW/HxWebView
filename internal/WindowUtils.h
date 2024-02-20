Dynamic get_window_position(webview_t w); 
void set_window_position(webview_t w, int newX, int newY); 
void set_window_decoration(webview_t w, bool state); 
void set_window_topmost(webview_t w, bool state); 
void set_window_taskbar_hint(webview_t w, bool state); 
void add_destroy_signal(webview_t w); 
bool events_pending(); 
void run_main_iteration(bool state); 
bool is_open(); 

#include "WindowUtils.cpp"