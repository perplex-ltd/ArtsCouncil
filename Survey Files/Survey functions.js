
function setup() {

    // Make 1..5 radio button questions horizontal
    if (window.matchMedia("(min-width: 530px)").matches) {
        clickd_jquery("td:contains('1')").
            parent("tr").
            siblings().
            addBack().
            css("float", "left"); 
    }

    // Unbold
    clickd_jquery("div.responsiveRow #skills").
        parents(".responsiveRow").
        nextUntil(clickd_jquery("div.responsiveRow #skills_end").
            parents(".responsiveRow")).
        find("span b").
        css("font-weight", "normal");

    clickd_jquery("#multioption12_8b7365732876e911a98800224800c719") .click(function() {
        clickd_jquery("#cont_title_id_f_9b01ea972876e911a98800224800c719").parents(".responsiveRow").toggle(this.checked);
    });
    clickd_jquery("#cont_title_id_f_9b01ea972876e911a98800224800c719").parents(".responsiveRow").hide();
}
clickd_jquery('document').ready(setup);
