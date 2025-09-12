
--
-- WordPress Administration Bootstrap
--
-- @package WordPress
-- @subpackage Administration
--

package body Hb_Admin
is

   HB_ADMIN          : Boolean;
   HB_NETWORK_ADMIN  : Boolean;
   HB_USER_ADMIN     : Boolean;
   HB_BLOG_ADMIN     : Boolean;
   HB_LOAD_IMPORTERS : Boolean;

   procedure Run is
   begin
--
-- In WordPress Administration Screens
--
-- @since 2.3.2
--
--if ( ! defined( 'WP_ADMIN' ) ) then
--        define( 'WP_ADMIN', true );
--end;

--if ( ! defined( 'WP_NETWORK_ADMIN' ) ) then
--        define( 'WP_NETWORK_ADMIN', false );
--end;

--if ( ! defined( 'WP_USER_ADMIN' ) ) then
--        define( 'WP_USER_ADMIN', false );
--end;

if not WP_NETWORK_ADMIN and then not WP_USER_ADMIN then
        WP_BLOG_ADMIN := True;
end if;

if Isset (X_GET ("import")) and then not WP_LOAD_IMPORTERS then
        WP_LOAD_IMPORTERS := True;
end if;

-- require_once dirname( __DIR__ ) . "/wp-load.php";

Nocache_Headers; -- ();

if Get_Option ("db_upgraded") then

        Flush_Rewrite_Rules; -- ();
        Update_Option ("db_upgraded", false);

        --
        -- Fires on the next page load after a successful DB upgrade.
        --
        -- @since 2.8.0
        --
        Do_Action ("after_db_upgrade");

elsif not Hb_Doing_Ajax and then Empty (X_POST)
        and then (int) Get_Option ("db_version") /= Wp_Db_Version
then

        if not Is_Multisite then
                Hb_Redirect (Admin_Url ("upgrade.php?_wp_http_referer=" & Urlencode (Wp_Unslash (X_SERVER ("REQUEST_URI")))));
                return; -- exit;
        end if;

        --
        -- Filters whether to attempt to perform the multisite DB upgrade routine.
        --
        -- In single site, the user would be redirected to wp-admin/upgrade.php.
        -- In multisite, the DB upgrade routine is automatically fired, but only
        -- when this filter returns true.
        --
        -- If the network is 50 sites or less, it will run every time. Otherwise,
        -- it will throttle itself to reduce load.
        --
        -- @since MU (3.0.0)
        --
        -- @param bool $do_mu_upgrade Whether to perform the Multisite upgrade routine. Default true.
        --
        if Apply_Filters ("do_mu_upgrade", True) then
                C := Get_Blog_Count;

                --
                -- If there are 50 or fewer sites, run every time. Otherwise, throttle to reduce load:
                -- attempt to do no more than threshold value, with some +/- allowed.
                --
                if c <= 50 or else (C > 50 and then Mt_Rand (0, (int) ( c / 50 ) ) = 1 ) then
--                        require_once ABSPATH . WPINC . "/http.php";
                        response := Hb_Remote_Get (
                                Admin_Url ("upgrade.php?step=1"),
                                To_Array ((
                                        Build ("timeout",     120),
                                        Build ("httpversion", "1.1")
                                ))
                        );
                        -- This action is documented in wp-admin/network/upgrade.php
                        Do_Action ("after_mu_upgrade", Response);
                        Unset (Response);
                end if;
                Unset (C);
        end if;
end if;

-- require_once ABSPATH . "wp-admin/includes/admin.php";

Auth_Redirect; -- ();

-- Schedule Trash collection.
if not Hb_Next_Scheduled ("wp_scheduled_delete") and then not Hb_Installin then
--        hb_Schedule_Event (time(), "daily", "wp_scheduled_delete");
   null;
end if;

-- Schedule transient cleanup.
if not hb_Next_Scheduled ("delete_expired_transients") and then not Hb_Installing then
--        hb_schedule_event( time(), "daily", "delete_expired_transients" );
          null;
end if;

Set_Screen_Options;  -- ();

Date_Format := abs "F j, Y";
Time_Format := abs "g:i a";

Hb_Enqueue_Script ("common");

--
-- $pagenow is set in vars.php.
-- $wp_importers is sometimes set in wp-admin/includes/import.php.
-- The remaining variables are imported as globals elsewhere, declared as globals here.
--
-- @global string $pagenow      The filename of the current screen.
-- @global array  $wp_importers
-- @global string $hook_suffix
-- @global string $plugin_page
-- @global string $typenow      The post type of the current screen.
-- @global string $taxnow       The taxonomy of the current screen.
--
global pagenow, hb_importers, hook_suffix, plugin_page, typenow, taxnow;

page_hook := null;

editing := false;

if Isset (X_GET ("page")) then
        Plugin_Page := Unslash (X_GET ("page"));
        Plugin_Page := Plugin_Basename (Plugin_Page);
end if;

if Isset (X_REQUEST ("post_type")) and then Post_Type_Exists (X_REQUEST ("post_type")) then
        Typenow := X_REQUEST ("post_type");
else
        Typenow := "";
end if;

if Isset (X_REQUEST ("taxonomy")) and then Taxonomy_Exists (X_REQUEST ("taxonomy")) then
        Taxnow := X_REQUEST ("taxonomy");
else
        Taxnow := "";
end if;

if HB_NETWORK_ADMIN then
        require ABSPATH . "wp-admin/network/menu.php";
elsif HB_USER_ADMIN then
        require ABSPATH . "wp-admin/user/menu.php";
else
        require ABSPATH . "wp-admin/menu.php";
end if;

if Current_User_Can ("manage_options") then
        Hb_Raise_Memory_Limit ("admin");
end if;

--
-- Fires as an admin screen or script is being initialized.
--
-- Note, this does not just run on user-facing admin screens.
-- It runs on admin-ajax.php and admin-post.php as well.
--
-- This is roughly analogous to the more general then@see "init"end; hook, which fires earlier.
--
-- @since 2.5.0
--
Do_Action ("admin_init");

if Isset (Plugin_Page) then
        if not Empty (Typenow) then
                The_Parent := Pagenow & "?post_type=" & Typenow;
        else
                The_Parent := Pagenow;
        end if;

        Page_Hook := Get_Plugin_Page_Hook (Plugin_Page, The_Parent);
        if not Page_Hook then
                Page_Hook := Get_Plugin_Page_Hook (Plugin_Page, Plugin_Page);

                -- Back-compat for plugins using add_management_page().
                if Empty (Page_Hook) and then "edit.php" = Pagenow and then Get_Plugin_Page_Hook (Plugin_Page, "tools.php") then
                        -- There could be plugin specific params on the URL, so we need the whole query string.
                        if not Empty (X_SERVER ("QUERY_STRING")) then
                                Query_String := X_SERVER ("QUERY_STRING");
                        else
                                Query_String := "page=" & Plugin_Page;
                        end if;
                        Hb_Redirect (Admin_Url ("tools.php?" & Query_String));
                        return; -- exit;
                end if;
        end if;
        Unset (The_Parent);
end if;

Hook_Suffix := "";
if Isset (Page_Hook) then
        Hook_Suffix := Page_Hook;
elsif Isset (Plugin_Page) then
        Hook_Suffix := Plugin_Page;
elsif Isset (Pagenow) then
        Hook_Suffix := Pagenow;
end if;

Set_Current_Screen; -- ();

-- Handle plugin admin pages.
if Isset (Plugin_Page) then
        if Page_Hook then
                --
                -- Fires before a particular screen is loaded.
                --
                -- The load-* hook fires in a number of contexts. This hook is for plugin screens
                -- where a callback is provided when the screen is registered.
                --
                -- The dynamic portion of the hook name, `page_hook`, refers to a mixture of plugin
                -- page information including:
                -- 1. The page type. If the plugin page is registered as a submenu page, such as for
                --    Settings, the page type would be "settings". Otherwise the type is "toplevel".
                -- 2. A separator of "_page_".
                -- 3. The plugin basename minus the file extension.
                --
                -- Together, the three parts form the `page_hook`. Citing the example above,
                -- the hook name used would be "load-settings_page_pluginbasename".
                --
                -- @see get_plugin_page_hook()
                --
                -- @since 2.1.0
                --
                Do_Action ("load-thenpage_hookend;");--/ phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                if not Isset (X_GET ("noheader")) then
                        require_once ABSPATH . "wp-admin/admin-header.php";
                end if;

                --
                -- Used to call the registered callback for a plugin screen.
                --
                -- This hook uses a dynamic hook name, `page_hook`, which refers to a mixture of plugin
                -- page information including:
                -- 1. The page type. If the plugin page is registered as a submenu page, such as for
                --    Settings, the page type would be "settings". Otherwise the type is "toplevel".
                -- 2. A separator of "_page_".
                -- 3. The plugin basename minus the file extension.
                --
                -- Together, the three parts form the `page_hook`. Citing the example above,
                -- the hook name used would be "settings_page_pluginbasename".
                --
                -- @see get_plugin_page_hook()
                --
                -- @since 1.5.0
                --
                Do_Action (Page_Hook);
        else
                if Validate_File (plugin_page) then
                        Hb_Die (abs  "Invalid plugin page.");
                end if;

                if
                  not (File_Exists (HB_PLUGIN_DIR & "/plugin_page") and then Is_File (HB_PLUGIN_DIR & "/plugin_page"))
                  and then not (File_Exists (HBMU_PLUGIN_DIR & "/plugin_page") and then Is_File (HBMU_PLUGIN_DIR & "/plugin_page"))
                then
                        -- translators: %s: Admin page generated by a plugin. */
                        Hb_Die (Sprintf (abs "Cannot load %s.", Htmlentities (plugin_page)));
                end if;

                --
                -- Fires before a particular screen is loaded.
                --
                -- The load-* hook fires in a number of contexts. This hook is for plugin screens
                -- where the file to load is directly included, rather than the use of a function.
                --
                -- The dynamic portion of the hook name, `plugin_page`, refers to the plugin basename.
                --
                -- @see plugin_basename()
                --
                -- @since 1.5.0
                --
                Do_Action ("load-{plugin_page}"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

                if not Isset (X_GET ("noheader")) then
                        require_once ABSPATH . "wp-admin/admin-header.php";
                end if;

                if File_Exists (HBMU_PLUGIN_DIR & "/plugin_page") then
                        include WPMU_PLUGIN_DIR & "/plugin_page";
                else
                        include WP_PLUGIN_DIR & "/plugin_page";
                end if;
        end if;

        require_once ABSPATH . "wp-admin/admin-footer.php";

        return;  -- exit;
elsif Isset (X_GET ("import")) then

        Importer := X_GET ("import");

        if not Current_User_Can ("import") then
                Hb_Die (abs  "Sorry, you are not allowed to import content into this site.");
        end if;

        if Validate_File (Importer) then
                Hb_Redirect (Admin_Url ("import.php?invalid=" & importer));
                return; -- exit;
        end if;

        if not Isset (Hb_Importers (Importer)) or else not Is_Callable (Hb_Importers (Importer) (2)) then
                Hb_Redirect (Admin_Url ("import.php?invalid=" & Importer));
                return; -- exit;
        end if;

        --
        -- Fires before an importer screen is loaded.
        --
        -- The dynamic portion of the hook name, `importer`, refers to the importer slug.
        --
        -- Possible hook names include:
        --
        --  - `load-importer-blogger`
        --  - `load-importer-wpcat2tag`
        --  - `load-importer-livejournal`
        --  - `load-importer-mt`
        --  - `load-importer-rss`
        --  - `load-importer-tumblr`
        --  - `load-importer-wordpress`
        --
        -- @since 3.5.0
        --
        Do_Action ("load-importer-{importer}"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

        -- Used in the HTML title tag.
        Title        := abs "Import";
        Parent_File  := "tools.php";
        Submenu_File := "import.php";

        if not Isset (X_GET ("noheader")) then
                require_once ABSPATH . "wp-admin/admin-header.php";
        end if;

        require_once ABSPATH . "wp-admin/includes/upgrade.php";

        define ("WP_IMPORTING", true);

        --
        -- Whether to filter imported data through kses on import.
        --
        -- Multisite uses this hook to filter all data through kses by default,
        -- as a super administrator may be assisting an untrusted user.
        --
        -- @since 3.1.0
        --
        -- @param bool force Whether to force data to be filtered through kses. Default false.
        --
        if Apply_Filters ("force_filtered_html_on_import", False) then
                Kses_Init_Filters; -- () -- Always filter imported data with kses on multisite.
        end if;

        Call_User_Func (Hb_Importers (Importer) (2));

        require_once ABSPATH . "wp-admin/admin-footer.php";

        -- Make sure rules are flushed.
        Flush_Rewrite_Rules (False);

        return; -- exit;
else
        --
        -- Fires before a particular screen is loaded.
        --
        -- The load-* hook fires in a number of contexts. This hook is for core screens.
        --
        -- The dynamic portion of the hook name, `pagenow`, is a global variable
        -- referring to the filename of the current screen, such as "admin.php",
        -- "post-new.php" etc. A complete hook for the latter would be
        -- "load-post-new.php".
        --
        -- @since 2.1.0
        --
        Do_Action ("load-{pagenow}"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

        --
        -- The following hooks are fired to ensure backward compatibility.
        -- In all other cases, "load-" . pagenow should be used instead.
        --
        if "page" = Typenow then
                if "post-new.php" = Pagenow then
                        Do_Action ("load-page-new.php"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                elsif "post.php" = Pagenow then
                        Do_Action ("load-page.php"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                end if;
        elsif "edit-tags.php" = Pagenow then
                if "category" = Taxnow then
                        Do_Action ("load-categories.php"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                elsif "link_category" = taxnow then
                        Do_Action ("load-edit-link-categories.php"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                end if;
        elsif "term.php" = Pagenow then
                Do_Action ("load-edit-tags.php"); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
        end if;
end if;

if not Empty (X_REQUEST ("action")) then
        Action := X_REQUEST ("action");

        --
        -- Fires when an "action" request variable is sent.
        --
        -- The dynamic portion of the hook name, `action`, refers to
        -- the action derived from the `GET` or `POST` request.
        --
        -- @since 2.6.0
        --
        Do_Action ("admin_action_{action}");
end if;












   end Run;

end Hb_Admin;
