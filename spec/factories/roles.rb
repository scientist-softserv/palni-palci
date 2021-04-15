FactoryBot.define do
  factory :role do
    name { 'test_role' }

    factory :admin_role do
      name          { 'admin' }
      resource_id   { Site.instance.id }
      resource_type { 'Site' }
    end

    factory :collection_manager_role do
      name          { 'collection_manager' }
      resource_id   { Site.instance.id }
      resource_type { 'Site' }
    end

    factory :collection_editor_role do
      name          { 'collection_editor' }
      resource_id   { Site.instance.id }
      resource_type { 'Site' }
    end

    factory :collection_reader_role do
      name          { 'collection_reader' }
      resource_id   { Site.instance.id }
      resource_type { 'Site' }
    end

    factory :tenant_manager_role do
      name          { 'tenant_manager' }
      resource_id   { Site.instance.id }
      resource_type { 'Site' }
    end

    factory :tenant_editor_role do
      name          { 'tenant_editor' }
      resource_id   { Site.instance.id }
      resource_type { 'Site' }
    end

    factory :tenant_reader_role do
      name          { 'tenant_reader' }
      resource_id   { Site.instance.id }
      resource_type { 'Site' }
    end

    factory :user_admin_role do
      name          { 'user_admin' }
    end

    factory :user_manager_role do
      name          { 'user_manager' }
    end

    factory :user_reader_role do
      name          { 'user_reader' }
    end
  end
end
