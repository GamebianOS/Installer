# Fixing VirtualBox KVM Conflict

## Problem

VirtualBox can't start because KVM (Kernel-based Virtual Machine) is already using the hardware virtualization features (VT-x/AMD-V).

## Solution 1: Disable KVM Temporarily (Quick Fix)

Unload KVM modules so VirtualBox can use hardware acceleration:

```bash
# Check if KVM is loaded
lsmod | grep kvm

# Unload KVM modules
sudo modprobe -r kvm_intel  # For Intel CPUs
# OR
sudo modprobe -r kvm_amd    # For AMD CPUs

# Also unload the main kvm module
sudo modprobe -r kvm

# Now try starting your VM in VirtualBox
```

**Note**: KVM will reload on next boot. This is a temporary fix.

## Solution 2: Use VirtualBox Without Hardware Acceleration

Configure your VM to not use hardware acceleration:

1. **In VirtualBox GUI:**
   - Select your VM → Settings → System → Acceleration
   - Uncheck "Enable VT-x/AMD-V"
   - Uncheck "Enable Nested Paging"
   - Click OK

2. **Or via command line:**
   ```bash
   VBoxManage modifyvm "Gamebian" --nested-hw-virt off
   VBoxManage modifyvm "Gamebian" --hwvirtex off
   ```

**Note**: This will make the VM slower but it will work.

## Solution 3: Disable KVM at Boot (Permanent)

If you want to use VirtualBox exclusively:

1. **Blacklist KVM modules:**
   ```bash
   echo "blacklist kvm" | sudo tee -a /etc/modprobe.d/blacklist.conf
   echo "blacklist kvm_intel" | sudo tee -a /etc/modprobe.d/blacklist.conf
   # OR for AMD:
   # echo "blacklist kvm_amd" | sudo tee -a /etc/modprobe.d/blacklist.conf
   ```

2. **Reboot:**
   ```bash
   sudo reboot
   ```

3. **Verify KVM is not loaded:**
   ```bash
   lsmod | grep kvm
   # Should return nothing
   ```

## Solution 4: Use KVM Instead of VirtualBox (Recommended for Linux)

Since you're on Linux, consider using KVM/QEMU directly instead of VirtualBox:

```bash
# Install QEMU/KVM
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# Add your user to libvirt group
sudo usermod -aG libvirt $USER

# Log out and back in, then use virt-manager GUI
```

**Advantages:**
- Better performance on Linux
- Native integration
- No conflicts with KVM
- Free and open source

## Solution 5: Check What's Using KVM

Find out what's using KVM:

```bash
# Check if any VMs are running
sudo virsh list --all

# Check QEMU processes
ps aux | grep qemu

# Check libvirt
sudo systemctl status libvirtd
```

## Quick Commands Reference

```bash
# Check KVM status
lsmod | grep kvm

# Unload KVM (Intel)
sudo modprobe -r kvm_intel kvm

# Unload KVM (AMD)
sudo modprobe -r kvm_amd kvm

# Disable KVM permanently (add to blacklist)
echo "blacklist kvm" | sudo tee -a /etc/modprobe.d/blacklist.conf
echo "blacklist kvm_intel" | sudo tee -a /etc/modprobe.d/blacklist.conf

# Re-enable KVM later (remove from blacklist)
sudo sed -i '/blacklist kvm/d' /etc/modprobe.d/blacklist.conf
```

## Recommended Approach

For testing GamebianOS ISO, I recommend:

1. **Quick test**: Use Solution 1 (unload KVM temporarily)
2. **Better performance**: Use Solution 4 (switch to KVM/QEMU)
3. **If you need VirtualBox**: Use Solution 3 (disable KVM permanently)

## Testing Your ISO with QEMU/KVM

If you switch to KVM, you can test your ISO with:

```bash
# Using the test script from build
~/test-gamebianos.sh

# Or manually
qemu-system-x86_64 \
    -cdrom ~/GamebianOS-1.0-amd64.iso \
    -drive file=~/gamebian-test.qcow2,format=qcow2 \
    -m 4096 \
    -cpu host \
    -smp 4 \
    -enable-kvm \
    -vga virtio \
    -display sdl,gl=on \
    -net nic,model=virtio \
    -net user
```

This will give you better performance than VirtualBox on Linux!
