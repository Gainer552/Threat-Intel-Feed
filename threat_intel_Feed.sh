#!/bin/bash

# ========= CONFIG ===========
FEEDS=(
    "The Hacker News|https://feeds.feedburner.com/TheHackersNews"
    "Security Magazine|https://www.securitymagazine.com/rss/15"
    "Infosecurity Magazine|https://www.infosecurity-magazine.com/rss/news/"
)

# ========= COLORS ===========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ========= FUNCTIONS ==========

fetch_and_display_feed() {
    local name="$1"
    local url="$2"

    echo -e "\n${YELLOW}== $name ==${NC}"

    # Fetch feed
    content=$(curl -s --max-time 10 "$url")
    if [[ -z "$content" ]]; then
        echo -e "${RED}Failed to retrieve feed from $name${NC}"
        return
    fi

    # Parse and display top 5 items
    echo "$content" | \
        grep -E '<title>|<link>' | \
        sed -e 's/<[^>]*>//g' | \
        awk 'BEGIN{RS="</item>";ORS="\n\n"} {print}' | \
        head -n 10 | \
        awk 'NR % 2 == 1 {printf "• %s\n", $0} NR % 2 == 0 {printf "  %s\n", $0}'
}

# ========= MAIN ===========
echo -e "${CYAN}Fetching latest threat intel headlines...\n${NC}"

for feed in "${FEEDS[@]}"; do
    name="${feed%%|*}"
    url="${feed##*|}"
    fetch_and_display_feed "$name" "$url"
done

echo -e "\n${GREEN}Done.${NC}"
