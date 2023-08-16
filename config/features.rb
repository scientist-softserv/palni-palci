# frozen_string_literal: true

Flipflop.configure do
  feature :show_workflow_roles_menu_item_in_admin_dashboard_sidebar,
          default: false,
          description: "Shows the Workflow Roles menu item in the admin dashboard sidebar."

  feature :show_featured_researcher,
          default: true,
          description: "Shows the Featured Researcher tab on the homepage."

  feature :show_share_button,
          default: true,
          description: "Shows the 'Share Your Work' button on the homepage."

  feature :show_featured_works,
          default: true,
          description: "Shows the Featured Works tab on the homepage."

  feature :show_recently_uploaded,
          default: true,
          description: "Shows the Recently Uploaded tab on the homepage."

  feature :show_identity_provider_in_admin_dashboard,
          default: false,
          description: "Shows the Identity Provider tab on the admin dashboard."

  feature :use_iiif_print,
          default: false,
          description: "Use IIIF Print for derivative generation (with PDF splitting and OCR)."         
end
