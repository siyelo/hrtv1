// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict()

var code_assignments_budget = {
  run: function () {

    /*
     * Adds collapsible checkbox tree functionality for a tab and validates classification tree
     * @param {String} tab
     *
     */
    var addCollabsibleButtons = function (tab) {
      jQuery('.' + tab + ' ul.activity_tree').collapsibleCheckboxTree({tab: tab});
      jQuery('.' + tab + ' ul.activity_tree').validateClassificationTree();
    };

    // collapsible checkboxes for tab1
    jQuery('.tooltip').tipsy({gravity: 'e'});
    addCollabsibleButtons('tab1');

    // load budget districts
    jQuery.get('/activities/' + _activity_id + '/coding/budget_districts', function (response) {
      jQuery("#activity_classification").append(response);
      addCollabsibleButtons('tab2');
    });

    // load budget cost categorization
    jQuery.get('/activities/' + _activity_id + '/coding/budget_cost_categories', function (response) {
      jQuery("#activity_classification").append(response);
      addCollabsibleButtons('tab3');
    });

    // load expenditure
    jQuery.get('/activities/' + _activity_id + '/coding/expenditure', function (response) {
      jQuery("#activity_classification").append(response);
      addCollabsibleButtons('tab4');
    });

    // load expenditure districts
    jQuery.get('/activities/' + _activity_id + '/coding/expenditure_districts', function (response) {
      jQuery("#activity_classification").append(response);
      addCollabsibleButtons('tab5');
    });
    // load expenditure cost categories
    jQuery.get('/activities/' + _activity_id + '/coding/expenditure_cost_categories', function (response) {
      jQuery("#activity_classification").append(response);
      addCollabsibleButtons('tab6');
    });

    // bind click events for tabs
    jQuery(".nav2 ul li").click(function (e) {
      e.preventDefault();
      jQuery(".nav2 ul li").removeClass('selected');
      jQuery(this).addClass('selected');
      jQuery("#activity_classification > div").hide();
      jQuery('#activity_classification > div.' + jQuery(this).attr("id")).show();
    });

  }
};

jQuery(function () {
  var id = jQuery('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof window[controller_action] !== 'undefined') {
      window[controller_action]['run']();
    }
  }
})
