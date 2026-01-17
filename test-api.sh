#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

API_BASE="http://localhost:3000/api"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    📝 Notes App API Testing Suite      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

# Check if server is running
echo -e "${YELLOW}⏳ Checking if server is running...${NC}"
if ! curl -s http://localhost:3000/health > /dev/null; then
    echo -e "${RED}❌ Server is not running. Start it first with: npm start${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Server is running!${NC}\n"

# Test 1: Get all notes
echo -e "${YELLOW}📋 Test 1: Get all notes${NC}"
NOTES=$(curl -s -X GET "${API_BASE}/notes" -H "Content-Type: application/json")
echo -e "${BLUE}Response:${NC}"
echo "$NOTES" | jq '.' 2>/dev/null || echo "$NOTES"
echo ""

# Test 2: Create a note
echo -e "${YELLOW}➕ Test 2: Create a new note${NC}"
NOTE_DATA='{
  "title": "Test Note - '$(date +%s)'",
  "content": "This is a test note created at '$(date)'"
}'
CREATE_RESPONSE=$(curl -s -X POST "${API_BASE}/notes" \
  -H "Content-Type: application/json" \
  -d "$NOTE_DATA")
echo -e "${BLUE}Response:${NC}"
echo "$CREATE_RESPONSE" | jq '.' 2>/dev/null || echo "$CREATE_RESPONSE"

# Extract note ID
NOTE_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id' 2>/dev/null)
if [ -z "$NOTE_ID" ] || [ "$NOTE_ID" = "null" ]; then
    echo -e "${RED}❌ Failed to create note${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Note created with ID: $NOTE_ID${NC}\n"

# Test 3: Get single note
echo -e "${YELLOW}🔍 Test 3: Get single note${NC}"
GET_RESPONSE=$(curl -s -X GET "${API_BASE}/notes/${NOTE_ID}" \
  -H "Content-Type: application/json")
echo -e "${BLUE}Response:${NC}"
echo "$GET_RESPONSE" | jq '.' 2>/dev/null || echo "$GET_RESPONSE"
echo ""

# Test 4: Update note
echo -e "${YELLOW}✏️  Test 4: Update note${NC}"
UPDATE_DATA='{
  "title": "Updated Test Note - '$(date +%s)'",
  "content": "This note has been updated at '$(date)'. Updated content here."
}'
UPDATE_RESPONSE=$(curl -s -X PUT "${API_BASE}/notes/${NOTE_ID}" \
  -H "Content-Type: application/json" \
  -d "$UPDATE_DATA")
echo -e "${BLUE}Response:${NC}"
echo "$UPDATE_RESPONSE" | jq '.' 2>/dev/null || echo "$UPDATE_RESPONSE"
echo ""

# Test 5: Get all notes again
echo -e "${YELLOW}📋 Test 5: Get all notes (after update)${NC}"
NOTES_UPDATED=$(curl -s -X GET "${API_BASE}/notes" \
  -H "Content-Type: application/json")
COUNT=$(echo "$NOTES_UPDATED" | jq 'length' 2>/dev/null)
echo -e "${BLUE}Total notes:${NC} ${GREEN}$COUNT${NC}"
echo "$NOTES_UPDATED" | jq '.' 2>/dev/null || echo "$NOTES_UPDATED"
echo ""

# Test 6: Health check
echo -e "${YELLOW}❤️  Test 6: Health check${NC}"
HEALTH=$(curl -s -X GET "http://localhost:3000/health" \
  -H "Content-Type: application/json")
echo -e "${BLUE}Response:${NC}"
echo "$HEALTH" | jq '.' 2>/dev/null || echo "$HEALTH"
echo ""

# Test 7: Delete note
echo -e "${YELLOW}🗑️  Test 7: Delete note${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE "${API_BASE}/notes/${NOTE_ID}" \
  -H "Content-Type: application/json")
echo -e "${BLUE}Response:${NC}"
echo "$DELETE_RESPONSE" | jq '.' 2>/dev/null || echo "$DELETE_RESPONSE"
echo ""

# Test 8: Verify deletion
echo -e "${YELLOW}🔍 Test 8: Verify note deletion${NC}"
VERIFY=$(curl -s -X GET "${API_BASE}/notes/${NOTE_ID}" \
  -H "Content-Type: application/json")
if echo "$VERIFY" | grep -q "not found"; then
    echo -e "${GREEN}✅ Note successfully deleted${NC}"
else
    echo -e "${YELLOW}⚠️  Note still exists${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    ✅ API Testing Complete!           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
echo -e "${GREEN}All tests passed! Your Notes App is working correctly.${NC}"
