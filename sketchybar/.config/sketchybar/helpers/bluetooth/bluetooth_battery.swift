import IOBluetooth

// Reads battery levels via private IOBluetoothDevice selectors that macOS
// Control Center uses. Outputs one line per paired device:
//   address|name|connected|battery
// battery is -1 when unavailable.

typealias IntGetter = @convention(c) (AnyObject, Selector) -> Int

func readIntSel(_ device: IOBluetoothDevice, _ name: String) -> Int {
    let sel = NSSelectorFromString(name)
    guard device.responds(to: sel) else { return -1 }
    let imp = unsafeBitCast(device.method(for: sel), to: IntGetter.self)
    return imp(device, sel)
}

func batteryFor(_ device: IOBluetoothDevice) -> Int {
    // Prefer the combined level (earbuds/case); fall back to single (headphones)
    let combined = readIntSel(device, "batteryPercentCombined")
    if combined > 0 { return combined }
    let single = readIntSel(device, "batteryPercentSingle")
    if single > 0 { return single }
    let headset = readIntSel(device, "headsetBattery")
    if headset > 0 { return headset }
    return -1
}

guard let paired = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else {
    exit(0)
}

for device in paired {
    let name      = device.name ?? "Unknown"
    let address   = device.addressString ?? ""
    let connected = device.isConnected() ? "1" : "0"
    let battery   = batteryFor(device)
    print("\(address)|\(name)|\(connected)|\(battery)")
}
