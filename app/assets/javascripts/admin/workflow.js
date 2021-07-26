Blacklight.onLoad(function() {
  $('#workflow-approved-table').DataTable( {
    'processing': true,
    'serverSide': true,
    "ajax": '/hyrax/admin/workflows/approved.json',
    "pageLength": 5,
    "lengthMenu": [[5, 10, 50, 100, 200], [5, 10, 50, 100, 200]],
    "columns": [
      {
        "orderable":      false,
        "data":           "title",
      },
      { "data": "depositor" },
      { "data": "submission_date" },
      { "data": "last_modified_date" },
      { "data": "status" }
    ]
  } );

  $('#workflow-under-review-table').DataTable( {
    'processing': true,
    'serverSide': true,
    "ajax": '/hyrax/admin/workflows/under_review.json',
    "pageLength": 5,
    "lengthMenu": [[5, 10, 50, 100, 200], [5, 10, 50, 100, 200]],
    "columns": [
      {
        "orderable":      false,
        "data":           "title",
      },
      { "data": "depositor" },
      { "data": "submission_date" },
      { "data": "last_modified_date" },
      { "data": "status" }
    ]
  } );
})
