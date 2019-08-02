$(document).ready(function () {
 var entitlementField = $("#entitlementid");
 if (entitlementField && entitlementField.closest('td').get(0) && entitlementField.closest('td').get(0).style.display == "none") {
  //remove required class and validator if entitlement isn't showing
  $("#entitlementid_label").parent().removeClass("required");
  if (typeof (Page_Validators) == 'undefined') return;
  if ($("#RequiredFieldValidatorentitlementid") != 'undefined' && entitlementField.closest('td').get(0).style.display == "none") {
   $("#entitlementid_label").parent().removeClass("required");
   Array.remove(Page_Validators, document.getElementById('RequiredFieldValidatorentitlementid'));
  }
 }
});