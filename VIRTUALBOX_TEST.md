# Testing GamebianOS in VirtualBox

Quick guide to build and test GamebianOS ISO in VirtualBox.

## Step 1: Install Prerequisites

```bash
sudo apt update
sudo apt install -y live-build live-boot live-config live-config-systemd \
    calamares calamares-settings-debian xorriso isolinux syslinux-utils \
    grub-pc-bin grub-efi-amd64-bin mtools dosfstools squashfs-tools
```

## Step 2: Build the ISO

Navigate to the Installer directory and run the build script:

```bash
cd /home/khinds/Dropbox/Current-Projects/GamebianOS/Installer
sudo ./build-iso.sh
```

**Note**: The first build takes 30-120 minutes as it downloads all packages. Subsequent builds are faster.

## Step 3: Create VirtualBox VM

### Option A: Using VirtualBox GUI

1. **Open VirtualBox** and click "New"
2. **Name**: `GamebianOS Test`
3. **Type**: Linux
4. **Version**: Debian (64-bit)
5. **Memory**: 4096 MB (4GB) minimum, 8192 MB (8GB) recommended
6. **Hard Disk**: Create a virtual hard disk
   - **Size**: 64GB minimum (128GB recommended)
   - **Type**: VDI (VirtualBox Disk Image)
   - **Storage**: Dynamically allocated

### Option B: Using Command Line

```bash
VBoxManage createvm --name "GamebianOS Test" --ostype "Debian_64" --register
VBoxManage modifyvm "GamebianOS Test" --memory 4096 --vram 128
VBoxManage createhd --filename "~/VirtualBox VMs/GamebianOS Test/GamebianOS.vdi" --size 64000
VBoxManage storagectl "GamebianOS Test" --name "SATA Controller" --add sata
VBoxManage storageattach "GamebianOS Test" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "~/VirtualBox VMs/GamebianOS Test/GamebianOS.vdi"
```

## Step 4: Configure VM Settings

### Essential Settings:

1. **System → Processor**:
   - Enable PAE/NX (if available)
   - Enable VT-x/AMD-V
   - Processors: 2-4 cores

2. **Display → Screen**:
   - Video Memory: 128 MB (or higher)
   - Enable 3D Acceleration (if available)

3. **Storage → Controller: IDE**:
   - Add optical drive
   - Choose disk: Select your `GamebianOS-1.0-amd64.iso` file

4. **Network**:
   - Adapter 1: NAT (default, works for most cases)
   - Or Bridged Adapter (if you need network access)

### Optional but Recommended:

- **Audio**: Enable audio output
- **USB**: Enable USB 2.0 or 3.0 controller
- **Shared Clipboard**: Bidirectional (for convenience)

## Step 5: Boot and Install

1. **Start the VM** (click Start or run `VBoxManage startvm "GamebianOS Test"`)
2. **Boot from ISO**: The VM should automatically boot from the ISO
3. **Select boot option**: Choose "GamebianOS Live (Qt Installer)"
4. **Wait for desktop**: LXQt desktop will load with installer icon
5. **Run installer**: Double-click "Install GamebianOS" icon
6. **Follow wizard**: 
   - Partition the virtual disk
   - Create user account
   - Install packages
7. **Reboot**: After installation, remove ISO from storage and reboot

## Step 6: Post-Installation

After rebooting, the system should:
- Auto-login to your user
- Start Steam Big Picture automatically
- Be ready to use!

## Troubleshooting

### VM Won't Boot from ISO

**Problem**: VM boots to black screen or error

**Solutions**:
1. Check that ISO is attached to IDE controller
2. Verify ISO file is not corrupted (check checksums)
3. Try enabling EFI in System → Motherboard → Enable EFI
4. Increase video memory to 128MB or higher

### Installation Fails

**Problem**: Installer crashes or fails

**Solutions**:
1. Increase VM memory to 8GB
2. Allocate more disk space (64GB+)
3. Check VirtualBox logs: `VBoxManage showvminfo "GamebianOS Test"`
4. Try booting with "Safe Graphics" option

### Slow Performance

**Problem**: VM is very slow

**Solutions**:
1. Enable hardware acceleration (VT-x/AMD-V)
2. Allocate more CPU cores (2-4)
3. Increase video memory
4. Enable 3D acceleration (if supported)
5. Close other applications on host

### Network Not Working

**Problem**: No internet in VM

**Solutions**:
1. Check VM network adapter is enabled
2. Try switching from NAT to Bridged Adapter
3. Verify host network is working
4. Check VirtualBox network settings

### Steam Won't Start

**Problem**: Steam doesn't launch after install

**Solutions**:
1. Check graphics drivers: `lspci | grep VGA`
2. Install drivers manually if needed
3. Check Steam logs: `~/.steam/logs/`
4. Try launching from terminal: `steam -bigpicture`

## Quick Commands

### Start VM
```bash
VBoxManage startvm "GamebianOS Test"
```

### Stop VM
```bash
VBoxManage controlvm "GamebianOS Test" poweroff
```

### Attach ISO
```bash
VBoxManage storageattach "GamebianOS Test" \
    --storagectl "IDE Controller" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium "/path/to/GamebianOS-1.0-amd64.iso"
```

### Detach ISO
```bash
VBoxManage storageattach "GamebianOS Test" \
    --storagectl "IDE Controller" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium "none"
```

### View VM Info
```bash
VBoxManage showvminfo "GamebianOS Test"
```

## Recommended VM Settings Summary

```
Name: GamebianOS Test
OS: Debian 64-bit
Memory: 4096-8192 MB
CPU: 2-4 cores
Video Memory: 128 MB
3D Acceleration: Enabled
Hard Disk: 64-128 GB (dynamic)
Network: NAT or Bridged
Audio: Enabled
USB: USB 2.0 or 3.0
```

## Tips

1. **First Boot**: The live environment loads faster than installing
2. **Test Before Install**: Try the live environment first to verify everything works
3. **Snapshot Before Install**: Create a VM snapshot before installation for easy rollback
4. **Guest Additions**: Install VirtualBox Guest Additions after installation for better performance
5. **Full Screen**: Press Right Ctrl + F to toggle full screen mode

## Next Steps

After successful installation:
1. Test Steam Big Picture mode
2. Try switching to desktop (Ctrl+Alt+D)
3. Install VirtualBox Guest Additions for better integration
4. Test gaming performance (if applicable)
5. Verify all features work as expected
