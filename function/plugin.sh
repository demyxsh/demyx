# Demyx
# https://demyx.sh

demyx_plugin() {
    demyx_app_config
    cat > "$DEMYX_APP_PATH"/demyx.php <<-EOF
    <?php
    /**
    * AUTO GENERATED
    * @package demyx_helper
    * @version 1.0
    */
    /*
    Plugin Name: Demyx Helper
    Plugin URI: https://github.com/demyxco/demyx/blob/master/function/plugin.sh/
    Description: A collection of helper functions.
    Author: Demyx
    Version: 1.0
    Author URI: https://demyx.sh/
    */

    # Prevent a static homepage redirect when using BrowserSync
    add_filter('redirect_canonical', 'demyx_browsersync');
    # Borrowed code from autover
    add_filter('style_loader_src', 'demyx_version_filter');
    add_filter('script_loader_src', 'demyx_version_filter');

    function demyx_browsersync( \$redirect ) {
        if (is_page() && \$front_page = get_option('page_on_front')) {
            if (is_page( \$front_page)) {
                \$redirect = false;
            }
        }
        return \$redirect;
    }

    function demyx_version_filter( \$src ) {
            \$url_parts = wp_parse_url( \$src );

            \$extension = pathinfo( \$url_parts['path'], PATHINFO_EXTENSION );
            if ( ! \$extension || ! in_array( \$extension, [ 'css', 'js' ] ) ) {
                    return \$src;
            }

            if ( defined( 'DEMYX_DISABLE_' . strtoupper( \$extension ) ) ) {
                    return \$src;
            }

            \$file_path = rtrim( ABSPATH, '/' ) . urldecode( \$url_parts['path'] );
            if ( ! is_file( \$file_path ) ) {
                    return \$src;
            }

            \$timestamp_version = filemtime( \$file_path ) ?: filemtime( utf8_decode( \$file_path ) );
            if ( ! \$timestamp_version ) {
                    return \$src;
            }

            if ( ! isset( \$url_parts['query'] ) ) {
                    \$url_parts['query'] = '';
            }

            \$query = [];
            parse_str( \$url_parts['query'], \$query );
            unset( \$query['v'] );
            unset( \$query['ver'] );
            \$query['ver']       = "\$timestamp_version";
            \$url_parts['query'] = build_query( \$query );

            return demyx_build_url( \$url_parts );
    }


    function demyx_build_url( array \$parts ) {
            return ( isset( \$parts['scheme'] ) ? "{\$parts['scheme']}:" : '' ) .
                    ( ( isset( \$parts['user'] ) || isset( \$parts['host'] ) ) ? '//' : '' ) .
                    ( isset( \$parts['user'] ) ? "{\$parts['user']}" : '' ) .
                    ( isset( \$parts['pass'] ) ? ":{\$parts['pass']}" : '' ) .
                    ( isset( \$parts['user'] ) ? '@' : '' ) .
                    ( isset( \$parts['host'] ) ? "{\$parts['host']}" : '' ) .
                    ( isset( \$parts['port'] ) ? ":{\$parts['port']}" : '' ) .
                    ( isset( \$parts['path'] ) ? "{\$parts['path']}" : '' ) .
                    ( isset( \$parts['query'] ) ? "?{\$parts['query']}" : '' ) .
                    ( isset( \$parts['fragment'] ) ? "#{\$parts['fragment']}" : '' );
    }
EOF
    sed -i 's/    //' "$DEMYX_APP_PATH"/demyx.php
}
