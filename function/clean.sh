# Demyx
# https://demyx.sh

# Update demyx user motd in .zshrc
sed -i "s|bash /demyx/.motd|sudo demyx motd|g" /home/demyx/.zshrc

# Remove old motd message
[[ -f /demyx/.motd ]] && rm -f /demyx/.motd
