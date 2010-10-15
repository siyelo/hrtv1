// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict()

var data_responses_show = {
  run: function () {
    jQuery('.project.entry_header').click(function () {
      jQuery(this).next('.project.entry_main').toggle();
    });

    jQuery('.activity.entry_header').click(function () {
      jQuery(this).next('.activity.entry_main').toggle();
    });
  }
}

var code_assignments_show = {
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

    /*
     * Appends tab content 
     * @param {String} tab
     * @param {String} response
     *
     */
    var appendTab = function (tab, response) {
      jQuery("#activity_classification ." + tab).html(response);
      addCollabsibleButtons(tab);
    };

    // collapsible checkboxes for tab1
    jQuery('.tooltip').tipsy({gravity: 'e'});
    addCollabsibleButtons('tab1');

    // load budget districts
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingBudgetDistrict&tab=tab2', function (response) {
      appendTab('tab2', response);
    });

    // load budget cost categorization
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingBudgetCostCategorization&tab=tab3', function (response) {
      appendTab('tab3', response);
    });

    // load expenditure
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingSpend&tab=tab4', function (response) {
      appendTab('tab4', response);
    });

    // load expenditure districts
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingSpendDistrict&tab=tab5', function (response) {
      appendTab('tab5', response);
    });
    // load expenditure cost categories
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingSpendCostCategorization&tab=tab6', function (response) {
      appendTab('tab6', response);
    });

    // bind click events for tabs
    jQuery(".nav2 ul li").click(function (e) {
      e.preventDefault();
      jQuery(".nav2 ul li").removeClass('selected');
      jQuery(this).addClass('selected');
      jQuery("#activity_classification > div").hide();
      jQuery('#activity_classification > div.' + jQuery(this).attr("id")).show();
    });

    // remove flash notice
    jQuery("#notice").fadeOut(3000);

    jQuery("#use_budget_codings_for_spend").click(function () {
      jQuery.post( "/activities/" + _activity_id + "/use_budget_codings_for_spend",
       { checked: jQuery(this).is(':checked'), "_method": "put" }
      );
    })

    jQuery("#approve_activity").click(function () {
      jQuery.post( "/activities/" + _activity_id + "/approve",
       { checked: jQuery(this).is(':checked'), "_method": "put" }
      );
    })
  }
};

var data_responses_review = {
  run: function () {
    jQuery(".use_budget_codings_for_spend").click(function () {
      activity_id = Number(jQuery(this).attr('id').match(/\d+/)[0], 10);
      jQuery.post( "/activities/" + activity_id + "/use_budget_codings_for_spend",
       { checked: jQuery(this).is(':checked'), "_method": "put" }
      );
    })
  }
}

jQuery(function () {
  var id = jQuery('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof window[controller_action] !== 'undefined') {
      window[controller_action]['run']();
    }
  }

  jQuery('#page_tips_open_link').click(function (e) {
    e.preventDefault();
    jQuery('#desc').toggle();
    jQuery('#page_tips_nav').toggle();
  });

  jQuery('#page_tips_close_link').click(function (e) {
    e.preventDefault();
    jQuery('#desc').toggle();
    jQuery('#page_tips_nav').toggle();
    jQuery("#page_tips_open_link").effect("highlight", {}, 1500);
  });


  // Date picker
  jQuery('.date_picker').live('click', function () {
    jQuery(this).datepicker('destroy').datepicker({
      changeMonth: true,
      changeYear: true,
      yearRange: '2000:2025',
      dateFormat: 'yy-mm-dd'
    }).focus();
  });
})
