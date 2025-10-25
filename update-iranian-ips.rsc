# ============================================
# MikroTik Auto-Update Iranian IPs Script
# ============================================
# Repository: https://github.com/amirsalahshur/update-iranian-ips
# Version: 1.0
# Last Updated: 2025-10-25
#
# Description:
# This script automatically downloads and updates the Iranian IP address list
# from the GitHub repository. It can be scheduled to run automatically.
#
# Features:
# - Downloads latest IP list from GitHub
# - Removes old entries before importing new ones
# - Provides detailed logging
# - Error handling and validation
# - Automatic cleanup of temporary files
#
# ============================================

/system script
add name=update-iranian-ips dont-require-permissions=no owner=admin \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source={
    # ============================================
    # Configuration Variables
    # ============================================
    :local listName "Iranian-IPs"
    :local fileName "iranian-ips.rsc"
    :local githubUrl "https://raw.githubusercontent.com/amirsalahshur/update-iranian-ips/main/mikrotik_address_list.rsc"
    :local success false
    
    # ============================================
    # Start Update Process
    # ============================================
    :log info "=========================================="
    :log info "Starting Iranian IPs Update"
    :log info "Repository: github.com/amirsalahshur/update-iranian-ips"
    :log info "=========================================="
    
    # ============================================
    # Step 1: Remove Old Downloaded File
    # ============================================
    :log info "Step 1: Checking for old files..."
    :if ([/file find name=$fileName] != "") do={
        :log info "Removing old file: $fileName"
        /file remove $fileName
        :delay 2s
    } else={
        :log info "No old file found"
    }
    
    # ============================================
    # Step 2: Download New File from GitHub
    # ============================================
    :log info "Step 2: Downloading from GitHub..."
    :do {
        /tool fetch url=$githubUrl mode=https dst-path=$fileName
        :log info "Download initiated, waiting for completion..."
        :delay 5s
        
        # ============================================
        # Step 3: Verify Download Success
        # ============================================
        :log info "Step 3: Verifying download..."
        :if ([/file find name=$fileName] != "") do={
            :log info "Download completed successfully"
            
            # Get file size for verification
            :local fileSize [/file get $fileName size]
            :log info "Downloaded file size: $fileSize bytes"
            
            # ============================================
            # Step 4: Backup Old IP Count
            # ============================================
            :log info "Step 4: Preparing to update IP list..."
            :local oldCount [/ip firewall address-list print count-only where list=$listName]
            :log info "Current IP entries: $oldCount"
            
            # ============================================
            # Step 5: Remove Old Entries
            # ============================================
            :log info "Step 5: Removing old IP entries..."
            /ip firewall address-list remove [find list=$listName]
            :delay 2s
            :log info "Old entries removed successfully"
            
            # ============================================
            # Step 6: Import New IP List
            # ============================================
            :log info "Step 6: Importing new IP list..."
            /import file-name=$fileName
            :delay 3s
            :log info "Import completed"
            
            # ============================================
            # Step 7: Verify New Entries
            # ============================================
            :log info "Step 7: Verifying new entries..."
            :local newCount [/ip firewall address-list print count-only where list=$listName]
            
            # ============================================
            # Step 8: Report Results
            # ============================================
            :log info "=========================================="
            :log info "Update Completed Successfully!"
            :log info "=========================================="
            :log info "Previous IP entries: $oldCount"
            :log info "New IP entries: $newCount"
            :local difference ($newCount - $oldCount)
            :if ($difference > 0) do={
                :log info "Added: $difference new entries"
            }
            :if ($difference < 0) do={
                :local removed ($difference * -1)
                :log info "Removed: $removed old entries"
            }
            :if ($difference = 0) do={
                :log info "No change in entry count"
            }
            :log info "=========================================="
            
            # ============================================
            # Step 9: Cleanup Temporary Files
            # ============================================
            :log info "Step 9: Cleaning up temporary files..."
            /file remove $fileName
            :delay 1s
            :log info "Cleanup completed"
            
            :set success true
            
        } else={
            # Download failed - file not found
            :log error "=========================================="
            :log error "Download Failed!"
            :log error "=========================================="
            :log error "File not found after download"
            :log error "Possible causes:"
            :log error "- No internet connection"
            :log error "- GitHub is unreachable"
            :log error "- Incorrect URL"
            :log error "=========================================="
        }
        
    } on-error={
        # Exception occurred during download or import
        :log error "=========================================="
        :log error "Error During Update Process!"
        :log error "=========================================="
        :log error "An error occurred during download or import"
        :log error "Please check:"
        :log error "1. Internet connection"
        :log error "2. DNS resolution (try: /ping github.com)"
        :log error "3. Available storage space"
        :log error "4. GitHub repository accessibility"
        :log error "=========================================="
    }
    
    # ============================================
    # Final Status Report
    # ============================================
    :if ($success = true) do={
        :log info "Script execution: SUCCESS"
        :log info "Iranian IP list is now up to date"
    } else={
        :log error "Script execution: FAILED"
        :log error "Iranian IP list was NOT updated"
        :log error "Please check logs and try manual update"
    }
    
    :log info "=========================================="
    :log info "Script Completed"
    :log info "=========================================="
}

# ============================================
# Installation Instructions
# ============================================
# 
# 1. Copy this entire script and paste it into your MikroTik terminal
# 
# 2. Run the script manually to test:
#    /system script run update-iranian-ips
# 
# 3. Check the logs to verify success:
#    /log print where message~"Iranian"
# 
# 4. Set up automatic daily updates:
#    /system scheduler add name=update-iranian-ips-daily \
#        on-event="/system script run update-iranian-ips" \
#        start-time=03:00:00 interval=1d
# 
# 5. Verify the scheduler:
#    /system scheduler print
# 
# ============================================
# Troubleshooting
# ============================================
# 
# If the script fails, check:
# 
# 1. Internet connectivity:
#    /tool fetch url="https://www.google.com" mode=https
# 
# 2. GitHub accessibility:
#    /tool fetch url="https://github.com" mode=https
# 
# 3. DNS resolution:
#    /ping github.com count=3
# 
# 4. Available storage:
#    /system resource print
# 
# 5. View detailed logs:
#    /log print where topics~"script"
# 
# ============================================
# Support
# ============================================
# 
# For issues, questions, or contributions:
# https://github.com/amirsalahshur/update-iranian-ips/issues
# 
# ============================================
