# frozen_string_literal: true

def expect_social_fields
  assert_select "input[name=?]", "user[avatar]"
  assert_select "input[name=?]", "user[facebook_handle]"
  assert_select "input[name=?]", "user[twitter_handle]"
  assert_select "input[name=?]", "user[googleplus_handle]"
  assert_select "input[name=?]", "user[chat_id]"
  assert_select "input[name=?]", "user[website]"
end

def expect_contact_fields
  assert_select "input[name=?]", "user[email]"
  assert_select "input[name=?]", "user[display_name]"
  assert_select "input[name=?]", "user[address]"
  assert_select "input[name=?]", "user[department]"
  assert_select "input[name=?]", "user[title]"
  assert_select "input[name=?]", "user[office]"
  assert_select "input[name=?]", "user[affiliation]"
  assert_select "input[name=?]", "user[telephone]"
  assert_select "input[name=?]", "user[orcid]"
end

def expect_additional_fields
  assert_select "textarea[name=?]", "user[group_list]"
  assert_select "input[name=?]", "user[arkivo_subscription]"
  assert_select "input[name=?]", "user[preferred_locale]"
end

def create_hyrax_countermetric_objects
  Hyrax::CounterMetric.create(
    worktype: 'GenericWork',
    resource_type: 'Book',
    work_id: '12345',
    date: '2022-01-05',
    total_item_investigations: 1,
    total_item_requests: 10
  )
  Hyrax::CounterMetric.create(
    worktype: 'GenericWork',
    resource_type: 'Book',
    work_id: '54321',
    date: '2022-01-05',
    total_item_investigations: 3,
    total_item_requests: 5
  )
  Hyrax::CounterMetric.create(
    worktype: 'GenericWork',
    resource_type: 'Article',
    work_id: '98765',
    date: '2023-08-09',
    total_item_investigations: 2,
    total_item_requests: 8
  )
end
