# Build Output Files Explained

This document explains all the files and directories created by `live-build` during the ISO build process.

## Directory Structure

### `auto/`
**Purpose**: Automatically generated configuration files  
**Contents**: Live-build creates this directory to store auto-generated configuration based on your `lb config` command.  
**Can delete**: Yes, but it will be regenerated on next build  
**Size**: Small (~4KB)

### `binary/`
**Purpose**: Final binary output directory  
**Contents**: Contains the final ISO image and related files:
- `live-image-amd64.hybrid.iso` - The bootable ISO file (moved to output directory after build)
- Other binary artifacts needed for ISO creation

**Can delete**: Yes, after ISO is moved  
**Size**: Large (contains ISO file)

### `cache/`
**Purpose**: Package download cache  
**Contents**: Cached `.deb` packages downloaded during build. This speeds up subsequent builds by reusing downloaded packages.  
**Can delete**: Yes, but you'll re-download packages on next build  
**Size**: Can be large (several GB) - contains all downloaded packages

**Tip**: Keep this directory to speed up rebuilds!

### `chroot/`
**Purpose**: Chroot environment for building  
**Contents**: The complete filesystem of the live system being built. This is where all packages are installed and configured before being packaged into the ISO.  
**Can delete**: Yes, but needed during build  
**Size**: Large (several GB) - contains full system filesystem

**Structure**:
- `chroot/bin/` - System binaries
- `chroot/etc/` - Configuration files
- `chroot/usr/` - User programs and data
- `chroot/var/` - Variable data
- etc. (full Linux filesystem)

### `local/`
**Purpose**: Local build artifacts  
**Contents**: Temporary files and build artifacts specific to this build  
**Can delete**: Yes  
**Size**: Small to medium

## File Descriptions

### `binary.modified_timestamps`
**Purpose**: Tracks modification timestamps of binary files  
**Type**: Metadata file  
**Contents**: Timestamps for files in the binary directory  
**Can delete**: Yes  
**Size**: Small (~878 bytes)

### `build.log`
**Purpose**: Complete build log  
**Type**: Text file  
**Contents**: Detailed log of the entire build process, including:
- Package downloads
- Installation steps
- Configuration steps
- Errors and warnings
- Build timestamps

**Can delete**: Yes, but useful for debugging  
**Size**: Medium (320KB in your case)

**Usage**: Check this file if build fails to see what went wrong

### `chroot.files`
**Purpose**: List of all files in the chroot  
**Type**: Text file  
**Contents**: Complete list of every file that will be included in the ISO, with paths and metadata  
**Can delete**: Yes  
**Size**: Large (2.2MB) - contains thousands of file entries

**Format**: One file path per line

### `chroot.packages.install`
**Purpose**: List of packages installed in the system  
**Type**: Text file  
**Contents**: Complete list of all packages (and versions) that were installed during the build  
**Can delete**: Yes  
**Size**: Medium (17KB)

**Format**: Package name and version per line

**Example**:
```
calamares 3.3.0-1
lxqt-core 2.0.0-1
...
```

### `chroot.packages.live`
**Purpose**: List of packages in the live system  
**Type**: Text file  
**Contents**: Similar to `chroot.packages.install` but specifically for live system packages  
**Can delete**: Yes  
**Size**: Medium (17KB)

### `live-image-amd64.contents`
**Purpose**: Contents listing of the final ISO  
**Type**: Text file  
**Contents**: Detailed listing of what's inside the ISO file  
**Can delete**: Yes  
**Size**: Medium (9.6KB)

**Usage**: Useful for verifying what's included in the ISO

### `live-image-amd64.files`
**Purpose**: File listing of the ISO  
**Type**: Text file  
**Contents**: Complete list of all files in the ISO with their paths, sizes, and checksums  
**Can delete**: Yes  
**Size**: Large (2.2MB)

**Usage**: 
- Verify ISO contents
- Check file sizes
- Debug missing files

### `live-image-amd64.hybrid.iso`
**Purpose**: **THE FINAL ISO FILE**  
**Type**: Binary ISO image  
**Contents**: Complete bootable ISO image ready to:
- Burn to DVD
- Write to USB drive
- Use in VirtualBox/VMware
- Boot on real hardware

**Can delete**: **NO!** This is what you need!  
**Size**: Large (588MB in your case, typically 1-4GB)

**Note**: This file is moved to your output directory (default: `~/`) and renamed to `GamebianOS-1.0-amd64.iso` by the build script.

### `live-image-amd64.packages`
**Purpose**: Package manifest for the ISO  
**Type**: Text file  
**Contents**: List of all packages included in the final ISO  
**Can delete**: Yes  
**Size**: Medium (17KB)

**Usage**: 
- Verify package versions
- Check what's included
- Debug package issues

## File Size Summary

| File/Directory | Typical Size | Purpose |
|----------------|--------------|---------|
| `auto/` | ~4KB | Auto-generated config |
| `binary/` | Large (ISO size) | Final output |
| `cache/` | 2-10GB | Package cache |
| `chroot/` | 3-8GB | Build environment |
| `local/` | Small-Medium | Build artifacts |
| `*.iso` | 1-4GB | **The ISO file** |
| `*.log` | 100KB-1MB | Build logs |
| `*.files` | 1-5MB | File listings |
| `*.packages` | 10-50KB | Package lists |

## What to Keep vs Delete

### Keep These:
- ✅ `live-image-amd64.hybrid.iso` (or the renamed version in output directory)
- ✅ `cache/` - Speeds up future builds
- ✅ `build.log` - Useful for debugging

### Safe to Delete:
- 🗑️ `auto/` - Regenerated on next build
- 🗑️ `binary/` - After ISO is moved
- 🗑️ `chroot/` - Regenerated on next build
- 🗑️ `local/` - Temporary files
- 🗑️ `*.files` - Metadata files
- 🗑️ `*.packages` - Package lists (unless you need them)
- 🗑️ `*.contents` - Contents listing

### Clean Build Command

To clean everything except cache and final ISO:

```bash
cd /home/khinds/Dropbox/Current-Projects/GamebianOS/Installer
sudo lb clean
```

This removes:
- `auto/`
- `binary/` (after ISO moved)
- `chroot/`
- `local/`
- All metadata files

But keeps:
- `cache/` (package cache)
- Your final ISO (in output directory)

### Full Clean (Remove Everything)

```bash
sudo lb clean --purge
```

This removes **everything** including cache. Use this if you want a completely fresh build.

## Understanding the Build Process

1. **Configuration** (`auto/` created)
   - Live-build reads your config
   - Generates build configuration

2. **Bootstrap** (`chroot/` created)
   - Downloads base Debian system
   - Creates chroot environment

3. **Package Installation** (`chroot/` populated)
   - Installs all packages
   - Configures system
   - Creates file listings (`*.files`, `*.packages`)

4. **ISO Creation** (`binary/` created)
   - Packages chroot into ISO
   - Creates bootable image
   - Generates metadata files

5. **Final Output**
   - ISO moved to output directory
   - Checksums created
   - Test script generated

## Disk Space Requirements

**During Build:**
- Minimum: 10-15GB free space
- Recommended: 20GB+ free space

**After Build:**
- ISO file: 1-4GB
- Cache (optional): 2-10GB
- Total needed: 3-14GB

**To Free Space:**
```bash
# Remove everything except ISO and cache
sudo lb clean

# Or remove everything including cache
sudo lb clean --purge
```

## Troubleshooting

### Build Fails - Check These Files:
1. `build.log` - Full build output
2. `chroot.packages.install` - See what packages were installed
3. `live-image-amd64.files` - Verify files are included

### ISO Too Large:
- Check `live-image-amd64.packages` for unnecessary packages
- Review `live-image-amd64.files` for large files
- Remove packages from `config/package-lists/`

### Build Takes Too Long:
- Keep `cache/` directory to reuse downloaded packages
- Use `--cache true` in lb config (if not already enabled)

## Summary

The most important file is **`live-image-amd64.hybrid.iso`** - this is your bootable ISO. Everything else is either:
- Build artifacts (can be regenerated)
- Metadata files (useful but not essential)
- Cache (speeds up rebuilds)

After a successful build, you only need the ISO file. Everything else can be cleaned up to save disk space.
