/**
    Project: Validate Classification Tree
    Author:  Glenn Roberts (Based on work by Lewis Jenkins in his Collapsible Checkbox Tree jQuery Plugin)

    License:
        This code currently available for use in all personal or
        commercial projects under both MIT and GPL licenses. This means that you can choose
        the license that best suits your project and use it accordingly.
*/

(function($) {



  $.fn.validateClassificationTree = function(options) {

    var defaults = {
      checkParents : true, // When checking a box, all parents are checked
      checkChildren : false, // When checking a box, all children are checked
      uncheckChildren : true, // When unchecking a box, all children are unchecked
      initialState : 'default' // Options - 'expand' (fully expanded), 'collapse' (fully collapsed) or default
    };

    var options = $.extend(defaults, options);



    this.each(function() {

      var $root = this;

      // Text focus function - check the associated checkbox
      $("input[type='text']", $(this)).focus(function(){
        // Show immediate children  of checked
        $("> ul", $(this).parent("li")).removeClass('hide');
        // Update the tree
        $("> span.collapsed", $(this).parent("li")).removeClass("collapsed").addClass("expanded").html('-');

        // Check parents if necessary
        if (defaults.checkParents) {
          $(this).parents("li").find("input[type='checkbox']:first").attr('checked', true);
        }

        // Check children if necessary
        if (defaults.checkChildren) {
          $(this).parent("li").find("input[type='checkbox']").attr('checked', true);
          // Show all children of checked
          $("ul", $(this).parent("li")).removeClass('hide');
          // Update the tree
          $("span.collapsed", $(this).parent("li")).removeClass("collapsed").addClass("expanded").html('-');
        }
      });

      // Check percentages on lost focus
      $("input[type='text'][id$=_percentage]", $(this)).blur(function(){

        if ($.trim($(this).val()) != ''){
          var $percentage = parseFloat($.trim($(this).val()))
          // If I enter a bad percent, indicate an error
          if( isNaN($percentage) ) {
             alert("Percentage should be number with proper decimal formatting");
          } else {
            console.debug("Percentage is %d", $percentage);
            if ($percentage > 100.0 || $percentage < 0) {
              alert("Percentage should be between 0 and 100");
            }
          }
        }
      });



      // When losing focus, do some validation
      $("input[type='text']", $(this)).blur(function(){

        // If I enter a value in a parent, then indicate that children need entering
        if ($.trim($(this).val()) != ''){
          $("> ul > li", $(this).parent("li")).addClass('incomplete'); // children, not all descendants
        }

        // Update tree when checkbox loses focus function
        // *** put this on ice cos it interferes with child code entry
        /*
        if ($.trim($(this).val()) === ''){
          //console.debug("im trigering for %d: value is %d", $(this).attr('id'), $.trim($(this).val()) );
          // Uncheck children if necessary
          if (defaults.uncheckChildren) {
            $(this).parent("li").find("input[type='checkbox']").attr('checked', false);
            // Hide all children
            $("ul", $(this).parent("li")).addClass('hide');
            // Update the tree
            $("span.expanded", $(this).parent("li")).removeClass("expanded").addClass("collapsed").html('+');
          }
        }
        */
      });




    });

    return this;

  };

})(jQuery);

/*

(function($) {

  $.fn.collapsibleCheckboxTree = function(options) {

    var defaults = {
      checkParents : true, // When checking a box, all parents are checked
      checkChildren : false, // When checking a box, all children are checked
      uncheckChildren : true, // When unchecking a box, all children are unchecked
      initialState : 'default' // Options - 'expand' (fully expanded), 'collapse' (fully collapsed) or default
    };

    var options = $.extend(defaults, options);

    this.each(function() {

      var $root = this;

      // Add button
      $(this).before('<div id="buttons"><button id="expand">Expand All</button><button id="collapse">Collapse All</button><button id="default">Default View</button></div>');

      // Hide all except top level
      $("ul", $(this)).addClass('hide');
      // Check parents if necessary
      if (defaults.checkParents) {
        $("input:checked").parents("li").find("input[type='checkbox']:first").attr('checked', true);
      }
      // Check children if necessary
      if (defaults.checkChildren) {
        $("input:checked").parent("li").find("input[type='checkbox']").attr('checked', true);
      }
      // Show checked and immediate children of checked
      $("li:has(input:checked) > ul", $(this)).removeClass('hide');
      // Add tree links
      $("li", $(this)).prepend('<span>&nbsp;</span>');
      $("li:has(> ul:not(.hide)) > span", $(this)).addClass('expanded').html('-');
      $("li:has(> ul.hide) > span", $(this)).addClass('collapsed').html('+');

      // Checkbox function
      $("input[type='checkbox']", $(this)).click(function(){

        // If checking ...
        if ($(this).is(":checked")) {

          // Show immediate children  of checked
          $("> ul", $(this).parent("li")).removeClass('hide');
          // Update the tree
          $("> span.collapsed", $(this).parent("li")).removeClass("collapsed").addClass("expanded").html('-');

          // Check parents if necessary
          if (defaults.checkParents) {
            $(this).parents("li").find("input[type='checkbox']:first").attr('checked', true);
          }

          // Check children if necessary
          if (defaults.checkChildren) {
            $(this).parent("li").find("input[type='checkbox']").attr('checked', true);
            // Show all children of checked
            $("ul", $(this).parent("li")).removeClass('hide');
            // Update the tree
            $("span.collapsed", $(this).parent("li")).removeClass("collapsed").addClass("expanded").html('-');
          }


        // If unchecking...
        } else {

          // Uncheck children if necessary
          if (defaults.uncheckChildren) {
            $(this).parent("li").find("input[type='checkbox']").attr('checked', false);
            // Hide all children
            $("ul", $(this).parent("li")).addClass('hide');
            // Update the tree
            $("span.expanded", $(this).parent("li")).removeClass("expanded").addClass("collapsed").html('+');
          }
        }

      });

      // Tree function
      $("li:has(> ul) span", $(this)).click(function(){

        // If was previously collapsed...
        if ($(this).is(".collapsed")) {

          // ... then expand
          $("> ul", $(this).parent("li")).removeClass('hide');
          // ... and update the html
          $(this).removeClass("collapsed").addClass("expanded").html('-');

        // If was previously expanded...
        } else if ($(this).is(".expanded")) {

          // ... then collapse
          $("> ul", $(this).parent("li")).addClass('hide');
          // and update the html
          $(this).removeClass("expanded").addClass("collapsed").html('+');
        }

      });

      // Button functions

      // Expand all
      $("#expand").click(function () {
        // Show all children
        $("ul", $root).removeClass('hide');
        // and update the html
        $("li:has(> ul) > span", $root).removeClass("collapsed").addClass("expanded").html('-');
        return false;
      });
      // Collapse all
      $("#collapse").click(function () {
        // Hide all children
        $("ul", $root).addClass('hide');
        // and update the html
        $("li:has(> ul) > span", $root).removeClass("expanded").addClass("collapsed").html('+');
        return false;
      });
      // Wrap around checked boxes
      $("#default").click(function () {
        // Hide all except top level
        $("ul", $root).addClass('hide');
        // Show checked and immediate children of checked
        $("li:has(input:checked) > ul", $root).removeClass('hide');
        // and update the html
        $("li:has(> ul:not(.hide)) > span", $root).removeClass('collapsed').addClass('expanded').html('-');
        $("li:has(> ul.hide) > span", $root).removeClass('expanded').addClass('collapsed').html('+');
        return false;
      });

      switch(defaults.initialState) {
        case 'expand':
          $("#expand").trigger('click');
          break;
        case 'collapse':
          $("#collapse").trigger('click');
          break;
      }

    });

    return this;

  };

})(jQuery);

*/
