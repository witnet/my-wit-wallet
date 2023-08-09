#ifndef WINDOW_CONFIGURATION_
#define WINDOW_CONFIGURATION_

extern const wchar_t* kFlutterWindowTitle;
extern const unsigned int kFlutterWindowWidth;
extern const unsigned int kFlutterWindowHeight;

int* alignCenter(int screenWidth, int screenHeight);

int* getFlutterWindowPosition();

#endif  // WINDOW_CONFIGURATION_
