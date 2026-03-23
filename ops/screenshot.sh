#!/bin/bash
# Screenshot tool for the team
# Usage: ./screenshot.sh <url> [output_filename] [width] [height]
# Example: ./screenshot.sh https://drift.nowherelabs.dev drift-landing.png 1280 720

URL="${1:?Usage: ./screenshot.sh <url> [filename] [width] [height]}"
FILENAME="${2:-screenshot.png}"
WIDTH="${3:-1280}"
HEIGHT="${4:-720}"
OUTPUT="/tmp/$FILENAME"

node -e "
import { chromium } from 'playwright';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: $WIDTH, height: $HEIGHT } });
await page.goto('$URL', { waitUntil: 'networkidle', timeout: 15000 });
await page.waitForTimeout(2000);
await page.screenshot({ path: '$OUTPUT', fullPage: false });
await browser.close();
console.log('saved: $OUTPUT');
" 2>&1

