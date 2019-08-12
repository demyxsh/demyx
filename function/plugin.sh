# Demyx
# https://demyx.sh

demyx_plugin() {
    demyx_app_config
    cat > "$DEMYX_APP_CONFIG"/demyx_browsersync.php <<-EOF
    <?php
    /**
    * AUTO GENERATED
    * @package demyx_browsersync
    * @version 1.0
    */
    /*
    Plugin Name: Demyx BrowserSync
    Plugin URI: https://demyx.sh
    Description: A static homepage will redirect BrowserSync, this plugin disables that.
    Author: Demyx
    Version: 1.0
    Author URI: https://demyx.sh
    */

    demyx_browsersync_init( \$redirect ) {
        if (is_page() && \$front_page = get_option('page_on_front')) {
            if (is_page( \$front_page)) {
                \$redirect = false;
            }
        }
        return \$redirect;
    }

    add_filter('redirect_canonical', 'demyx_browsersync_init');
EOF
    sed -i 's/    //' "$DEMYX_APP_CONFIG"/demyx_browsersync.php
}
