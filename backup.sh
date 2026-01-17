#!/bin/bash

# 📅 Notes App Database Backup & Maintenance Script
# Setup: Add to crontab with: crontab -e
# Daily backup: 0 2 * * * /path/to/backup.sh
# Weekly cleanup: 0 3 * * 0 /path/to/backup.sh cleanup

set -e

# Configuration
BACKUP_DIR="./backups"
DB_HOST="${DB_HOST:-localhost}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"
DB_NAME="${DB_NAME:-notesdb}"
BACKUP_RETENTION_DAYS=30
LOG_FILE="./backups/backup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Logging function
log() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${TIMESTAMP}] $1" | tee -a "$LOG_FILE"
}

# Function: Backup Database
backup_database() {
    log "=========================================="
    log "🔄 Starting database backup..."
    
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    BACKUP_FILE="${BACKUP_DIR}/notesdb_backup_${TIMESTAMP}.sql"
    
    if [ -z "$DB_PASS" ]; then
        # No password
        mysqldump -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" > "$BACKUP_FILE" 2>&1
    else
        # With password
        mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        log "✅ Backup successful: $BACKUP_FILE (Size: $FILE_SIZE)"
        
        # Compress backup
        gzip "$BACKUP_FILE"
        log "📦 Compressed to: ${BACKUP_FILE}.gz"
        
        # List backup
        ls -lh "${BACKUP_FILE}.gz" >> "$LOG_FILE"
    else
        log "❌ Backup failed!"
        exit 1
    fi
    
    log "=========================================="
}

# Function: Cleanup old backups
cleanup_old_backups() {
    log "=========================================="
    log "🧹 Cleaning up old backups (older than ${BACKUP_RETENTION_DAYS} days)..."
    
    find "$BACKUP_DIR" -type f -name "notesdb_backup_*.sql.gz" -mtime +${BACKUP_RETENTION_DAYS} | while read file; do
        log "🗑️  Deleting: $file"
        rm "$file"
    done
    
    log "✅ Cleanup completed"
    log "=========================================="
}

# Function: Get backup statistics
backup_stats() {
    log "=========================================="
    log "📊 Backup Statistics"
    log "=========================================="
    
    if [ -d "$BACKUP_DIR" ]; then
        TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
        FILE_COUNT=$(find "$BACKUP_DIR" -type f -name "*.sql.gz" | wc -l)
        LATEST=$(ls -t "$BACKUP_DIR"/notesdb_backup_*.sql.gz 2>/dev/null | head -1)
        
        log "📁 Backup Directory: $BACKUP_DIR"
        log "📊 Total Backups: $FILE_COUNT"
        log "💾 Total Size: $TOTAL_SIZE"
        
        if [ ! -z "$LATEST" ]; then
            LATEST_SIZE=$(du -h "$LATEST" | cut -f1)
            LATEST_DATE=$(stat -c %y "$LATEST" 2>/dev/null || stat -f %Sm "$LATEST")
            log "📅 Latest Backup: $(basename $LATEST)"
            log "   Size: $LATEST_SIZE"
            log "   Date: $LATEST_DATE"
        fi
    fi
    
    log "=========================================="
}

# Function: Verify backup integrity
verify_backup() {
    log "=========================================="
    log "✔️  Verifying latest backup..."
    
    LATEST=$(ls -t "$BACKUP_DIR"/notesdb_backup_*.sql.gz 2>/dev/null | head -1)
    
    if [ -f "$LATEST" ]; then
        # Check if file is valid gzip
        if gzip -t "$LATEST" 2>/dev/null; then
            log "✅ Backup file is valid"
            
            # Try to count tables in backup
            TABLE_COUNT=$(gunzip -c "$LATEST" | grep -c "CREATE TABLE" || echo "0")
            log "📋 Tables in backup: $TABLE_COUNT"
        else
            log "❌ Backup file is corrupted!"
        fi
    else
        log "⚠️  No backup found"
    fi
    
    log "=========================================="
}

# Function: List all backups
list_backups() {
    log "=========================================="
    log "📋 Available Backups:"
    log "=========================================="
    
    if [ -d "$BACKUP_DIR" ]; then
        ls -lhS "$BACKUP_DIR"/notesdb_backup_*.sql.gz 2>/dev/null | awk '{print $9, "(" $5 ")"}' | while read file; do
            log "📦 $file"
        done
    else
        log "❌ Backup directory not found"
    fi
    
    log "=========================================="
}

# Function: Restore from backup
restore_backup() {
    BACKUP_FILE="$1"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        log "❌ Backup file not found: $BACKUP_FILE"
        return 1
    fi
    
    log "=========================================="
    log "⚠️  RESTORE WARNING!"
    log "=========================================="
    log "This will overwrite existing data in: $DB_NAME"
    log "Backup file: $BACKUP_FILE"
    
    # Ask for confirmation (in non-interactive mode, this should be forced)
    if [ "$2" != "force" ]; then
        read -p "Continue? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log "❌ Restore cancelled"
            return 1
        fi
    fi
    
    log "🔄 Starting restore..."
    
    # Decompress and restore
    if [[ "$BACKUP_FILE" == *.gz ]]; then
        if [ -z "$DB_PASS" ]; then
            gunzip -c "$BACKUP_FILE" | mysql -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" 2>&1
        else
            gunzip -c "$BACKUP_FILE" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" 2>&1
        fi
    else
        if [ -z "$DB_PASS" ]; then
            mysql -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" < "$BACKUP_FILE" 2>&1
        else
            mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$BACKUP_FILE" 2>&1
        fi
    fi
    
    if [ $? -eq 0 ]; then
        log "✅ Restore successful!"
    else
        log "❌ Restore failed!"
        return 1
    fi
    
    log "=========================================="
}

# Main script logic
case "${1:-backup}" in
    backup)
        backup_database
        backup_stats
        ;;
    cleanup)
        cleanup_old_backups
        backup_stats
        ;;
    stats)
        backup_stats
        ;;
    verify)
        verify_backup
        ;;
    list)
        list_backups
        ;;
    restore)
        if [ -z "$2" ]; then
            log "❌ Usage: $0 restore <backup_file> [force]"
            exit 1
        fi
        restore_backup "$2" "$3"
        ;;
    full)
        backup_database
        verify_backup
        cleanup_old_backups
        backup_stats
        ;;
    *)
        echo "📅 Notes App Database Backup & Maintenance Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  backup      - Create database backup (default)"
        echo "  cleanup     - Remove old backups (older than ${BACKUP_RETENTION_DAYS} days)"
        echo "  stats       - Show backup statistics"
        echo "  verify      - Verify latest backup integrity"
        echo "  list        - List all available backups"
        echo "  restore     - Restore from backup: $0 restore <backup_file>"
        echo "  full        - Run backup, verify, cleanup, and stats"
        echo ""
        echo "📋 Crontab Examples:"
        echo ""
        echo "  # Daily backup at 2 AM"
        echo "  0 2 * * * /path/to/backup.sh backup"
        echo ""
        echo "  # Weekly cleanup on Sunday at 3 AM"
        echo "  0 3 * * 0 /path/to/backup.sh cleanup"
        echo ""
        echo "  # Daily full backup at 1 AM"
        echo "  0 1 * * * /path/to/backup.sh full"
        echo ""
        echo "📁 Backup Directory: $BACKUP_DIR"
        echo "📊 Retention Days: ${BACKUP_RETENTION_DAYS}"
        echo ""
        ;;
esac

exit 0
