$(document).on('turbolinks:load ready', function() {
	var provider = $('#auth_provider_provider').val();
	if (provider == 'saml') {
		$('#saml-fields').show();
		$('#oidc-fields').hide();
	} else if (provider == 'oidc') {
		$('#saml-fields').hide();
		$('#oidc-fields').show();
	} else {
		$('#saml-fields').hide();
		$('#oidc-fields').hide();
	}

  $('body').on('change', '#auth_provider_provider', function(e) {
		provider = $(this).val();
		if (provider == 'saml') {
			$('#saml-fields').show();
			$('#oidc-fields').hide();
		} else if (provider == 'oidc') {
			$('#saml-fields').hide();
			$('#oidc-fields').show();
		} else {
			$('#saml-fields').hide();
			$('#oidc-fields').hide();
		}
  });
});

