# Plans for HxWebView 0.1.0

- MacOS Support (Working with Jonnycat)
- Cleaner code
- More features
- Rewrite the whole codebase
- Full control over the WebView owned Window (***)
    - Pending window state controls (minimize, restore, maximize)
    - Pending changing window icon

# Done so far

- Automatically add NO_PRECOMPILED_HEADERS to Linux Builds (*)
- More control over the GTK Main Loop including Win32 Message Queue
- Macros to copy required Windows DLLs to the output directory (*)
- Fixed Window resizing when changing the position of the Window (Win32 Only)
- Window Examples will be unified in one called "Window Control"
- Fixed passing arguments through binding (*)

# Legend

- (*) This feature will be pushed to the master branch and included in the next Release.
- (**) This feature is pending to be fixed and most likely be fixed in the following commits.
- (***) This feature is currently being worked on.