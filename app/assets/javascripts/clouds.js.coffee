#= require helpers/avatar

$(document).bind 'new_clouds.load edit_clouds.load', (e,obj) =>
  $("fieldset.avatarupload").avatarUpload()

    