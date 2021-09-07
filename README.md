# btRemover
Unpair and remove your Bluetooth device from Windows 10, even when the standard Windows 10 methods won't work or when the device keeps coming back on it's own.  
This PowerShell script was written by Keith A. Miller and posted on the Microsoft community thread [Unable to remove bluetooth device on windows 10](https://answers.microsoft.com/en-us/windows/forum/windows_10-networking-winpc/unable-to-remove-bluetooth-device-on-windows-10/ea6da83d-583e-4b80-8714-367510879f07?messageId=eacc108d-9d7b-4e82-9280-60916bd702f1&page=14).  
    
This version replaces the old C# [btRemover](https://github.com/lflfm/btRemover) that I wrote, which was hard to get and use.  
  
## instructions
1. Download the removeBluetoothDevice.ps1 file
2. Right-click it and select "**run with PowerShell**" _alternative - if you get an error like "scripts are disabled in this system", this should work: copy/paste contents of the file into a PowerShell window_
3. You should see the list of paired BlueTooth devices, plus their status, class and address.
4. Choose the one you wish to remove by typing the number in the list
5. Make a donation to a local non-profit and/or come back to the web and send thanks to Keith A. Miller and myself if it worked... or post your problem if it didn't _(and donate something somewhere anyway, because you can)_
  
*note:* if you get an error that the file is not digitally signed, you can open a PowerShell window and temporarily disable this check with the command `Set-ExecutionPolicy -Scope Process -ExecutionPolicy  ByPass`, it's also possible to permanently disable it, but don't.  
  
### picture worth 95 words
![instructions in an image](images/how2use.png?raw=true "Instructions in an image")
