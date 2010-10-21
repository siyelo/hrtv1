// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict()

var collapse_expand = function (element, type) {
  var next_element = element.next('.' + type + '.entry_main');
  var next_element_visible = next_element.is(':visible');
  jQuery('.' + type + '.entry_main').hide();
  jQuery('.' + type + '.entry_header').removeClass('active');
  if (next_element_visible) {
    next_element.hide();
  } else {
    element.addClass('active');
    next_element.show();
  }
};

var get_row_id = function (element) {
  return element.parents('tr').attr('id');
};

var get_resource_name = function (element) {
  return element.parents('#resources').attr('class');
};

var get_resource_id = function (element) {
  return Number(get_row_id(element).match(/\d+/)[0]);
};

var remove_row = function (row_id) {
  jQuery("#" + row_id).remove();
};

var destroy_resource = function (element) {
  var row_id = get_row_id(element);
  var resource_id = get_resource_id(element)
  var resource_name = get_resource_name(element);
  jQuery.post(resource_name + '/' + resource_id + '.js', {'_method': 'delete'}, function (data) {
    remove_row(row_id);
  });
};

var admin_data_responses_index = {
  run: function () {
    // destroy
    jQuery(".destroy_btn").live('click', function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (confirm('Are you sure?')) {
        destroy_resource(element);
      }
    });
  }
};


var createPieChart = function (title, domId, urlEndpoint) {
  var so = new SWFObject("/ampie/ampie.swf", "ampie", "100%", "300", "8", "#FFFFFF");
  so.addVariable("path", "");
  so.addVariable("settings_file", encodeURIComponent("/ampie/ampie_settings.xml"));
  so.addVariable("data_file", encodeURIComponent(urlEndpoint));
  so.addVariable("additional_chart_settings", encodeURIComponent(
    '<settings>' +
      '<labels>' +
        '<label lid="0">' +
          '<text>' + title + '</title>' +
        '</label>' +
      '</labels>' +
    '</settings>')
  );
  so.write(domId);
};

var admin_data_responses_show = {
  run: function () {
    jQuery('.project.entry_header').click(function () {
      collapse_expand(jQuery(this), 'project');
    });

    jQuery('.activity.entry_header').click(function () {
      collapse_expand(jQuery(this), 'activity');
    });

    jQuery('.sub_activity.entry_header').click(function () {
      collapse_expand(jQuery(this), 'sub_activity');
    });

    // bind click events for tabs
    jQuery(".classifications ul li").click(function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (element.attr("id")) {
        jQuery(".classifications ul li").removeClass('selected');
        element.addClass('selected');
        jQuery("#activity_classification > div").hide();
        jQuery('#activity_classification > div.' + element.attr("id")).show();
      }
    });

    // collapsiable project header
    jQuery("#details").click(function (e) {
      e.preventDefault();
      jQuery(".projects").toggle();
    });

    //
    // Data Response summary charts
    //
    createPieChart("", "response_total_funding", "/charts/response_total_funding");

    //
    // project charts
    //

    // bind click events for project chart tabs
    jQuery(".project_charts_nav ul.compact_tab li").click(function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (element.attr("id")) {
        jQuery(".project_charts_nav ul.compact_tab li").removeClass('selected');
        element.addClass('selected');
        jQuery(".project_charts > div").hide();
        jQuery('.project_charts > div.' + element.attr("id")).show();
      }
    });

    jQuery.each(_projects, function (i, projectId) {
      createPieChart("MTEF Budget", "project_" + projectId + "_mtef_budget", "/charts/project_pie?codings_type=CodingBudget&code_type=Mtef&project_id=" + projectId);
      createPieChart("MTEF Expenditure", "project_" + projectId + "_mtef_spend", "/charts/project_pie?codings_type=CodingSpend&code_type=Mtef&project_id=" + projectId);
      createPieChart("NSP Budget", "project_" + projectId + "_nsp_budget", "/charts/project_pie?codings_type=CodingBudget&code_type=Nsp&project_id=" + projectId);
      createPieChart("HSSPII Strat Prog Expenditure", "project_" + projectId + "_nsp_spend", "/charts/project_pie?codings_type=spend_stratprog_coding&code_type=Nsp&project_id=" + projectId);
    });


  }
};

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
      var element = jQuery(this);
      if (element.attr("id")) {
        jQuery(".nav2 ul li").removeClass('selected');
        element.addClass('selected');
        jQuery("#activity_classification > div").hide();
        jQuery('#activity_classification > div.' + element.attr("id")).show();
      }
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
    if (typeof(window[controller_action]) !== 'undefined' && typeof(window[controller_action]['run']) === 'function') {
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
