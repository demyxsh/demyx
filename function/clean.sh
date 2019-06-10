# Demyx
# https://demyx.sh

# Update demyx user motd in .zshrc
DEMYX_REPLACE_MOTD_1="$(grep -s "bash /demyx/.motd" /home/demyx/.zshrc || true)"
if [[ -n "$DEMYX_REPLACE_MOTD_1" ]]; then
    sed -i "s|bash /demyx/.motd|sudo demyx motd|g" /home/demyx/.zshrc
fi

# Remove old motd message
[[ -f /demyx/.motd ]] && rm -f /demyx/.motd

# Update demyx user motd in .zshrc (again)
DEMYX_REPLACE_MOTD_2="$(grep -s "sudo demyx motd" /home/demyx/.zshrc || true)"
if [[ -n "$DEMYX_REPLACE_MOTD_2" ]]; then
    sed -i "s|sudo demyx motd|demyx motd|g" /home/demyx/.zshrc
fi
