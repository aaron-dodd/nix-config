{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = {
        smartCardSupport = true;
      };
      extraPolicies = {
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisablePocket = true;
        DisableTelemetry = true;
        EnableTrackingProtection = {
          Cryptomining = true;
          Fingerprinting = true;
          Value = true;
        };
        EncryptedMediaExtensions = {
          Enabled = true;
        };
        FirefoxHome = {
          Pocket = false;
          Search = false;
          Snippets = false;
        };
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        SearchSuggestEnabled = false;
        UserMessaging = {
          ExtensionRecommendations = false;
          MoreFromMozilla = false;
          SkipOnboarding = true;
          WhatsNew = false;
        };
      };
    };
    profiles = {
      aaron = {
        isDefault = true;
        bookmarks = { };
        search = {
          engines = {
            "Brave Search" = {
              urls = [{
                template = "https://search.brave.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }];

              definedAliases = [ "@b" ];
            };
            "Nix flakes" = {
              urls = [{
                template = "https://search.nixos.org/flakes";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nf" ];
            };
            "Nix flake options" = {
              urls = [{
                template = "https://search.nixos.org/flakes";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nfo" ];
            };
            "Nix flake packages" = {
              urls = [{
                template = "https://search.nixos.org/flakes";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nfp" ];
            };
            "Nix options" = {
              urls = [{
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            "Nix packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "Amazon.co.uk".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = true;
            "Google".metaData.hidden = true;
            "Wikipedia (en)".metaData.hidden = true;
            "eBay".metaData.hidden = true;
          };
          default = "Brave Search";
          force = true;
        };
        settings = {
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.default.sites" = "";
          "browser.newtabpage.enabled" = false;
          "browser.startup.homepage" = "https://search.brave.com";
          "browser.startup.page" = 0;

          "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
          "geo.provider.ms-windows-location" = false;
          "geo.provider.use_corelocation" = false;
          "geo.provider.use_gpsd" = false;
          "geo.provider.use_geoclue" = false;

          "extensions.getAddons.showPane" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "browser.discovery.enabled" = false;

          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;

          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";
          "browser.ping-centre.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;

          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";

          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

          "dom.security.https_only_mode" = true;
          "privacy.trackingprotection.enabled" = true;
        };
      };
    };
  };

  home.file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
    "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
