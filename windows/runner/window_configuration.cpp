#include "window_configuration.h"
#include <windows.h>

const wchar_t* kFlutterWindowTitle = L"myWitWallet";
const unsigned int kFlutterWindowWidth = 430;
const unsigned int kFlutterWindowHeight = 730;

int* alignCenter(int screenWidth, int screenHeight){
  static int pos[2];
  pos[0] = (screenWidth - kFlutterWindowWidth) / 2;
  pos[1] = (screenHeight - kFlutterWindowHeight) / 2;
  return pos;
}

int* getFlutterWindowPosition() {
  // Get the size of the primary monitor
  HMONITOR primaryMonitor = ::MonitorFromWindow(nullptr, MONITOR_DEFAULTTOPRIMARY);
  MONITORINFO monitorInfo;
  monitorInfo.cbSize = sizeof(MONITORINFO);
  ::GetMonitorInfo(primaryMonitor, &monitorInfo);

  int screenWidth = monitorInfo.rcMonitor.right - monitorInfo.rcMonitor.left;
  int screenHeight = monitorInfo.rcMonitor.bottom - monitorInfo.rcMonitor.top;

  return alignCenter(screenWidth, screenHeight);
}
