#!/bin/bash
# Setup script for OnePlus 12 Android 14 kernel build environment
# This script helps initialize the build environment using repo tool

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
MANIFEST_URL="https://github.com/OnePlusOSS/kernel_manifest.git"
MANIFEST_BRANCH="oneplus/sm8650"
MANIFEST_FILE="oneplus_12_u.xml"
WORKSPACE_DIR="${HOME}/oneplus12_kernel"

print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed"
        return 1
    else
        print_info "$1 is installed: $(command -v $1)"
        return 0
    fi
}

check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_deps=0
    
    # Check essential tools
    for cmd in git python3 make gcc; do
        if ! check_command "$cmd"; then
            missing_deps=1
        fi
    done
    
    # Check for repo
    if ! check_command "repo"; then
        print_warning "repo tool not found in PATH"
        print_info "You can install it using: curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo && chmod a+x ~/.bin/repo"
        missing_deps=1
    fi
    
    # Check Java
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -ge 11 ]; then
            print_info "Java $JAVA_VERSION is installed"
        else
            print_warning "Java 11 or later is required, found Java $JAVA_VERSION"
            missing_deps=1
        fi
    else
        print_error "Java is not installed"
        missing_deps=1
    fi
    
    if [ $missing_deps -eq 1 ]; then
        print_error "Some dependencies are missing. Please install them before continuing."
        echo ""
        echo "On Ubuntu/Debian, install dependencies with:"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install -y build-essential libncurses-dev bison flex \\"
        echo "    libssl-dev libelf-dev bc cpio python3 python3-pip git openjdk-11-jdk"
        return 1
    fi
    
    print_info "All dependencies are satisfied"
    return 0
}

check_disk_space() {
    print_header "Checking Disk Space"
    
    local required_space_gb=100
    local available_space=$(df -BG "$HOME" | tail -1 | awk '{print $4}' | sed 's/G//')
    
    print_info "Available disk space: ${available_space}GB"
    print_info "Required disk space: ${required_space_gb}GB"
    
    if [ "$available_space" -lt "$required_space_gb" ]; then
        print_warning "Low disk space. At least ${required_space_gb}GB is recommended"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

setup_workspace() {
    print_header "Setting Up Workspace"
    
    if [ -d "$WORKSPACE_DIR" ]; then
        print_warning "Workspace directory already exists: $WORKSPACE_DIR"
        read -p "Remove and recreate? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Removing existing workspace..."
            rm -rf "$WORKSPACE_DIR"
        else
            print_error "Cannot continue with existing workspace"
            exit 1
        fi
    fi
    
    print_info "Creating workspace directory: $WORKSPACE_DIR"
    mkdir -p "$WORKSPACE_DIR"
}

init_repo() {
    print_header "Initializing Repo"
    
    cd "$WORKSPACE_DIR"
    
    print_info "Initializing repo with OnePlus 12 Android 14 manifest..."
    print_info "Manifest URL: $MANIFEST_URL"
    print_info "Branch: $MANIFEST_BRANCH"
    print_info "Manifest file: $MANIFEST_FILE"
    
    repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH" -m "$MANIFEST_FILE"
    
    if [ $? -eq 0 ]; then
        print_info "Repo initialized successfully"
    else
        print_error "Failed to initialize repo"
        exit 1
    fi
}

sync_repos() {
    print_header "Syncing Repositories"
    
    cd "$WORKSPACE_DIR"
    
    local num_jobs=$(nproc --all)
    print_info "Syncing with $num_jobs parallel jobs..."
    print_warning "This may take 15-30 minutes depending on your connection"
    
    repo sync -c -j"$num_jobs" --no-clone-bundle --no-tags
    
    if [ $? -eq 0 ]; then
        print_info "Sync completed successfully"
    else
        print_error "Sync failed. You can retry with: cd $WORKSPACE_DIR && repo sync -c"
        exit 1
    fi
}

verify_structure() {
    print_header "Verifying Repository Structure"
    
    cd "$WORKSPACE_DIR"
    
    local required_dirs=(
        "kernel_platform/common"
        "kernel_platform/msm-kernel"
        "kernel_platform/oplus"
        "kernel_platform/build"
        "vendor/oplus"
        "vendor/qcom"
    )
    
    local missing=0
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_info "Found: $dir"
        else
            print_error "Missing: $dir"
            missing=1
        fi
    done
    
    if [ $missing -eq 1 ]; then
        print_error "Repository structure verification failed"
        exit 1
    fi
    
    print_info "Repository structure verified"
}

print_build_instructions() {
    print_header "Setup Complete!"
    
    echo ""
    echo "Your build environment is ready at: $WORKSPACE_DIR"
    echo ""
    echo "To build the kernel, run:"
    echo "  cd $WORKSPACE_DIR"
    echo "  ./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki"
    echo ""
    echo "Build variants:"
    echo "  gki          - Generic Kernel Image (user/production build)"
    echo "  consolidate  - Consolidated build (userdebug with more modules)"
    echo ""
    echo "Other build targets:"
    echo "  oplus_build_ko.sh        - Build kernel modules only"
    echo "  oplus_build_boot.sh      - Build boot image"
    echo "  oplus_build_dtbo.sh      - Build device tree overlay"
    echo ""
    echo "Output will be in: kernel_platform/out/msm-kernel-pineapple-gki/dist/"
    echo ""
    echo "For more information, see: $WORKSPACE_DIR/README.md"
    echo ""
}

# Main execution
main() {
    print_header "OnePlus 12 Android 14 Kernel Build Setup"
    echo ""
    echo "This script will set up the build environment for:"
    echo "  Device: OnePlus 12"
    echo "  Platform: SM8650 (pineapple)"
    echo "  OS: Android 14 OxygenOS"
    echo "  Build Type: User (u)"
    echo ""
    
    # Check if running in the repo directory
    if [ -d ".repo" ]; then
        print_error "This script should not be run from within an existing repo checkout"
        print_info "Please run it from your home directory or another location"
        exit 1
    fi
    
    # Run checks and setup
    check_dependencies || exit 1
    check_disk_space
    
    # Ask for confirmation
    echo ""
    read -p "Continue with setup? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Setup cancelled"
        exit 0
    fi
    
    setup_workspace
    init_repo
    sync_repos
    verify_structure
    print_build_instructions
}

# Run main function
main "$@"
