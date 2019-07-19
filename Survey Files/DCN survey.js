function setup() {
    // Make 1..5 radio button questions horizontal
    if (window.matchMedia("(min-width: 530px)").matches) {
        clickd_jquery("td:contains('1')").
            parent("tr").
            siblings().
            addBack().
            css("float", "left"); 
    }
    // Unbold (for Impact and event surveys only)
    clickd_jquery("div.responsiveRow #skills").
        parents(".responsiveRow").
        nextUntil(clickd_jquery("div.responsiveRow #skills_end").
        parents(".responsiveRow")).
        find("span b").
        css("font-weight", "normal");
}

clickd_jquery('document').ready(setup);



/// For Event satisfaction survey only
var cdFieldId = "f_a6e00b7d1956e911a98200224800c719";

function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
        }
    }
};

clickd_jquery(document).ready(function () {
    var eventParticipationId = getUrlParameter("ace_eventparticipationid");
	console.log(eventParticipationId);
	clickd_jquery("#" + cdFieldId).val(eventParticipationId);
    clickd_jquery("#cont_title_id_" + cdFieldId).hide();
	clickd_jquery("#cont_id_" + cdFieldId).hide();
});
