# VirtualBox Setup Guide

## Installing Kernel Headers

VirtualBox needs kernel headers to build its kernel modules. Install them with:

```bash
sudo apt update
sudo apt install -y linux-headers-amd64 linux-headers-$(uname -r)
```

Or install the specific version mentioned in the error:

```bash
sudo apt install -y linux-headers-6.12.57+deb13-amd64
```

## Complete Setup Steps

1. **Install kernel headers:**
   ```bash
   sudo apt update
   sudo apt install -y linux-headers-amd64 linux-headers-$(uname -r)
   ```

2. **Install build tools (if not already installed):**
   ```bash
   sudo apt install -y build-essential dkms
   ```

3. **Run VirtualBox configuration:**
   ```bash
   sudo /sbin/vboxconfig
   ```

4. **Verify VirtualBox is working:**
   ```bash
   sudo systemctl status vboxdrv
   ```

## If You Still Have Issues

### Secure Boot

If your system uses EFI Secure Boot, you may need to:

1. **Disable Secure Boot** (temporarily) in BIOS, or
2. **Sign the kernel modules** manually

### Alternative: Use VirtualBox from Debian Repositories

If the Oracle VirtualBox is giving issues, you can use the Debian version:

```bash
sudo apt install -y virtualbox virtualbox-dkms
```

This version is often easier to set up but may be slightly older.

### Check Module Status

```bash
# Check if modules are loaded
lsmod | grep vbox

# Check dkms status
sudo dkms status
```

## Quick Fix Command

Run this single command to install everything needed:

```bash
sudo apt update && sudo apt install -y linux-headers-amd64 linux-headers-$(uname -r) build-essential dkms && sudo /sbin/vboxconfig
```
