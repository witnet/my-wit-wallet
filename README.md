# witnet_wallet


# Build Instructions

## Windows

- ##### Install [Flutter SDK](https://flutter.dev/docs/get-started/install)

  - Update your path
    - From the Start search bar, enter ‘env’ and select **Edit environment variables for your account**.
    - Under **User variables** check if there is an entry called **Path**:
      - If the entry exists, append the full path to `flutter\bin` using `;` as a separator from existing values.
      - If the entry doesn’t exist, create a new user variable named `Path` with the full path to `flutter\bin` as its value.
    - close / open a new PowerShell console window
      
  - If you use an IDE you need to setup the editor to use the flutter SDK

- ##### Install Visual Studio 2019

  - The (free) Community Version of [Visual Studio 2019](https://visualstudio.microsoft.com/downloads/)- not to be confused with Visual Studio Code

    - Once Visual Studio 2019 is installed - open **Visual Studio Installer** 

  - modify the Visual Studio 2019 installation

    ![](https://github.com/parodyBit/witnet_wallet/blob/main/assets/readme/visual_studio_installer.PNG)

  - Under **Mobile & Desktop** select **Desktop development with C++** 	

    ![](https://github.com/parodyBit/witnet_wallet/blob/main/assets/readme/desktop_dev_cpp.PNG)

  - Ensure these options are selected for the **Desktop development with C++** workload

    ![](https://github.com/parodyBit/witnet_wallet/blob/main/assets/readme/desktop_dev_cpp_options.PNG)

- Download the **witnet_wallet** repository 

  - navigate to the directory in **PowerShell** (run as administrator)

  - get the required flutter packages

    - `PS> flutter pub get`
    - `PS> flutter pub upgrade`

  - run the doctor on flutter to check the pre-build

    - `PS> flutter doctor`

    - should look something like this

      ![](https://github.com/parodyBit/witnet_wallet/blob/main/assets/readme/flutter_doctor.PNG)

  - build the application for windows

    - `PS> flutter build windows`

  - The application `witnet_wallet.exe` will be in `\witnet_wallet-main\build\windows\runner\Release`