# ================== Bluetooth Unpair + GATT Cleanup Script ==================

$Source = @"
using System;
using System.Runtime.InteropServices;

public static class BTRemover
{
    [DllImport("BluetoothAPIs.dll", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
    public static extern UInt32 BluetoothRemoveDevice(IntPtr pAddress);

    public static UInt32 Unpair(ulong BTAddress)
    {
        GCHandle pinnedAddr = GCHandle.Alloc(BTAddress, GCHandleType.Pinned);
        IntPtr pAddress = pinnedAddr.AddrOfPinnedObject();
        UInt32 result = BluetoothRemoveDevice(pAddress);
        pinnedAddr.Free();
        return result;
    }
}
"@

# Load the native BluetoothRemoveDevice wrapper
Add-Type -TypeDefinition $Source -PassThru | Out-Null

Function Get-BTDevice {
    Get-PnpDevice -Class Bluetooth |
        Where-Object { $_.HardwareID -match 'DEV_' } |
        ForEach-Object {
            $hid = $_.HardwareID[0]

            # Extract 12 hex chars after DEV_ as address if possible
            $m = [regex]::Match($hid, 'DEV_([0-9A-Fa-f]{12})')

            $addr = 0
            if ($m.Success) {
                $addr = [uint64]("0x{0}" -f $m.Groups[1].Value)
            }

            [pscustomobject]@{
                Status       = $_.Status
                Class        = $_.Class
                FriendlyName = $_.FriendlyName
                HardwareID   = $_.HardwareID
                InstanceId   = $_.InstanceId
                Address      = $addr
            }
        }
}

################## Execution Begins Here ################

$BTDevices = @(Get-BTDevice) # Force array

Do {
    if ($BTDevices.Count) {
        "`n******** Bluetooth Devices ********`n" | Write-Host

        for ($i = 0; $i -lt $BTDevices.Count; $i++) {
            $dev = $BTDevices[$i]
            $addrText = if ($dev.Address -ne 0) { $dev.Address } else { "<no BT address>" }

            ('{0,5} - {1} ({2}/{3}/{4})' -f ($i + 1), $dev.FriendlyName, $dev.Status, $dev.Class, $addrText) |
                Write-Host
        }

        $selected = Read-Host "`nSelect a device to remove (0 to Exit)"
        if ([int]$selected -in 1..$BTDevices.Count) {
            $dev = $BTDevices[[int]$selected - 1]
            'Removing device: {0}' -f $dev.FriendlyName | Write-Host

            if ($dev.Address -ne 0) {
                # Real paired device → unpair via BluetoothRemoveDevice
                $Result = [BTRemover]::Unpair($dev.Address)
                if ($Result -eq 0) {
                    "Device removed successfully (unpaired)." | Write-Host
                }
                else {
                    $msg = (New-Object System.ComponentModel.Win32Exception([int]$Result)).Message
                    "BluetoothRemoveDevice failed. Error $($Result): $msg" | Write-Host
                }
            }
            else {
                # No BT address → treat as GATT / LE service, remove PnP node
                Write-Host "No Bluetooth address, uninstalling PnP device via pnputil..."
                pnputil.exe /remove-device "$($dev.InstanceId)" | Write-Host
                if ($LASTEXITCODE -eq 0) {
                    "PnP device uninstall requested successfully." | Write-Host
                }
                else {
                    "pnputil failed with exit code $LASTEXITCODE." | Write-Host
                }
            }
        }
    }
    else {
        "`n********* No devices found ********" | Write-Host
    }

} while ( ($BTDevices = @(Get-BTDevice)) -and [int]$selected )

Write-Host "`n`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
