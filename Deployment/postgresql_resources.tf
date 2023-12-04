# Enable workload identity in postgres:
# https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-connect-with-managed-identity#creating-a-postgresql-user-for-your-managed-identity

# select * from pgaadauth_create_principal('<identity_name>', false, false);
# https://github.com/MicrosoftDocs/azure-docs/issues/102693#issuecomment-1668488887

# SELECT pg_get_functiondef((SELECT oid FROM pg_proc WHERE proname = 'pgaadauth_create_principal'));

# CREATE OR REPLACE FUNCTION pg_catalog.pgaadauth_create_principal(rolename text, isadmin boolean, ismfa boolean)                                   +
#   RETURNS text                                                                                                                                     +
#   LANGUAGE plpgsql                                                                                                                                 +
#  AS $function$                                                                                                                                     +
#      DECLARE securityLabel text := 'aadauth';                                                                                                      +
#      DECLARE createRoleQuery text;                                                                                                                 +
#      DECLARE securityLabelQuery text;                                                                                                              +
#      DECLARE query text;                                                                                                                           +
#      BEGIN                                                                                                                                         +
#          createRoleQuery := FORMAT('CREATE ROLE %1$s LOGIN',  quote_ident(roleName));                                                              +
#                                                                                                                                                    +
#          IF isAdmin IS TRUE THEN                                                                                                                   +
#              createRoleQuery := CONCAT(createRoleQuery,  ' CREATEROLE CREATEDB in role azure_pg_admin');                                           +
#              securityLabel := CONCAT(securityLabel, ',admin');                                                                                     +
#          END IF;                                                                                                                                   +
#                                                                                                                                                    +
#          createRoleQuery := CONCAT(createRoleQuery, ';');                                                                                          +
#                                                                                                                                                    +
#          IF isMfa IS TRUE THEN                                                                                                                     +
#              securityLabel := CONCAT(securityLabel, ',mfa');                                                                                       +
#          END IF;                                                                                                                                   +
#                                                                                                                                                    +
#          EXECUTE createRoleQuery;                                                                                                                  +
#                                                                                                                                                    +
#          securityLabelQuery := FORMAT('SECURITY LABEL for "pgaadauth" on role %1$s is %2$s', quote_ident(roleName) , quote_literal(securityLabel));+
#                                                                                                                                                    +
#          EXECUTE securityLabelQuery;                                                                                                               +
#                                                                                                                                                    +
#          RETURN FORMAT('Created role for %1$s', quote_ident(roleName));                                                                            +
#      END;  


# resource "postgresql_role" "app_identity" {
#   name     = "app"
#   login    = true
#   password = azurerm_user_assigned_identity.app.client_id
#   roles    = ["azure_ad_user"]
# }
