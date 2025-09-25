
--
-- WordPress Administration Bootstrap
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Numerics.Discrete_Random;
with Ada.Strings.Unbounded;

with Arrays;
with Globals;
with HB_Common;
with Php;

with Adi_Plugins;
with Adi_Screens;
with Adm_Menu;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_Http;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Load;
with Inc_Ms_Functions;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Posts;
with Inc_Rewrites;
with Inc_Taxonomys;
with Inc_Versions;

package body Adm_Admin
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use HB_Common;
   use Inc_L10n;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Globals;
      use Adi_Plugins;
      use Inc_Plugins;

      Unused : Boolean;
   begin
--
-- In WordPress Administration Screens
--
-- @since 2.3.2
--
-- if ( ! defined( 'WP_ADMIN' ) ) then
--        define( 'WP_ADMIN', true );
-- end;

-- if ( ! defined( 'WP_NETWORK_ADMIN' ) ) then
--        define( 'WP_NETWORK_ADMIN', false );
-- end;

-- if ( ! defined( 'WP_USER_ADMIN' ) ) then
--        define( 'WP_USER_ADMIN', false );
-- end;

      if not WP_NETWORK_ADMIN and then not WP_USER_ADMIN then
         WP_BLOG_ADMIN := True;
      end if;

      if
        Isset (String'(Get (XX_GET, "import"))) and then
        not WP_LOAD_IMPORTERS
      then
         WP_LOAD_IMPORTERS := True;
      end if;

      -- require_once dirname( __DIR__ ) . "/wp-load.php";

      Inc_Functions.Nocache_Headers; -- ();

      if "" /= Inc_Options.Get_Option ("db_upgraded") then

         Inc_Rewrites.Flush_Rewrite_Rules; -- ();
         Unused := Inc_Options.Update_Option ("db_upgraded", False);

         --
         -- Fires on the next page load after a successful DB upgrade.
         --
         -- @since 2.8.0
         --
         Do_Action ("after_db_upgrade");

      elsif not Inc_Load.Wp_Doing_Ajax and then Empty (X_POST)
        and then Inc_Options.Get_Option ("db_version") /= Inc_Versions.wp_db_version
      then

         if not Inc_Load.Is_Multisite then
            Inc_Pluggables.Wp_Redirect
               (Inc_Link_Templates.Admin_URL
                 ("upgrade.php?_wp_http_referer=" &
                  Php.Urlencode (Inc_Formatting.Wp_Unslash
                                  (Get (X_SERVER, "REQUEST_URI")))));
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
         -- @param bool $do_mu_upgrade Whether to perform the Multisite upgrade
         -- routine. Default true.
         --
         if Apply_Filters ("do_mu_upgrade", True) then
            declare
               use Inc_Ms_Functions;

               C : constant Natural := Get_Blog_Count;
               type Site_Count is range 1 .. 1000;

               package Site_Random is new
                  Ada.Numerics.Discrete_Random (Result_Subtype => Site_Count);
               use Site_Random;

               Gen  : Generator;
               Pick : Site_Count;
            begin
               Reset (Gen);
               Pick := Random (Gen, First => 1, Last => Site_Count (C / 50));
               --
               -- If there are 50 or fewer sites, run every time. Otherwise, throttle
               -- to reduce load:
               -- attempt to do no more than threshold value, with some +/- allowed.
               --
               if
                 C <= 50 or else
                (C > 50 and then Pick = 1)
--              (C > 50 and then Mt_Rand (0, Integer (C / 50)) = 1)
               then
--                       require_once ABSPATH . WPINC . "/http.php";
                  declare
                     Response : Array_Type;
                  begin
                     Response := Inc_Http.Wp_Remote_Get (
                        Inc_Link_Templates.Admin_URL ("upgrade.php?step=1"),
                           Arrays.To_Array ((
                              Build ("timeout",     120),
                              Build ("httpversion", "1.1")
                           ))
                        );
                     -- This action is documented in wp-admin/network/upgrade.php
--                     Do_Action ("after_mu_upgrade", Response);
--                     Unset (Response);
                  end;
               end if;
--             Unset (C);
            end;
         end if;
      end if;

-- require_once ABSPATH . "wp-admin/includes/admin.php";

      Inc_Pluggables.Auth_Redirect; -- ();

--       -- Schedule Trash collection.
--       if
--         not Wp_Next_Scheduled ("wp_scheduled_delete") and then
--         not wp_Installing
--       then
-- --       wp_Schedule_Event (time(), "daily", "wp_scheduled_delete");
--          null;
--       end if;

--       -- Schedule transient cleanup.
--       if
--         not wp_Next_Scheduled ("delete_expired_transients") and then
--         not wp_Installing
--       then
-- --       wp_schedule_event( time(), "daily", "delete_expired_transients" );
--          null;
--       end if;

--      Set_Screen_Options;  -- ();

--      Date_Format := abs "F j, Y";
--      Time_Format := abs "g:i a";

      Inc_Functions_Wp_Scripts.Wp_Enqueue_Script ("common");

      --
      -- $pagenow is set in vars.php.
      -- $wp_importers is sometimes set in wp-admin/includes/import.php.
      -- The remaining variables are imported as globals elsewhere, declared as
      -- globals here.
      --
      -- @global string $pagenow      The filename of the current screen.
      -- @global array  $wp_importers
      -- @global string $hook_suffix
      -- @global string $plugin_page
      -- @global string $typenow      The post type of the current screen.
      -- @global string $taxnow       The taxonomy of the current screen.
      --
--      global pagenow, wp_importers, hook_suffix, plugin_page, typenow, taxnow;
      declare
         use Adm_Menu;

         Page_Hook : Unbounded_String; -- = null;
         Unused    : Integer;
      begin
--    Editing := False;

         if Isset (XX_GET, "page") then
            Plugin_Page :=
              +Slug_Type (Inc_Formatting.Wp_Unslash (Get (XX_GET, "page")));

            Plugin_Page :=
              +Slug_Type (Inc_Plugins.Plugin_Basename (String (-Plugin_Page)));
         end if;

         if
           Isset (X_REQUEST, "post_type") and then
           Inc_Posts.Post_Type_Exists (Get (X_REQUEST, "post_type"))
         then
            Typenow := +Get (X_REQUEST, "post_type");
         else
            Typenow := +"";
         end if;

         if
           Isset (X_REQUEST, "taxonomy") and then
           Inc_Taxonomys.Taxonomy_Exists (Get (X_REQUEST, "taxonomy"))
         then
            Taxnow := +Get (X_REQUEST, "taxonomy");
         else
            Taxnow := +"";
         end if;

         -- if WP_NETWORK_ADMIN then
         --    require ABSPATH . "wp-admin/network/menu.php";
         -- elsif WP_USER_ADMIN then
         --    require ABSPATH . "wp-admin/user/menu.php";
         -- else
         --    require ABSPATH . "wp-admin/menu.php";
         -- end if;

         if Inc_Capabilities.Current_User_Can ("manage_options") then
            Unused := Inc_Functions.Wp_Raise_Memory_Limit ("admin");
         end if;

         --
         -- Fires as an admin screen or script is being initialized.
         --
         -- Note, this does not just run on user-facing admin screens.
         -- It runs on admin-ajax.php and admin-post.php as well.
         --
         -- This is roughly analogous to the more general {@see "init"} hook,
         -- which fires earlier.
         --
         -- @since 2.5.0
         --
         Do_Action ("admin_init");

         if Plugin_Page /= "" then
            declare
               The_Parent : Unbounded_String;
            begin
               if Typenow /= "" then
                  The_Parent := Pagenow & "?post_type=" & Typenow;
               else
                  The_Parent := Pagenow;
               end if;

               Page_Hook := +Get_Plugin_Page_Hook (String (-Plugin_Page),
                                                   -The_Parent);
               if Page_Hook = "" then
                  Page_Hook := +Get_Plugin_Page_Hook (String (-Plugin_Page),
                                                      String (-Plugin_Page));

                  -- Back-compat for plugins using add_management_page().
                  if
                    Page_Hook = "" and then
                    "edit.php" = Pagenow and then
                    "" /= Get_Plugin_Page_Hook (String (-Plugin_Page), "tools.php")
                  then
                     -- There could be plugin specific params on the URL, so we need
                     -- the whole query string.
                     declare
                        Query_String : Unbounded_String;
                     begin
                        if Get (X_SERVER, "QUERY_STRING") /= "" then
                           Query_String := +String'(Get (X_SERVER, "QUERY_STRING"));
                        else
                           Query_String := "page=" & Unbounded_String (Plugin_Page);
                        end if;
                        Inc_Pluggables.Wp_Redirect
                           (Inc_Link_Templates.Admin_URL
                              ("tools.php?" & (-Query_String)));
                     end;
                     return; -- exit;
                  end if;
               end if;
--             Unset (The_Parent);
            end;
         end if;

         Hook_Suffix := +"";
         if Page_Hook /= "" then
            Hook_Suffix := Page_Hook;
         elsif Plugin_Page /= "" then
            Hook_Suffix := Unbounded_String (Plugin_Page);
         elsif Pagenow /= "" then
            Hook_Suffix := Pagenow;
         end if;

         Adi_Screens.Set_Current_Screen; -- ();

         -- Handle plugin admin pages.
         if Plugin_Page /= "" then
            if Page_Hook /= "" then
               --
               -- Fires before a particular screen is loaded.
               --
               -- The load-* hook fires in a number of contexts. This hook is for plugin
               -- screens where a callback is provided when the screen is registered.
               --
               -- The dynamic portion of the hook name, `page_hook`, refers to a mixture
               -- of plugin page information including:
               -- 1. The page type. If the plugin page is registered as a submenu page,
               --    such as for Settings, the page type would be "settings". Otherwise
               --    the type is "toplevel".
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
               Do_Action ("load-{page_hook}");
               -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

               -- if not Isset (XX_GET ("noheader")) then
               --    require_once ABSPATH . "wp-admin/admin-header.php";
               -- end if;

               --
               -- Used to call the registered callback for a plugin screen.
               --
               -- This hook uses a dynamic hook name, `page_hook`, which refers to a
               -- mixture of plugin page information including:
               -- 1. The page type. If the plugin page is registered as a submenu page,
               --    such as for Settings, the page type would be "settings". Otherwise
               --    the type is "toplevel".
               -- 2. A separator of "_page_".
               -- 3. The plugin basename minus the file extension.
               --
               -- Together, the three parts form the `page_hook`. Citing the example
               -- above, the hook name used would be "settings_page_pluginbasename".
               --
               -- @see get_plugin_page_hook()
               --
               -- @since 1.5.0
               --
               Do_Action (-Page_Hook);
            else
               if Inc_Functions.Validate_File (String (-Plugin_Page)) /= 0 then
                  Inc_Functions.Wp_Die (abs  "Invalid plugin page.");
               end if;

               if
                 not (Php.File_Exists (WP_PLUGIN_DIR & "/plugin_page") and then
                 Php.Is_File (WP_PLUGIN_DIR & "/plugin_page")) and then
                 not (Php.File_Exists (WPMU_PLUGIN_DIR & "/plugin_page") and then
                 Php.Is_File (WPMU_PLUGIN_DIR & "/plugin_page"))
               then
                  -- translators: %s: Admin page generated by a plugin.
                  Inc_Functions.Wp_Die (Sprintf (abs "Cannot load %s.",
                                                 Php.Htmlentities (String (-Plugin_Page))));
               end if;

               --
               -- Fires before a particular screen is loaded.
               --
               -- The load-* hook fires in a number of contexts. This hook is for plugin
               -- screens where the file to load is directly included, rather than the
               -- use of a function.
               --
               -- The dynamic portion of the hook name, `plugin_page`, refers to the
               -- plugin basename.
               --
               -- @see plugin_basename()
               --
               -- @since 1.5.0
               --
               Do_Action ("load-{plugin_page}");
               -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

               -- if not Isset (SX_GET ("noheader")) then
               --    require_once ABSPATH . "wp-admin/admin-header.php";
               -- end if;

               -- if File_Exists (HBMU_PLUGIN_DIR & "/plugin_page") then
               --    include WPMU_PLUGIN_DIR & "/plugin_page";
               -- else
               --    include WP_PLUGIN_DIR & "/plugin_page";
               -- end if;
            end if;

--          require_once ABSPATH . "wp-admin/admin-footer.php";

            return;  -- exit;

         elsif Isset (XX_GET, "import") then
            declare
               Importer : constant String := Get (XX_GET, "import");
            begin
               if not Inc_Capabilities.Current_User_Can ("import") then
                  Inc_Functions.Wp_Die
                    (abs  "Sorry, you are not allowed to import content into this site.");
               end if;

               if Inc_Functions.Validate_File (Importer) /= 0 then
                  Inc_Pluggables.Wp_Redirect
                     (Inc_Link_Templates.Admin_URL ("import.php?invalid=" & Importer));
                  return; -- exit;
               end if;

               if False
--               not Isset (Wp_Importers (Importer)) -- or else
--               not Is_Callable (Wp_Importers (Importer) (2))
               then
                  Inc_Pluggables.Wp_Redirect
                     (Inc_Link_Templates.Admin_URL ("import.php?invalid=" & Importer));
                  return; -- exit;
               end if;

               --
               -- Fires before an importer screen is loaded.
               --
               -- The dynamic portion of the hook name, `importer`, refers to the
               -- importer slug.
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
               Do_Action ("load-importer-{importer}");
               -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

               -- Used in the HTML title tag.
               Title        := +abs "Import";
               Parent_File  := Adm_Menu."+" ("tools.php");
               Submenu_File := +"import.php";

               -- if not Isset (XX_GET ("noheader")) then
               --    require_once ABSPATH . "wp-admin/admin-header.php";
               -- end if;

               -- require_once ABSPATH . "wp-admin/includes/upgrade.php";

--             WP_IMPORTING := True;

               --
               -- Whether to filter imported data through kses on import.
               --
               -- Multisite uses this hook to filter all data through kses by default,
               -- as a super administrator may be assisting an untrusted user.
               --
               -- @since 3.1.0
               --
               -- @param bool force Whether to force data to be filtered through kses.
               --                   Default false.
               --
               if Apply_Filters ("force_filtered_html_on_import", False) then
--                Kses_Init_Filters; -- () -- Always filter imported data with kses on multisite.
                  null;
               end if;

--             Call_User_Func (Wp_Importers (Importer) (2));
            end;
--          require_once ABSPATH . "wp-admin/admin-footer.php";

            -- Make sure rules are flushed.
            Inc_Rewrites.Flush_Rewrite_Rules (False);

            return; -- exit;
         else
            --
            -- Fires before a particular screen is loaded.
            --
            -- The load-* hook fires in a number of contexts. This hook is for core
            -- screens.
            --
            -- The dynamic portion of the hook name, `pagenow`, is a global variable
            -- referring to the filename of the current screen, such as "admin.php",
            -- "post-new.php" etc. A complete hook for the latter would be
            -- "load-post-new.php".
            --
            -- @since 2.1.0
            --
            Do_Action ("load-{pagenow}");
            -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

            --
            -- The following hooks are fired to ensure backward compatibility.
            -- In all other cases, "load-" . pagenow should be used instead.
            --
            if "page" = Typenow then
               if "post-new.php" = Pagenow then
                  Do_Action ("load-page-new.php");
                  -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
               elsif "post.php" = Pagenow then
                  Do_Action ("load-page.php");
                  -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
               end if;
            elsif "edit-tags.php" = Pagenow then
               if "category" = Taxnow then
                  Do_Action ("load-categories.php");
                  -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
               elsif "link_category" = Taxnow then
                  Do_Action ("load-edit-link-categories.php");
                  -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
               end if;
            elsif "term.php" = Pagenow then
               Do_Action ("load-edit-tags.php");
               -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
            end if;
         end if;
      end;

      if not Empty (X_REQUEST, "action") then
         declare
            Action : constant String := Get (X_REQUEST, "action");
         begin
            --
            -- Fires when an "action" request variable is sent.
            --
            -- The dynamic portion of the hook name, `action`, refers to
            -- the action derived from the `GET` or `POST` request.
            --
            -- @since 2.6.0
            --
            Do_Action ("admin_action_" & Action);
         end;
      end if;
   end Run;

end Adm_Admin;
